# MLflow Stack

A production-ready, self-hosted MLflow experiment tracking platform using Docker containers with PostgreSQL backend and MinIO S3-compatible object storage.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.13+](https://img.shields.io/badge/python-3.13+-blue.svg)](https://www.python.org/downloads/)
[![MLflow](https://img.shields.io/badge/MLflow-3.6+-green.svg)](https://mlflow.org/)

## Architecture

The project consists of four Docker services:

- **PostgreSQL** - Metadata store for MLflow experiments and runs
- **MinIO** - S3-compatible object storage for ML artifacts (models, plots, etc.)
- **MinIO Setup** - Initialization container to create required buckets
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
   - MinIO Console: http://localhost:9001
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
| `MINIO_ACCESS_KEY` | MinIO access key | `minioadmin` |
| `MINIO_SECRET_ACCESS_KEY` | MinIO secret key | `minioadmin123` |
| `MINIO_STORAGE_USE_HTTPS` | Use HTTPS for MinIO | `false` |

## Service Details

### PostgreSQL
- **Port**: 5433 (host) -> 5432 (container)
- **Database**: `mlflow` (automatically created)
- **Data persistence**: `postgres_data` volume

### MinIO
- **API Port**: 9000
- **Console Port**: 9001
- **Bucket**: `mlflow` (automatically created)
- **Data persistence**: `minio_data` volume

### MLflow
- **Port**: 5001
- **Backend**: PostgreSQL
- **Artifact Store**: MinIO (S3-compatible)
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

### Accessing MinIO Console

1. Navigate to http://localhost:9001
2. Login with credentials from `.env`:
   - Username: Value of `MINIO_ACCESS_KEY`
   - Password: Value of `MINIO_SECRET_ACCESS_KEY`

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
- Check if ports 5001, 5433, 9000, 9001 are available
- Verify `.env` file exists and has all required variables
- Check logs: `docker-compose logs`

### MLflow can't connect to MinIO
- Ensure all services are running: `docker-compose ps`
- Check MinIO setup completed: `docker-compose logs minio-setup`
- Verify bucket exists in MinIO console

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
├── minio/
│   └── create-bucket.sh    # Bucket initialization script
└── postgres/
    └── init.sql            # Database initialization
```

## Security Notes

- Default credentials are for development only
- For production:
  - Use strong passwords
  - Consider using Docker secrets
  - Enable HTTPS for MinIO
  - Add authentication to MLflow
  - Restrict network access