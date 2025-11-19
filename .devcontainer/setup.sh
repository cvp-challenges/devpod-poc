#!/bin/bash
set -e

echo "🚀 Setting up workspace..."

# Clone or pull frontend repo
if [ ! -d "frontend" ]; then
  echo "Cloning frontend..."
  git clone "$FRONTEND_REPO" frontend
else
  echo "Updating frontend..."
  cd frontend && git pull && cd ..
fi

# Clone or pull backend repo
if [ ! -d "backend" ]; then
  echo "Cloning backend..."
  git clone "$BACKEND_REPO" backend
else
  echo "Updating backend..."
  cd backend && git pull && cd ..
fi

# echo "Installing frontend dependencies..."
# npm install --prefix frontend

# if [ -f backend/mvnw ]; then
#   echo "Building backend..."
#   cd backend && ./mvnw clean package -DskipTests && cd ..
# fi

# # Run both services
# echo "Starting development servers..."
# cat > start.sh <<'EOF'
# #!/bin/bash
# trap "exit" INT TERM
# trap "kill 0" EXIT

# (cd backend && ./mvnw spring-boot:run) &
# (cd frontend && npm run dev) &

# wait
# EOF

# chmod +x start.sh
# ./start.sh
