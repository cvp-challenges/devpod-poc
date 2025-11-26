#!/bin/bash
set -e

# Wait until package.json exists before running yarn install
echo "⏳ Waiting for pom.xml to be available..."

while [ ! -f /home/vscode/backend/pom.xml ]; do
  sleep 1
done

echo "📦 pom.xml found! Running mvn install..."

cd /home/vscode/backend
mvn clean install -Dmaven.test.skip=true