#! /usr/bin/env bash

set -e  # Exit on error

# Get parent directory name for volume
PARENT_DIR=$(basename "$(pwd)")
VOLUME_NAME="${PARENT_DIR}_wordpress"

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