#!/usr/bin/env bash
set -euo pipefail
docker build -t dev-env -f docker-env/Dockerfile .
echo "✅ Image built: dev-env"
