#!/bin/bash
set -e

INIT_FLAG="/workspace/.initialized"
ENV="/workspace/.env"

if [ ! -f "$INIT_FLAG" ]; then
  echo "🚀 First-time initialization..."

  # Generate .env file
  if [ ! -f "$ENV" ]; then
    echo "🔧 Creating environment file..."

    function randomPassword() {
      LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c $1; echo;
    }

    SMTP_SERVER_PORT=25
    FRONTEND_PORT=3000
    AWS_API_PORT=4566
    POSTGRES_PORT=5432
    KEYCLOAK_PORT=8080
    BACKEND_PORT=8089
    PGADMIN_PORT=8099

    ACCESS_KEY=LKIA$(randomPassword 16)
    ACCESS_KEY=${ACCESS_KEY^^}
    AWS_ENDPOINT_URL=http://localhost:$AWS_API_PORT
    NEXTAUTH_URL=http://localhost:$FRONTEND_PORT
    NEXT_APP_API=http://localhost:$BACKEND_PORT
    KEYCLOAK_REALM=odos-iv-tech-challenge
    KEYCLOAK_REALM_DISPLAY="\"ODOS IV Tech Challenge\""
    KEYCLOAK_URL=http://localhost:$KEYCLOAK_PORT
    SIGNING_TOKEN=$(randomPassword 32)

    cat <<EOF > "$ENV"
NEXTAUTH_URL=$NEXTAUTH_URL
NEXTAUTH_SECRET=$SIGNING_TOKEN
JWT_TOKEN_SECRET=$SIGNING_TOKEN

AWS_ACCESS_KEY_ID=$ACCESS_KEY
AWS_SECRET_ACCESS_KEY=$(randomPassword 40)
AWS_ENDPOINT_URL=$AWS_ENDPOINT_URL
AWS_DEFAULT_REGION=us-east-1

POSTGRES_DB=postgres
POSTGRES_HOST=localhost
POSTGRES_PORT=$POSTGRES_PORT
POSTGRES_USER=postgres
POSTGRES_PASSWORD=$(randomPassword 20)

APP_DB_USER=appuser
APP_DB_PASSWORD=$(randomPassword 20)

DATA_DB_USER=appuser
DATA_DB_PASSWORD=$(randomPassword 20)

KEYCLOAK_DB=keycloak
KEYCLOAK_DB_USER=keycloak
KEYCLOAK_DB_PASSWORD=$(randomPassword 20)
KEYCLOAK_PORT=$KEYCLOAK_PORT
KEYCLOAK_URL=$KEYCLOAK_URL
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=$(randomPassword 20)
KEYCLOAK_REALM=$KEYCLOAK_REALM
KEYCLOAK_REALM_DISPLAY=$KEYCLOAK_REALM_DISPLAY
KEYCLOAK_ISSUER=$KEYCLOAK_URL/realms/$KEYCLOAK_REALM
KEYCLOAK_CLIENT_ID=${KEYCLOAK_REALM}-ui
KEYCLOAK_CLIENT_SECRET=$(randomPassword 20)
KEYCLOAK_SERVICE_ACCOUNT_CLIENT_ID=admin-cli
KEYCLOAK_SERVICE_ACCOUNT_CLIENT_SECRET=$(randomPassword 30)

PGADMIN_PORT=$PGADMIN_PORT
PGADMIN_DEFAULT_EMAIL=admin@cvpcorp.com
PGADMIN_DEFAULT_PASSWORD=$(randomPassword 20)

SMTP_SERVER_PORT=$SMTP_SERVER_PORT
SMTP_SERVER_HOST=localhost

KAFKA_BOOTSTRAP_SERVERS=kafka:9092
FORM_UPLOAD_BUCKET=formuploads
FORM_INBOUND_TOPIC=form.inbound
EOF
  fi

  echo "📁 Sourcing environment variables..."
  set -a
  source "$ENV"
  set +a

  echo "📚 Cloning repositories..."

  if [ ! -d "/workspace/frontend/.git" ]; then
    git clone -q https://github.com/cvp-challenges/devpod-odos-frontend /workspace/frontend
  fi

  if [ ! -d "/workspace/backend/.git" ]; then
    git clone -q https://github.com/cvp-challenges/devpod-odos-backend /workspace/backend
  fi

  echo "🔒 Configuring Git safe directories..."
  git config --global --add safe.directory /workspace
  git config --global --add safe.directory /workspace/frontend
  git config --global --add safe.directory /workspace/backend

  echo "🌐 Waiting for Docker..."
  until docker info >/dev/null 2>&1; do sleep 1; done

  echo "🚀 Starting shared services..."
  cd /workspace/.devcontainer/services
  docker-compose up -d

  touch "$INIT_FLAG"
  echo "✅ Initialization complete!"
else
  echo "🔁 Normal startup"
  set -a
  source "$ENV"
  set +a
fi

chown -R vscode:vscode /workspace/frontend /workspace/backend /workspace/.env /workspace/.initialized

exec sleep infinity
