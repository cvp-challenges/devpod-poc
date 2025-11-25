#!/bin/bash
set -e

cd /workspace/backend

# Wait until package.json exists before running yarn install
echo "⏳ Waiting for pom.xml to be available..."

while [ ! -f pom.xml ]; do
  sleep 1
done

echo "📦 pom.xml found! Running mvn install..."

mvn clean install -Dmaven.test.skip=true