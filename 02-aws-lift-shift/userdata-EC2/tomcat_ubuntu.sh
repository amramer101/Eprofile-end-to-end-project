#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install openjdk-17-jdk -y

sudo apt install tomcat10 tomcat10-admin tomcat10-docs tomcat10-common git -y

sudo snap install aws-cli --classic

sudo rm -rf /var/lib/tomcat10/webapps/ROOT

echo "Downloading Artifact from S3..."
aws s3 cp s3://s3-terraform-2026-java-artifacts1598/vprofile-v2.war /var/lib/tomcat10/webapps/ROOT.war

sudo systemctl start tomcat10
sudo systemctl enable tomcat10
sudo systemctl restart tomcat10