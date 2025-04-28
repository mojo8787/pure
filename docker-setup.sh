#!/bin/bash

# Create directories if they don't exist
mkdir -p db/init kong

# Generate secure passwords
POSTGRES_PASSWORD=$(openssl rand -base64 16)
JWT_SECRET=$(openssl rand -base64 32)

# Create .env file with generated passwords
cat > .env.docker <<EOL
# Postgres
POSTGRES_PASSWORD=$POSTGRES_PASSWORD

# JWT
JWT_SECRET=$JWT_SECRET
EOL

echo "Created .env.docker file with secure random passwords"
echo "To start Supabase, run: docker-compose up -d"
echo "To view logs, run: docker-compose logs -f"
echo "To stop Supabase, run: docker-compose down"
echo ""
echo "Local Supabase URLs:"
echo "- API: http://localhost:8000"
echo "- Auth: http://localhost:8000/auth"
echo "- Database: localhost:5432"
echo ""
echo "Database connection details:"
echo "- Host: localhost"
echo "- Port: 5432"
echo "- User: postgres"
echo "- Password: $POSTGRES_PASSWORD (saved in .env.docker)"
echo "- Database: postgres"
echo ""
echo "----------------------------------------------------------------"
echo "To update your Flutter app to use the local Supabase instance:"
echo ""
echo "1. Create a '.env' file in your Flutter project with:"
echo "SUPABASE_URL=http://localhost:8000"
echo "SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJvbGUiOiJhbm9uIn0.ZopqoUt20nEV9cklpv_ZJFJpr0vPpGvZtLNJR-cni5Y"
echo "SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJvbGUiOiJzZXJ2aWNlX3JvbGUifQ.M1yJUoQKt0Q1S4qdDgPWYgc3DFMVv9wy_8dJr2SvQQw"
echo ""
echo "2. Load these environment variables in your app"
echo "----------------------------------------------------------------" 