
# Base image with Python 3.13
FROM python:3.13-slim

# Install dependencies
RUN pip install pandas pyarrow

# Set the working directory
WORKDIR /app

# Copy the Python pipeline
COPY pipeline.py pipeline.py

# Run the pipeline when the container starts
ENTRYPOINT ["python", "/app/pipeline.py"]
