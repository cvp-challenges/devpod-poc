#!/bin/bash
set -e

# Wait until package.json exists before running yarn install
echo "⏳ Waiting for package.json to be available..."

while [ ! -f /home/vscode/frontend/package.json ]; do
  sleep 1
done

cd /home/vscode/frontend
yarn install --frozen-lockfile