#!/bin/bash

set -e

source .env

DB_URL="postgres://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=${DB_SSLMODE}"

case "$1" in
  up)
    echo "Running migrations..."
    migrate -path ./migrations -database "${DB_URL}" up
    echo "✅ Migrations completed"
    ;;
  down)
    echo "Rolling back migrations..."
    migrate -path ./migrations -database "${DB_URL}" down
    echo "✅ Rollback completed"
    ;;
  force)
    echo "Forcing migration version to $2..."
    migrate -path ./migrations -database "${DB_URL}" force "$2"
    echo "✅ Forced to version $2"
    ;;
  version)
    migrate -path ./migrations -database "${DB_URL}" version
    ;;
  *)
    echo "Usage: $0 {up|down|force|version} [version]"
    exit 1
    ;;
esac