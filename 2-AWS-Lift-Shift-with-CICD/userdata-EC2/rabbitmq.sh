#!/bin/bash
set -e

echo "Starting RabbitMQ Provisioning on Ubuntu 22.04..."

# Wait for network/NAT Gateway to be ready
echo "Waiting for network connectivity..."
until curl -s --max-time 5 http://archive.ubuntu.com > /dev/null 2>&1; do
  echo "Network not ready yet, waiting..." >&2
  sleep 10
done
echo "Network is ready!"

apt update -y

# Install Erlang (Ubuntu 22.04 native packages)
apt install -y \
  erlang-base \
  erlang-asn1 \
  erlang-crypto \
  erlang-eldap \
  erlang-ftp \
  erlang-inets \
  erlang-mnesia \
  erlang-os-mon \
  erlang-parsetools \
  erlang-public-key \
  erlang-runtime-tools \
  erlang-snmp \
  erlang-ssl \
  erlang-syntax-tools \
  erlang-tftp \
  erlang-tools \
  erlang-xmerl

# Install RabbitMQ
curl -1sLf 'https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-server/setup.deb.sh' | bash
apt install -y rabbitmq-server

systemctl enable rabbitmq-server
systemctl start rabbitmq-server

# Configure
sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'
rabbitmqctl add_user test test
rabbitmqctl set_user_tags test administrator
rabbitmqctl set_permissions -p / test ".*" ".*" ".*"

systemctl restart rabbitmq-server
systemctl status rabbitmq-server

echo "RabbitMQ Provisioning Completed!"



#-------------------------------------------------------------
# 1. Basic System Setup
#-------------------------------------------------------------
echo "===== [1/6] Setting up basic system configuration ====="
echo "Setting hostname to web01..."
echo "rabbitmq" > /etc/hostname
hostname rabbitmq

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