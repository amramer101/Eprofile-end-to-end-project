#!/bin/bash
set -e

# ============================================================
# Database Initialization Script for RDS
# ============================================================
# This script runs on Bastion Host to initialize the RDS database
# with proper schema and default users

echo "========================================="
echo "🗄️  Database Initialization Starting..."
echo "========================================="

# Export variables from Terraform
export RDS_ENDPOINT="${RDS_ENDPOINT}"
export DB_USER="${DB_USER}"
export DB_PASSWORD="${DB_PASSWORD}"
export DB_NAME="${DB_NAME}"

echo "📋 Configuration:"
echo "   RDS Endpoint: $RDS_ENDPOINT"
echo "   Database: $DB_NAME"
echo "   User: $DB_USER"
echo ""

# Install MySQL client
echo "Installing MySQL client..."
sudo apt-get update -y > /dev/null 2>&1
sudo apt-get install -y mysql-client > /dev/null 2>&1
echo "MySQL client installed"

# Wait for RDS to be ready
echo " Waiting for RDS database to be ready..."
MAX_ATTEMPTS=30
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
  if mysql -h "$RDS_ENDPOINT" -u "$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1" > /dev/null 2>&1; then
    echo " RDS is ready!"
    break
  fi
  ATTEMPT=$((ATTEMPT + 1))
  echo "   Attempt $ATTEMPT/$MAX_ATTEMPTS... retrying in 10 seconds"
  sleep 10
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
  echo " ERROR: Could not connect to RDS after $MAX_ATTEMPTS attempts"
  exit 1
fi

# Clone repository to get db_backup.sql
echo ""
echo "Cloning vprofile project..."
cd /tmp
if [ -d "vprofile-project" ]; then
  rm -rf vprofile-project
fi

git clone -b local https://github.com/hkhcoder/vprofile-project.git > /dev/null 2>&1
echo " Repository cloned"

# Verify db_backup.sql exists
if [ ! -f "/tmp/vprofile-project/src/main/resources/db_backup.sql" ]; then
  echo "ERROR: db_backup.sql not found at expected location"
  echo "   Checked: /tmp/vprofile-project/src/main/resources/db_backup.sql"
  exit 1
fi

echo "db_backup.sql found"

# Import database schema and data
echo ""
echo "Importing database schema and data..."
mysql -h "$RDS_ENDPOINT" \
      -u "$DB_USER" \
      -p"$DB_PASSWORD" \
      --ssl-mode=DISABLED \
      "$DB_NAME" < /tmp/vprofile-project/src/main/resources/db_backup.sql

if [ $? -eq 0 ]; then
  echo "Database schema imported successfully"
else
  echo "ERROR: Failed to import database schema"
  exit 1
fi

# Verify critical tables exist
echo ""
echo "🔍 Verifying database structure..."

TABLE_COUNT=$(mysql -h "$RDS_ENDPOINT" \
             -u "$DB_USER" \
             -p"$DB_PASSWORD" \
             --ssl-mode=DISABLED \
             "$DB_NAME" \
             -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB_NAME';" \
             2>/dev/null | tail -1)

if [ "$TABLE_COUNT" -gt 0 ]; then
  echo "Found $TABLE_COUNT tables in database"
  
  # List tables
  echo ""
  echo "Tables in database:"
  mysql -h "$RDS_ENDPOINT" \
       -u "$DB_USER" \
       -p"$DB_PASSWORD" \
       --ssl-mode=DISABLED \
       "$DB_NAME" \
       -e "SHOW TABLES;" \
       2>/dev/null | sed 's/^/   /'
else
  echo "WARNING: No tables found in database"
fi

# Verify users table exists and has admin_vp user
echo ""
echo "Verifying application users..."

USERS_TABLE=$(mysql -h "$RDS_ENDPOINT" \
             -u "$DB_USER" \
             -p"$DB_PASSWORD" \
             --ssl-mode=DISABLED \
             "$DB_NAME" \
             -e "SHOW TABLES LIKE 'user%';" \
             2>/dev/null | tail -1)

if [ -n "$USERS_TABLE" ]; then
  USER_COUNT=$(mysql -h "$RDS_ENDPOINT" \
              -u "$DB_USER" \
              -p"$DB_PASSWORD" \
              --ssl-mode=DISABLED \
              "$DB_NAME" \
              -e "SELECT COUNT(*) FROM \`${USERS_TABLE}\`;" \
              2>/dev/null | tail -1)
  
  echo "Found $USER_COUNT users in table '$USERS_TABLE'"
  
  # List users
  echo ""
  echo "👥 Users in database:"
  mysql -h "$RDS_ENDPOINT" \
       -u "$DB_USER" \
       -p"$DB_PASSWORD" \
       --ssl-mode=DISABLED \
       "$DB_NAME" \
       -e "SELECT id, username, email FROM \`${USERS_TABLE}\` LIMIT 10;" \
       2>/dev/null | sed 's/^/   /'
else
  echo "WARNING: No user table found"
fi

# Check for admin_vp specifically
ADMIN_CHECK=$(mysql -h "$RDS_ENDPOINT" \
             -u "$DB_USER" \
             -p"$DB_PASSWORD" \
             --ssl-mode=DISABLED \
             "$DB_NAME" \
             -e "SELECT COUNT(*) FROM \`${USERS_TABLE}\` WHERE username='admin_vp' OR email='admin_vp';" \
             2>/dev/null | tail -1)

if [ "$ADMIN_CHECK" -gt 0 ]; then
  echo "admin_vp user found in database!"
else
  echo "WARNING: admin_vp user NOT found - may need manual creation"
fi

# Final summary
echo ""
echo "========================================="
echo "Database initialization completed!"
echo "========================================="
echo ""
echo "Summary:"
echo "  - Database: $DB_NAME"
echo "  - Host: $RDS_ENDPOINT"
echo "  - Tables: $TABLE_COUNT"
echo "  - Users: $USER_COUNT"
echo ""
echo "Next Steps:"
echo "  1. Wait for Elastic Beanstalk deployment to complete"
echo "  2. Access the application via the Load Balancer URL"
echo "  3. Try logging in with your credentials"
echo ""

exit 0
