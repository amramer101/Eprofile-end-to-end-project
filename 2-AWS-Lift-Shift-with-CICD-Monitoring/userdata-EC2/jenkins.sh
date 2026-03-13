#!/bin/bash
sudo apt update
sudo apt install fontconfig openjdk-21-jre -y

sudo mkdir -p /etc/apt/keyrings

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install jenkins -y
sudo apt install awscli -y
sudo systemctl stop jenkins   

# 3. Disable the Initial Setup Wizard (We are using JCasC)
sudo sed -i 's/Environment="JAVA_OPTS=-Djava.awt.headless=true"/Environment="JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false"/g' /usr/lib/systemd/system/jenkins.service

# 4. Download Jenkins Plugin Manager CLI
wget https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.14/jenkins-plugin-manager-2.12.14.jar

# 5. Install all required plugins
sudo java -jar jenkins-plugin-manager-2.12.14.jar \
  --war /usr/share/java/jenkins.war \
  --plugin-download-directory /var/lib/jenkins/plugins \
  --plugins configuration-as-code git github workflow-aggregator credentials plain-credentials ssh-credentials sonar slack maven-plugin email-ext timestamper ws-cleanup job-dsl nexus-artifact-uploader ssh-agent dependency-check-jenkins-plugin build-timestamp

# 6. Setup JCasC Directory and Download your YAML file
sudo mkdir -p /var/lib/jenkins/casc_configs
sudo curl -L "https://raw.githubusercontent.com/amramer101/Strata-Ops/main/02-aws-lift-shift/userdata-EC2/jenkins.yaml" -o /var/lib/jenkins/casc_configs/jenkins.yaml
sudo chown -R jenkins:jenkins /var/lib/jenkins/casc_configs


# ==============================================================================
# 7. FETCHING SECRETS FROM AWS SSM
# ==============================================================================
REGION="eu-central-1"

wait_for_ssm_param() {
  PARAM_NAME=$1
  while true; do
    VAL=$(aws ssm get-parameter --name "$PARAM_NAME" --with-decryption --query "Parameter.Value" --output text --region $REGION 2>/dev/null)
    if [[ "$VAL" != "pending" && -n "$VAL" ]]; then
      echo "$VAL"  
      break
    fi
    echo "Waiting for $PARAM_NAME..." >&2 
    sleep 10
  done
}

echo "Fetching parameters from AWS SSM..."

JENKINS_PASS=$(aws ssm get-parameter --name "/strata-ops/jenkins-admin-password" --with-decryption --query "Parameter.Value" --output text --region $REGION)
GITHUB_KEY=$(aws ssm get-parameter --name "/strata-ops/github-private-key" --with-decryption --query "Parameter.Value" --output text --region $REGION)
TOMCAT_SSH_KEY=$(aws ssm get-parameter --name "/strata-ops/tomcat-ssh-key" --with-decryption --query "Parameter.Value" --output text --region $REGION)

SONAR_TOK=$(wait_for_ssm_param "/strata-ops/sonar-token")
SLACK_TOK=$(wait_for_ssm_param "/strata-ops/slack-token")
NEXUS_PASS=$(wait_for_ssm_param "/strata-ops/nexus-password")

# ==============================================================================
# 8. INJECT ENVIRONMENT VARIABLES SECURELY (No SSH Keys here)
# ==============================================================================
sudo mkdir -p /etc/systemd/system/jenkins.service.d/
cat <<EOF | sudo tee /etc/systemd/system/jenkins.service.d/override.conf
[Service]
Environment="JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false"
Environment="CASC_JENKINS_CONFIG=/var/lib/jenkins/casc_configs/jenkins.yaml"
Environment="ADMIN_PASSWORD=${JENKINS_PASS}"
Environment="SONAR_TOKEN=${SONAR_TOK}"
Environment="SLACK_TOKEN=${SLACK_TOK}"
EOF

# ==============================================================================
# 8.5 THE MAGIC TRICK: APPEND SSH KEYS DIRECTLY TO YAML WITH PERFECT INDENTATION
# ==============================================================================
echo "Appending multiline SSH Keys to jenkins.yaml dynamically..."
cat <<EOF | sudo tee -a /var/lib/jenkins/casc_configs/jenkins.yaml

      # 3. GitHub SSH Key
      - basicSSHUserPrivateKey:
          id: "github-ssh-key"
          scope: GLOBAL
          username: "git"
          description: "GitHub Private Key for cloning repo"
          privateKeySource:
            directEntry:
              privateKey: |
$(echo "$GITHUB_KEY" | sed '/^$/d' | sed 's/^/                /')

      # 4. Tomcat EC2 SSH Key
      - basicSSHUserPrivateKey:
          id: "tomcat-ssh-key"
          scope: GLOBAL
          username: "ubuntu"
          description: "SSH Key to deploy to Tomcat EC2"
          privateKeySource:
            directEntry:
              privateKey: |
$(echo "$TOMCAT_SSH_KEY" | sed '/^$/d' | sed 's/^/                /')
EOF

# 9. Reload and Restart Jenkins
sudo systemctl daemon-reload
sudo chown -R jenkins:jenkins /var/lib/jenkins/plugins
sudo systemctl restart jenkins
sudo systemctl enable jenkins

# Pre-download OWASP NVD database
sudo mkdir -p /var/lib/jenkins/OWASP-NVD
sudo chown jenkins:jenkins /var/lib/jenkins/OWASP-NVD