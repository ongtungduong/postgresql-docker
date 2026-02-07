#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <project_user>"
    exit 1
fi

PROJECT_USER=$1
echo "PROJECT_USER=${PROJECT_USER}" > ./.env

PROJECT_PASSWORD=$(openssl rand -base64 32 | tr -d 'iI1lLoO0' | tr -d -c '[:alnum:]' | cut -c1-32)
echo "PROJECT_PASSWORD=${PROJECT_PASSWORD}" >> ./.env
POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d 'iI1lLoO0' | tr -d -c '[:alnum:]' | cut -c1-32)
echo "POSTGRES_PASSWORD=${POSTGRES_PASSWORD}" >> ./.env
EXPORTER_PASSWORD=$(openssl rand -base64 32 | tr -d 'iI1lLoO0' | tr -d -c '[:alnum:]' | cut -c1-32)
echo "EXPORTER_PASSWORD=${EXPORTER_PASSWORD}" >> ./.env

POSTGRES_PORT=5432
while ss -tnpl | grep LISTEN | awk '{print $4}' | sed 's/.*://' | grep -q "^${POSTGRES_PORT}$"; do
    POSTGRES_PORT=$((POSTGRES_PORT + 1))
done
echo "POSTGRES_PORT=${POSTGRES_PORT}" >> ./.env
echo "EXPORTER_PORT=1${POSTGRES_PORT}" >> ./.env