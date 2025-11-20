#!/bin/bash
# Environment variable initialization script
set -e

function randomPassword() {
  LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c $1; echo;
}

ENV="/workspace/.env"

# Create .env file if it doesn't exist
if [ ! -f $ENV ]; then
  echo "📝 Creating default .env file..."

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
  KEYCLOAK_REALM=fifer-audit
  KEYCLOAK_REALM_DISPLAY='"Fifer AUDIT"'
  KEYCLOAK_URL=http://localhost:$KEYCLOAK_PORT

  # Github Repo Urls to clone
  echo "FRONTEND_REPO_URL=https://github.com/cvp-challenges/devpod-odos-frontend" >> $ENV
  echo "BACKEND_REPO_URL=https://github.com/cvp-challenges/devpod-odos-backend" >> $ENV

  # External Port to container port mappings
  echo "FRONTEND_PORT_MAPPING=$FRONTEND_PORT:3000" >> $ENV
  echo "POSTGRES_PORT_MAPPING=$POSTGRES_PORT:5432" >> $ENV
  echo "KEYCLOAK_PORT_MAPPING=$KEYCLOAK_PORT:8080" >> $ENV
  echo "BACKEND_PORT_MAPPING=$BACKEND_PORT:8089" >> $ENV
  echo "PGADMIN_PORT_MAPPING=$PGADMIN_PORT:80" >> $ENV

  # Authentication signing token
  echo "SIGNING_TOKEN=$(randomPassword 32)" >> $ENV

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

  # SMTP4Dev Configuration
  echo "SMTP_SERVER_PORT=$SMTP_SERVER_PORT" >> $ENV
  echo "SMTP_SERVER_HOST=localhost" >> $ENV

  echo "✅ Default .env file created"
fi
