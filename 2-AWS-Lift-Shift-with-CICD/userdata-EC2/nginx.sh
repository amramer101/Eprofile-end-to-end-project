#!/bin/bash
set -e

echo "Starting Nginx Provisioning on Ubuntu 22.04..."

apt update -y
apt install -y nginx dnsutils

# Wait for Tomcat DNS to resolve
echo "Waiting for app01.eprofile.in to resolve..."
until dig +short app01.eprofile.in | grep -q '.'; do
  echo "DNS not ready yet..." >&2
  sleep 5
done

TOMCAT_IP=$(dig +short app01.eprofile.in | tail -1)
echo "Tomcat IP resolved: $TOMCAT_IP"

# Write nginx config directly to the correct path (NO mv needed)
cat > /etc/nginx/sites-available/vproapp <<EOT
upstream vproapp {
  server ${TOMCAT_IP}:8080;
}
server {
  listen 80;
  location / {
    proxy_pass http://vproapp;
  }
}
EOT

# Enable vproapp and disable default
rm -rf /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp

systemctl enable nginx
systemctl restart nginx

echo "Nginx Provisioning Completed!"

#-------------------------------------------------------------
# 1. Basic System Setup
#-------------------------------------------------------------
echo "===== [1/6] Setting up basic system configuration ====="
echo "Setting hostname to web01..."
echo "nginx" > /etc/hostname
hostname nginx

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