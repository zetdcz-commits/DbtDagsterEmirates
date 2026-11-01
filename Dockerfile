FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DAGSTER_HOME=/opt/dagster/dagster_home

WORKDIR /app

# System libs needed to build psycopg2 / dbt-postgres dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libpq-dev git \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies first so Docker caches this layer
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the whole project, then install the Dagster package in editable mode
# (editable keeps the relative path from DagsterEmirates to DbtEmirates intact)
COPY . .
RUN pip install --no-cache-dir -e ./DagsterEmirates

# dbt finds profiles.yml inside the project folder
ENV DBT_PROFILES_DIR=/app/DbtEmirates

# Build the dbt manifest at image build time.
# Dummy credentials are only here because profiles.yml requires DBT_USER/DBT_PASSWORD;
# `dbt parse` never connects to the database.
RUN cd DbtEmirates \
    && DBT_USER=build DBT_PASSWORD=build dbt deps \
    && DBT_USER=build DBT_PASSWORD=build dbt parse

# Dagster instance config (we create these two files next)
RUN mkdir -p $DAGSTER_HOME
COPY dagster.yaml workspace.yaml $DAGSTER_HOME/

WORKDIR $DAGSTER_HOME

EXPOSE 3000

# Default: the web UI. The daemon service overrides this command.
CMD ["dagster-webserver", "-h", "0.0.0.0", "-p", "3000", "-w", "workspace.yaml"]