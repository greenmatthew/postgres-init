#!/bin/bash
set -e

# Set default wait interval if not provided
WAIT_INTERVAL=${WAIT_INTERVAL:-10}

echo "Waiting for PostgreSQL server at $PG_HOST:$PG_PORT to become available..."

# Wait for PostgreSQL to be ready
until PGPASSWORD=$PG_ADMIN_PASSWORD psql -h $PG_HOST -p ${PG_PORT:-5432} -U $PG_ADMIN_USER -c '\q' >/dev/null 2>&1; do
  echo "PostgreSQL is unavailable - sleeping for $WAIT_INTERVAL seconds"
  sleep $WAIT_INTERVAL
done

echo "PostgreSQL is up - checking for database"

# Check if database exists
DB_EXISTS=$(PGPASSWORD=$PG_ADMIN_PASSWORD psql -h $PG_HOST -U $PG_ADMIN_USER -tAc "SELECT 1 FROM pg_database WHERE datname='$APP_DB_NAME'")

if [ -z "$DB_EXISTS" ]; then
  echo "Creating database $APP_DB_NAME"
  PGPASSWORD=$PG_ADMIN_PASSWORD psql -h $PG_HOST -U $PG_ADMIN_USER -c "CREATE DATABASE $APP_DB_NAME;"
fi

# Check if user exists
USER_EXISTS=$(PGPASSWORD=$PG_ADMIN_PASSWORD psql -h $PG_HOST -U $PG_ADMIN_USER -tAc "SELECT 1 FROM pg_roles WHERE rolname='$APP_DB_USER'")

if [ -z "$USER_EXISTS" ]; then
  echo "Creating user $APP_DB_USER"
  PGPASSWORD=$PG_ADMIN_PASSWORD psql -h $PG_HOST -U $PG_ADMIN_USER -c "CREATE USER $APP_DB_USER WITH PASSWORD '$APP_DB_PASSWORD';"
fi

# Grant privileges to user
echo "Granting privileges to $APP_DB_USER on $APP_DB_NAME"
PGPASSWORD=$PG_ADMIN_PASSWORD psql -h $PG_HOST -U $PG_ADMIN_USER -c "GRANT ALL PRIVILEGES ON DATABASE $APP_DB_NAME TO $APP_DB_USER;"

# Create extensions if specified
if [ ! -z "$DB_EXTENSIONS" ]; then
  echo "Processing extensions: $DB_EXTENSIONS"
  
  # Connect to the application database
  PGPASSWORD=$PG_ADMIN_PASSWORD psql -h $PG_HOST -U $PG_ADMIN_USER -d $APP_DB_NAME -c "ALTER DATABASE $APP_DB_NAME OWNER TO $APP_DB_USER;"
  
  # Process each extension
  IFS=',' read -ra EXTS <<< "$DB_EXTENSIONS"
  for ext in "${EXTS[@]}"; do
    ext=$(echo $ext | xargs) # Trim whitespace
    echo "Enabling extension: $ext"
    PGPASSWORD=$PG_ADMIN_PASSWORD psql -h $PG_HOST -U $PG_ADMIN_USER -d $APP_DB_NAME -c "CREATE EXTENSION IF NOT EXISTS $ext;"
  done
fi

echo "Database initialization complete"