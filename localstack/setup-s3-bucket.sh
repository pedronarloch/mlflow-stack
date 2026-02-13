#!/bin/bash
# Auto-create the MLflow S3 bucket on LocalStack startup.
# Mounted to /etc/localstack/init/ready.d/ via docker-compose.
aws s3api create-bucket --bucket mlflow --endpoint-url=http://localhost:4566 2>/dev/null || true