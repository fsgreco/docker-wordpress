#! /usr/bin/env bash

set -e  # Exit on error

# relative project path (since this script is located in /helpers subdir)
# also replace any spaces with underscores (only it it has spaces)
PARENT_DIR="$(basename "$(dirname "$(dirname "$(realpath "$0")")")")"
SANITIZED_DIR="${PARENT_DIR// /_}"

VOLUME_NAME="${SANITIZED_DIR}_wordpress"


echo "🔄  Stopping containers..."
docker compose down 

echo "🗑️  Removing WordPress image..."
docker image rm fsg/wordpress:latest || true

echo "🗑️  Removing WordPress volume..."
docker volume rm "${VOLUME_NAME}" || true

echo "🏗️  Building new WordPress image..."
docker build -t fsg/wordpress:latest -f Dockerfile.website .

echo "✅  WordPress container refresh completed successfully!"

# Start containers (optional)
# docker compose up -d