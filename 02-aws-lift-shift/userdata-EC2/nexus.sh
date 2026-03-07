#!/bin/bash
set -e

echo "Starting Nexus Provisioning on Ubuntu 22.04..."

apt update -y
apt install -y openjdk-17-jdk wget curl jq awscli

# 1. Download and Setup Nexus
mkdir -p /opt/nexus/
mkdir -p /tmp/nexus/
cd /tmp/nexus/
NEXUSURL="https://download.sonatype.com/nexus/3/nexus-3.75.1-01-unix.tar.gz"
wget $NEXUSURL -O nexus.tar.gz
sleep 10
EXTOUT=$(tar xzvf nexus.tar.gz)
NEXUSDIR=$(echo $EXTOUT | cut -d '/' -f1)
sleep 5
rm -rf /tmp/nexus/nexus.tar.gz
cp -r /tmp/nexus/* /opt/nexus/
sleep 5

# 2. Create User and Permissions
useradd nexus || true
chown -R nexus:nexus /opt/nexus

# 3. Disable Onboarding Wizard + Accept EULA
NEXUS_PROPS="/opt/nexus/sonatype-work/nexus3/etc/nexus.properties"
mkdir -p "$(dirname $NEXUS_PROPS)"
echo "nexus.onboarding.enabled=false" > "$NEXUS_PROPS"
echo "nexus.eula.accepted=true" >> "$NEXUS_PROPS"
chown -R nexus:nexus /opt/nexus/sonatype-work

# 4. Configure Systemd Service
cat > /etc/systemd/system/nexus.service <<EOT
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/$NEXUSDIR/bin/nexus start
ExecStop=/opt/nexus/$NEXUSDIR/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOT

echo 'run_as_user="nexus"' > /opt/nexus/$NEXUSDIR/bin/nexus.rc
systemctl daemon-reload
systemctl enable nexus
systemctl start nexus



# 5. Wait for Nexus to Start
echo "Waiting for Nexus to start..."
while [[ "$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8081/)" != "200" ]]; do
  echo "Still waiting..." >&2
  sleep 15
done
echo "Nexus is UP!"


# 6. Get initial password
INITIAL_PASSWORD_FILE="/opt/nexus/sonatype-work/nexus3/admin.password"
if [ ! -f "$INITIAL_PASSWORD_FILE" ]; then
    echo "ERROR: Initial password file not found."
    exit 1
fi
INITIAL_PASS=$(cat "$INITIAL_PASSWORD_FILE")
echo "Initial password retrieved."

# 7. Change password to fixed value (admin123) for demo purposes
echo "Changing admin password to admin123..."
curl -s -u "admin:$INITIAL_PASS" -X PUT \
  "http://localhost:8081/service/rest/v1/security/users/admin/change-password" \
  -H "content-type: text/plain" \
  -d 'admin123'
echo "Password changed!"


# 8. Push NEW password to SSM 
aws ssm put-parameter \
  --name "/strata-ops/nexus-password" \
  --value "admin123" \     
  --type "SecureString" \
  --overwrite \
  --region eu-central-1
echo "Nexus password pushed to SSM."


# 9. Create vprofile-repo
echo "Creating vprofile-repo..."
sleep 10

curl -s -u "admin:admin123" -X POST \
  "http://localhost:8081/service/rest/v1/repositories/maven/hosted" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "vprofile-repo",
    "online": true,
    "storage": {
      "blobStoreName": "default",
      "strictContentTypeValidation": true,
      "writePolicy": "ALLOW"
    },
    "maven": {
      "versionPolicy": "MIXED",
      "layoutPolicy": "PERMISSIVE"
    }
  }'

echo "vprofile-repo created!"
echo "Nexus Provisioning Completed!"