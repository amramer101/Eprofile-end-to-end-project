#!/bin/bash
set -e

echo "Starting MySQL Provisioning on Ubuntu 22.04..."

# Wait for network/NAT Gateway to be ready
echo "Waiting for network connectivity..."
until curl -s --max-time 5 http://archive.ubuntu.com > /dev/null 2>&1; do
  echo "Network not ready yet, waiting..." >&2
  sleep 10
done
echo "Network is ready!"

apt update -y
apt install -y mariadb-server git curl awscli

echo "Allowing external connections..."
sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

systemctl restart mariadb
systemctl enable mariadb

# Fetch password from SSM
REGION="eu-central-1"
echo "Fetching Database Password from AWS SSM..."
for i in {1..10}; do
  DATABASE_PASS=$(aws ssm get-parameter --name "/strata-ops/mysql-password" \
    --with-decryption --query "Parameter.Value" --output text --region $REGION 2>/dev/null) && break
  echo "SSM not ready yet, retrying ($i/10)..." >&2
  sleep 15
done

if [ -z "$DATABASE_PASS" ]; then
  echo "ERROR: Could not fetch DB password from SSM"
  exit 1
fi

echo "Configuring MariaDB..."
mysql -u root -e "CREATE DATABASE IF NOT EXISTS accounts;"
mysql -u root -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'localhost' IDENTIFIED BY '$DATABASE_PASS';"
mysql -u root -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%' IDENTIFIED BY '$DATABASE_PASS';"
mysql -u root -e "FLUSH PRIVILEGES;"

echo "Cloning repo and restoring DB dump..."
for i in {1..5}; do
  git clone -b main https://github.com/amramer101/Strata-Ops.git /tmp/Strata-Ops && break
  echo "git clone failed, retrying ($i/5)..." >&2
  rm -rf /tmp/Strata-Ops
  sleep 15
done

mysql -u root accounts < /tmp/Strata-Ops/src/main/resources/db_backup.sql

echo "Verifying tables..."
mysql -u root accounts -e "SHOW TABLES;"
mysql -u root accounts -e "SELECT COUNT(*) as user_count FROM user;"

echo "MySQL Provisioning Completed Successfully!"



#-------------------------------------------------------------
# 1. Basic System Setup
#-------------------------------------------------------------
echo "===== [1/6] Setting up basic system configuration ====="
echo "Setting hostname to web01..."
echo "mysql" > /etc/hostname
hostname mysql

echo "Installing essential utilities (zip, unzip)..."
apt install -y zip unzip

#-------------------------------------------------------------
# 2. Install and Configure Node Exporter
#-------------------------------------------------------------
echo "===== [2/6] Installing Prometheus Node Exporter ====="

mkdir -p /tmp/exporter
cd /tmp/exporter

NODE_VERSION="1.10.2"
echo "Downloading Node Exporter v${NODE_VERSION}..."
wget -q https://github.com/prometheus/node_exporter/releases/download/v${NODE_VERSION}/node_exporter-${NODE_VERSION}.linux-amd64.tar.gz

echo "Extracting Node Exporter..."
tar xzf node_exporter-${NODE_VERSION}.linux-amd64.tar.gz

echo "Moving binary to /var/lib/node..."
mkdir -p /var/lib/node
mv node_exporter-${NODE_VERSION}.linux-amd64/node_exporter /var/lib/node/

echo "Creating prometheus system user..."
groupadd --system prometheus || true
useradd -s /sbin/nologin --system -g prometheus prometheus || true

chown -R prometheus:prometheus /var/lib/node/
chmod -R 775 /var/lib/node

echo "Creating Node Exporter systemd service..."
cat <<EOF > /etc/systemd/system/node.service
[Unit]
Description=Prometheus Node Exporter
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/var/lib/node/node_exporter
SyslogIdentifier=prometheus_node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "Enabling and starting Node Exporter..."
systemctl daemon-reload
systemctl enable --now node
systemctl status node --no-pager

echo "Node Exporter setup completed."