#!/bin/bash
set -e

# Wait for PostgreSQL to be ready
until PGPASSWORD=$PG_ADMIN_PASSWORD psql -h $PG_HOST -U $PG_ADMIN_USER -c '\q'; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 10
done

echo "PostgreSQL is up - checking for database"

# Check if database exists
DB_EXISTS=$(PGPASSWORD=$PG_ADMIN_PASSWORD psql -h $PG_HOST -U $PG_ADMIN_USER -tAc "SELECT 1 FROM pg_database WHERE datname='$APP_DB_NAME'")

if [ -z "$DB_EXISTS" ]; then
  echo "Creating database $APP_DB_NAME"
  PGPASSWORD=$PG_ADMIN_PASSWORD psql -h $PG_HOST -U $PG_ADMIN_USER -c "CREATE DATABASE $APP_DB_NAME;"
fi

# Similar logic for user creation and permission granting

echo "Database initialization complete"