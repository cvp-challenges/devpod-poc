#!/bin/bash
set -e

# Wait until package.json exists before running yarn install
echo "⏳ Waiting for pom.xml to be available..."

while [ ! -f /workspace/backend/pom.xml ]; do
  sleep 1
done

echo "📦 pom.xml found! Running mvn install..."

cd /workspace/backend
mvn clean install -Dmaven.test.skip=true