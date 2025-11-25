#!/bin/bash
set -e

cd /workspace/frontend

# Wait until package.json exists before running yarn install
echo "⏳ Waiting for package.json to be available..."

while [ ! -f package.json ]; do
  sleep 1
done

echo "📦 package.json found! Running yarn install..."

yarn install --frozen-lockfile