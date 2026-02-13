#!/bin/bash
# Auto-create the MLflow S3 bucket on LocalStack startup.
# Mounted to /etc/localstack/init/ready.d/ via docker-compose.
curl -sf -X PUT http://localhost:4566/mlflow || true