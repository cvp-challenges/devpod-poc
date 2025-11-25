#!/bin/bash
set -e

ENV=/workspace/.env

function randomPassword() {
  LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c $1; echo;
}

echo "🚀 DevPod workspace initializing..."

# Initialize $ENV variables
if [ ! -f $ENV ]; then
  # Exposed external ports
  SMTP_SERVER_PORT=25
  FRONTEND_PORT=3000
  AWS_API_PORT=4566
  POSTGRES_PORT=5432
  KEYCLOAK_PORT=8080
  BACKEND_PORT=8089
  PGADMIN_PORT=8099

  # Keys and URLs
  ACCESS_KEY=LKIA$(randomPassword 16)
  ACCESS_KEY=${ACCESS_KEY^^}
  AWS_ENDPOINT_URL=http://localhost:$AWS_API_PORT
  NEXTAUTH_URL=http://localhost:$FRONTEND_PORT
  NEXT_APP_API=http://localhost:$BACKEND_PORT
  KEYCLOAK_REALM=odos-iv-tech-challenge
  KEYCLOAK_REALM_DISPLAY="\"ODOS IV Tech Challenge\""
  KEYCLOAK_URL=http://localhost:$KEYCLOAK_PORT
  SIGNING_TOKEN=$(randomPassword 32)

  # Authentication signing token
  echo "NEXTAUTH_URL=$NEXTAUTH_URL" >> $ENV
  echo "NEXTAUTH_SECRET=$SIGNING_TOKEN" >> $ENV
  echo "JWT_TOKEN_SECRET=$SIGNING_TOKEN" >> $ENV

  # Localstack Configuration (AWS Emulator)
  echo "AWS_ACCESS_KEY_ID=$ACCESS_KEY" >> $ENV
  echo "AWS_SECRET_ACCESS_KEY=$(randomPassword 40)" >> $ENV
  echo "AWS_ENDPOINT_URL=$AWS_ENDPOINT_URL" >> $ENV
  echo "AWS_DEFAULT_REGION=us-east-1" >> $ENV

  # PostgreSQL Configuration
  echo "POSTGRES_DB=postgres" >> $ENV
  echo "POSTGRES_HOST=localhost" >> $ENV
  echo "POSTGRES_PORT=$POSTGRES_PORT" >> $ENV
  echo "POSTGRES_USER=postgres" >> $ENV
  echo "POSTGRES_PASSWORD=$(randomPassword 20)" >> $ENV

  # APP DB Configuration
  echo "APP_DB_USER=appuser" >> $ENV
  echo "APP_DB_PASSWORD=$(randomPassword 20)" >> $ENV

  # Data DB Configuration
  echo "DATA_DB_USER=appuser" >> $ENV
  echo "DATA_DB_PASSWORD=$(randomPassword 20)" >> $ENV

  # Keycloak Configuration
  echo "KEYCLOAK_DB=keycloak" >> $ENV
  echo "KEYCLOAK_DB_USER=keycloak" >> $ENV
  echo "KEYCLOAK_DB_PASSWORD=$(randomPassword 20)" >> $ENV
  echo "KEYCLOAK_PORT=$KEYCLOAK_PORT" >> $ENV
  echo "KEYCLOAK_URL=$KEYCLOAK_URL" >> $ENV
  echo "KEYCLOAK_ADMIN=admin" >> $ENV
  echo "KEYCLOAK_ADMIN_PASSWORD=$(randomPassword 20)" >> $ENV
  echo "KEYCLOAK_REALM=$KEYCLOAK_REALM" >> $ENV
  echo "KEYCLOAK_REALM_DISPLAY=$KEYCLOAK_REALM_DISPLAY" >> $ENV
  echo "KEYCLOAK_ISSUER=$KEYCLOAK_URL/realms/$KEYCLOAK_REALM" >> $ENV
  echo "KEYCLOAK_CLIENT_ID=$KEYCLOAK_REALM-ui" >> $ENV
  echo "KEYCLOAK_CLIENT_SECRET=$(randomPassword 20)" >> $ENV
  echo "KEYCLOAK_SERVICE_ACCOUNT_CLIENT_ID=admin-cli" >> $ENV
  echo "KEYCLOAK_SERVICE_ACCOUNT_CLIENT_SECRET=$(randomPassword 30)" >> $ENV

  # PGAdmin Configuration
  echo "PGADMIN_PORT=$PGADMIN_PORT" >> $ENV
  echo "PGADMIN_DEFAULT_EMAIL=admin@cvpcorp.com" >> $ENV
  echo "PGADMIN_DEFAULT_PASSWORD=$(randomPassword 20)" >> $ENV

  # SMTP Configuration
  echo "SMTP_SERVER_PORT=$SMTP_SERVER_PORT" >> $ENV
  echo "SMTP_SERVER_HOST=localhost" >> $ENV

  # MISC
  echo "KAFKA_BOOTSTRAP_SERVERS=kafka:9092" >> $ENV
  echo "FORM_UPLOAD_BUCKET=formuploads" >> $ENV
  echo "FORM_INBOUND_TOPIC=form.inbound" >> $ENV
fi

echo "🚀 Configuring env varibales..."
set -a
source $ENV
set +a

# --- Git global setup ---
git config --global credential.helper 'cache --timeout=3600' || true

echo "🚀 Cloning Repositories..."

if [ ! -d "frontend/.git" ]; then
  git clone https://github.com/cvp-challenges/devpod-odos-frontend /workspace/frontend
fi

if [ ! -d "backend/.git" ]; then
  git clone https://github.com/cvp-challenges/devpod-odos-backend /workspace/backend
fi

echo "🔒 Marking repositories as safe..."
git config --global --add safe.directory "/workspace/backend" || true
git config --global --add safe.directory "/workspace/frontend" || true

# Ensure Docker is running and ready
until docker info >/dev/null 2>&1; do sleep 1; done

echo "🔒 Starting common services..."
docker-compose -f /workspace/common/services.yml up -d

echo "✅ Environment ready! You can now run VS Code tasks to build and start services."
exec sleep infinity
