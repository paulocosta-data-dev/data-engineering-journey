import sys
import pandas as pd

print("Arguments:", sys.argv)

day = int(sys.argv[1])

print(f"Running pipeline for day {day}")

# Create a sample DataFrame
df = pd.DataFrame({
    "A": [1, 2],
    "B": [3, 4]
})

print(df.head())

# Export data to Parquet
output_file = f"output_day_{day}.parquet"

df.to_parquet(output_file)

print(f"Pipeline completed. File created: {output_file}")