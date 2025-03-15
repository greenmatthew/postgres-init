# postgres-init

A utility container that initializes PostgreSQL databases for your application stacks.

## Purpose

This container simplifies connecting applications to a centralized PostgreSQL database by:

1. Waiting for the PostgreSQL server to be available
2. Creating the application database if it doesn't exist
3. Creating a dedicated database user if needed
4. Granting appropriate permissions
5. Setting up any required PostgreSQL extensions

## Usage

### In docker-compose.yml

```yaml
services:
  myapp-db-init:
    image: greenmatthew/postgres-init:latest
    environment:
      PG_HOST: postgres
      PG_ADMIN_USER: postgres
      PG_ADMIN_PASSWORD: ${POSTGRES_PASSWORD}
      APP_DB_NAME: myapp
      APP_DB_USER: myapp
      APP_DB_PASSWORD: ${MYAPP_DB_PASSWORD}
      DB_EXTENSIONS: pg_trgm
    networks:
      - postgres_network
    restart: "no"  # Run once and exit

  myapp:
    image: myapp:latest
    depends_on:
      myapp-db-init:
        condition: service_completed_successfully
    environment:
      DB_HOST: postgres
      DB_PORT: 5432
      DB_NAME: myapp
      DB_USER: myapp
      DB_PASSWORD: ${MYAPP_DB_PASSWORD}
    # ... rest of application config
```

### Environment Variables

#### Required:
- `PG_HOST`: Hostname of your PostgreSQL server
- `PG_ADMIN_USER`: PostgreSQL admin username
- `PG_ADMIN_PASSWORD`: PostgreSQL admin password
- `APP_DB_NAME`: Name of the database to create
- `APP_DB_USER`: User to create and grant access
- `APP_DB_PASSWORD`: Password for the user

#### Optional:
- `PG_PORT`: PostgreSQL port (default: 5432)
- `WAIT_INTERVAL`: Seconds to wait between connection attempts (default: 10)
- `DB_EXTENSIONS`: Comma-separated list of extensions to enable (optional)

## Examples

### For Immich:

```yaml
immich-db-init:
  image: matthewgreen/postgres-init:latest
  environment:
    PG_HOST: postgres
    PG_ADMIN_USER: postgres
    PG_ADMIN_PASSWORD: ${POSTGRES_PASSWORD}
    APP_DB_NAME: immich
    APP_DB_USER: immich
    APP_DB_PASSWORD: ${IMMICH_DB_PASSWORD}
    DB_EXTENSIONS: vectors
  networks:
    - postgres_network
```

### For Nextcloud:

```yaml
nextcloud-db-init:
  image: matthewgreen/postgres-init:latest
  environment:
    PG_HOST: postgres
    PG_ADMIN_USER: postgres
    PG_ADMIN_PASSWORD: ${POSTGRES_PASSWORD}
    APP_DB_NAME: nextcloud
    APP_DB_USER: nextcloud
    APP_DB_PASSWORD: ${NEXTCLOUD_DB_PASSWORD}
    DB_EXTENSIONS: pg_trgm
  networks:
    - postgres_network
```

## Building

```bash
docker build -t matthewgreen/postgres-init:latest .
```