#!/bin/bash
set -e

# Directory where Tomcat deploys web apps on Homebrew macOS
TOMCAT_WEBAPPS="/opt/homebrew/opt/tomcat/libexec/webapps"

echo "=========================================================="
echo "  E-Banking Management System - Terminal Runner"
echo "=========================================================="

# 1. Check if database exists
echo "[1/4] Checking MySQL connection..."
echo "Note: If you haven't created the database yet, run:"
echo "      mysql -u root -p < ebanking_schema.sql"
echo ""

# 2. Package with Maven
echo "[2/4] Building banking.war with Maven..."
mvn clean package -DskipTests

# 3. Deploy to Tomcat
echo "[3/4] Deploying to Tomcat webapps ($TOMCAT_WEBAPPS)..."
rm -rf "$TOMCAT_WEBAPPS/banking" "$TOMCAT_WEBAPPS/banking.war"
cp target/banking.war "$TOMCAT_WEBAPPS/"

# 4. Start Tomcat
echo "[4/4] Starting Apache Tomcat on port 8080..."
echo ""
echo "----------------------------------------------------------"
echo "  Application URLs:"
echo "  - Home:         http://localhost:8080/banking/"
echo "  - User Login:   http://localhost:8080/banking/user/login.jsp"
echo "  - User Register:http://localhost:8080/banking/user/register.jsp"
echo "----------------------------------------------------------"
echo "Tomcat is starting below. Press [Ctrl + C] to stop."
echo ""

catalina run
