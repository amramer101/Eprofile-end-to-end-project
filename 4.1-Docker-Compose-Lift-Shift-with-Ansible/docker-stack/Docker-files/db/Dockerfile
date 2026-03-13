## Dockerfile for MySQL database container
FROM mysql:8.0.33

## Metadata
LABEL project="vprofile-Strata-Ops"
LABEL Author="Amr M. Amer"

## Set environment variables for MySQL (Default values can be overridden by docker-compose.yml)
ENV MYSQL_ROOT_PASSWORD=vprodbpass
ENV MYSQL_DATABASE=accounts

## Copy SQL script to initialize the database with sample data
COPY db_backup.sql /docker-entrypoint-initdb.d/db_backup.sql 