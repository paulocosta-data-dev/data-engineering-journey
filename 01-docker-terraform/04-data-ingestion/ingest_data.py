import argparse
from email.mime import text
import os
from time import perf_counter

import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL
from pathlib import Path
from dotenv import load_dotenv


DTYPE = {
    "VendorID": "Int64",
    "passenger_count": "Int64",
    "trip_distance": "float64",
    "RatecodeID": "Int64",
    "store_and_fwd_flag": "string",
    "PULocationID": "Int64",
    "DOLocationID": "Int64",
    "payment_type": "Int64",
    "fare_amount": "float64",
    "extra": "float64",
    "mta_tax": "float64",
    "tip_amount": "float64",
    "tolls_amount": "float64",
    "improvement_surcharge": "float64",
    "total_amount": "float64",
    "congestion_surcharge": "float64",
}

PARSE_DATES = [
    "tpep_pickup_datetime",
    "tpep_dropoff_datetime",
]

ENV_FILE = Path(__file__).resolve().parent.parent / "03-postgresql" / ".env"
load_dotenv(ENV_FILE)

def main():
    parser = argparse.ArgumentParser(
        description="Ingest NYC Taxi CSV data into PostgreSQL"
    )

    parser.add_argument("--url", required=True)
    parser.add_argument("--host", default="localhost")
    parser.add_argument("--port", type=int, default=5432)
    parser.add_argument("--user", required=True)
    parser.add_argument("--db", required=True)
    parser.add_argument("--table", required=True)

    args = parser.parse_args()

    print("Dataset:", args.url)
    print("PostgreSQL:", f"{args.host}:{args.port}/{args.db}")
    print("Target table:", args.table)

    database_url = URL.create(
        drivername="postgresql+psycopg",
        username=args.user,
        password=os.environ["POSTGRES_PASSWORD"],
        host=args.host,
        port=args.port,
        database=args.db,
    )

    engine = create_engine(
        database_url,
        connect_args={"connect_timeout": 5},
    )

    chunks = pd.read_csv(
        args.url,
        dtype=DTYPE,
        parse_dates=PARSE_DATES,
        chunksize=100_000,
    )

    with engine.connect() as conn:
        result = conn.execute(
            text("SELECT current_database(), current_user")
    )
    print("PostgreSQL connection:", result.fetchone())

    print("CSV reader initialized")
    
    total_rows = 0
    start_total = perf_counter()

    for batch_number, df_chunk in enumerate(chunks, start=1):
        start_batch = perf_counter()

        df_chunk.to_sql(
            name=args.table,
            con=engine,
            if_exists="replace" if batch_number == 1 else "append",
            index=False,
            chunksize=10_000,
        )

        total_rows += len(df_chunk)
        elapsed = perf_counter() - start_batch

        print(
            f"Batch {batch_number}: "
            f"{len(df_chunk):,} rows | "
            f"{elapsed:.2f}s"
        )

    elapsed_total = perf_counter() - start_total

    print(f"\nTotal rows ingested: {total_rows:,}")
    print(f"Total execution time: {elapsed_total:.2f}s")

    engine.dispose()


if __name__ == "__main__":
    main()