# MLflow Stack

A production-ready, self-hosted MLflow experiment tracking platform using Docker containers with PostgreSQL backend and LocalStack S3-compatible object storage.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.13+](https://img.shields.io/badge/python-3.13+-blue.svg)](https://www.python.org/downloads/)
[![MLflow](https://img.shields.io/badge/MLflow-3.6+-green.svg)](https://mlflow.org/)

## Architecture

The project consists of three Docker services:

- **PostgreSQL** - Metadata store for MLflow experiments and runs
- **LocalStack** - S3-compatible object storage for ML artifacts (models, plots, etc.)
- **MLflow Server** - ML experiment tracking and model registry UI

## Prerequisites

- Docker and Docker Compose installed
- Python 3.13+ (for local development)
- At least 2GB of available RAM

## Quick Start

1. **Clone the repository and navigate to the project directory**

2. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Edit .env if you want to change default credentials
   ```

3. **Start all services**
   ```bash
   docker-compose up -d
   ```

4. **Access the services**
   - MLflow UI: http://localhost:5001
   - LocalStack S3: http://localhost:4566
   - PostgreSQL: localhost:5433

5. **Check service status**
   ```bash
   docker-compose ps
   ```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `POSTGRES_USER` | PostgreSQL username | `postgres` |
| `POSTGRES_PASSWORD` | PostgreSQL password | `postgres` |
| `POSTGRES_DB` | PostgreSQL database name | `postgres` |
| `AWS_ACCESS_KEY_ID` | AWS/LocalStack access key | `test` |
| `AWS_SECRET_ACCESS_KEY` | AWS/LocalStack secret key | `test` |

## Service Details

### PostgreSQL
- **Port**: 5433 (host) -> 5432 (container)
- **Database**: `mlflow` (automatically created)
- **Data persistence**: `postgres_data` volume

### LocalStack
- **Port**: 4566
- **Bucket**: `mlflow` (used for artifact storage)
- **Data persistence**: `./volume` directory

### MLflow
- **Port**: 5001
- **Backend**: PostgreSQL
- **Artifact Store**: LocalStack S3
- **Features**: Experiment tracking, model registry, artifact storage

## Usage Examples

### Using MLflow in Python

```python
import mlflow

# Set tracking URI
mlflow.set_tracking_uri("http://localhost:5001")

# Start an experiment
mlflow.set_experiment("my-experiment")

# Log parameters and metrics
with mlflow.start_run():
    mlflow.log_param("learning_rate", 0.01)
    mlflow.log_metric("accuracy", 0.95)

    # Log artifacts
    mlflow.log_artifact("model.pkl")
```

## Common Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f mlflow

# Rebuild after code changes
docker-compose up -d --build

# Remove all data (WARNING: destructive)
docker-compose down -v
```

## Troubleshooting

### Services won't start
- Check if ports 5001, 5433, 4566 are available
- Verify `.env` file exists and has all required variables
- Check logs: `docker-compose logs`

### MLflow can't connect to LocalStack
- Ensure all services are running: `docker-compose ps`
- Check LocalStack logs: `docker-compose logs localstack`
- Verify the S3 bucket exists: `aws --endpoint-url=http://localhost:4566 s3 ls`

### Database connection errors
- Ensure PostgreSQL is healthy: `docker-compose logs postgres`
- Verify credentials in `.env` match what's in `docker-compose.yml`
- Check if database `mlflow` was created: `docker-compose exec postgres psql -U postgres -l`

## Development

### Project Structure
```
mlflow-stack/
├── docker-compose.yml      # Service orchestration
├── .env                    # Environment configuration (git-ignored)
├── .env.example            # Template for environment variables
├── mlflow/
│   ├── Dockerfile          # MLflow server image
│   ├── pyproject.toml      # Python dependencies
│   └── uv.lock             # Dependency lockfile
├── localstack/
│   └── setup-s3-bucket.sh  # S3 bucket initialization script
├── postgres/
│   └── init.sql            # Database initialization
└── volume/                 # LocalStack data persistence
```

## Security Notes

- Default credentials are for development only
- For production:
  - Use strong passwords
  - Consider using Docker secrets
  - Use a real S3 service or enable HTTPS for LocalStack
  - Add authentication to MLflow
  - Restrict network access