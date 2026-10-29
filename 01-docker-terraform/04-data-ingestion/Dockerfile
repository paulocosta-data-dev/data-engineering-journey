FROM python:3.13-slim

WORKDIR /app

COPY pyproject.toml .python-version ./
COPY src ./src

RUN pip install --no-cache-dir pandas sqlalchemy "psycopg[binary]" python-dotenv

COPY ingest_data.py ./

ENTRYPOINT ["python", "ingest_data.py"]