# VProfile Project - Local Setup Guide

## Overview
VProfile Project is a multi-tier web application consisting of several services working together. This guide explains how to set up the project locally using Vagrant and VirtualBox.

## Architecture

The project consists of 5 main services:

| Service | Role | Port |
|---------|------|------|
| **Nginx** | Web Server (Frontend) | 80 |
| **Tomcat** | Application Server | 8080 |
| **RabbitMQ** | Message Broker/Queue | 5672 |
| **Memcache** | Database Caching | 11211 |
| **MySQL** | SQL Database | 3306 |

---

## Prerequisites

Before starting, ensure you have the following tools installed:

### 1. Oracle VM VirtualBox
- Download and install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

### 2. Vagrant
- Download and install [Vagrant](https://www.vagrantup.com/downloads)

### 3. Vagrant Plugins
Install the hostmanager plugin:
```bash
vagrant plugin install vagrant-hostmanager
```

### 4. Git Bash
- For Windows: Install [Git Bash](https://git-scm.com/downloads)
- For Mac/Linux: Use standard Terminal

---

## Initial Setup Steps

### 1. Clone the Project
```bash
git clone https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project
```

### 2. Switch to Local Branch
```bash
git checkout local
```

### 3. Navigate to Vagrant Directory
```bash
cd vagrant/Manual_provisioning
```

### 4. Start Virtual Machines
```bash
vagrant up
```

> **Important Note:** 
> - Starting all VMs may take a long time (15-30 minutes)
> - If setup stops in the middle, run `vagrant up` again
> - `/etc/hosts` files will be automatically updated for all VMs

---

## Setup Order

⚠️ **Very Important:** Services must be set up in the following order:

1. **MySQL** (Database)
2. **Memcache** (Caching)
3. **RabbitMQ** (Message Broker)
4. **Tomcat** (Application Server)
5. **Nginx** (Web Server)

---

## 1️⃣ MySQL Database Setup

### SSH into the VM
```bash
vagrant ssh db01
```

### Verify Hosts File
```bash
cat /etc/hosts
```

### Update the System
```bash
sudo dnf update -y
```

### Install Repositories and Packages
```bash
sudo dnf install epel-release -y
sudo dnf install git mariadb-server -y
```

### Start and Enable MariaDB
```bash
sudo systemctl start mariadb
sudo systemctl enable mariadb
```

### Secure the Database
```bash
sudo mysql_secure_installation
```

**Security Settings:**
- Set root password: `Y` → Enter `admin123`
- Remove anonymous users: `Y`
- Disallow root login remotely: `n` (Important to allow connections from other services)
- Remove test database: `Y`
- Reload privilege tables: `Y`

### Create Database and Users
```bash
mysql -u root -padmin123
```

Inside MySQL:
```sql
CREATE DATABASE accounts;
GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'localhost' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%' IDENTIFIED BY 'admin123';
FLUSH PRIVILEGES;
EXIT;
```

### Import Initial Data
```bash
cd /tmp/
git clone -b local https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project
mysql -u root -padmin123 accounts < src/main/resources/db_backup.sql
```

### Verify Tables
```bash
mysql -u root -padmin123 accounts
```
```sql
SHOW TABLES;
EXIT;
```

### Configure Firewall
```bash
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
sudo firewall-cmd --reload
sudo systemctl restart mariadb
```

✅ **MySQL is now ready!**

---

## 2️⃣ Memcache Setup

### SSH into the VM
```bash
vagrant ssh mc01
```

### Verify Hosts and Update System
```bash
cat /etc/hosts
sudo dnf update -y
```

### Install Memcached
```bash
sudo dnf install epel-release -y
sudo dnf install memcached -y
```

### Start and Enable Memcached
```bash
sudo systemctl start memcached
sudo systemctl enable memcached
sudo systemctl status memcached
```

### Allow External Connections
```bash
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached
sudo systemctl restart memcached
```

### Configure Firewall
```bash
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --add-port=11211/tcp --permanent
sudo firewall-cmd --add-port=11111/udp --permanent
sudo firewall-cmd --reload
```

### Run Memcached on Specified Ports
```bash
sudo memcached -p 11211 -U 11111 -u memcached -d
```

✅ **Memcache is now ready!**

---

## 3️⃣ RabbitMQ Setup

### SSH into the VM
```bash
vagrant ssh rmq01
```

### Update and Setup
```bash
cat /etc/hosts
sudo dnf update -y
sudo dnf install epel-release -y
```

### Install RabbitMQ
```bash
sudo dnf install wget -y
sudo dnf -y install centos-release-rabbitmq-38
sudo dnf --enablerepo=centos-rabbitmq-38 -y install rabbitmq-server
sudo systemctl enable --now rabbitmq-server
```

### Configure User and Permissions
```bash
sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator
sudo rabbitmqctl set_permissions -p / test ".*" ".*" ".*"
sudo systemctl restart rabbitmq-server
```

### Configure Firewall
```bash
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --add-port=5672/tcp --permanent
sudo firewall-cmd --reload
sudo systemctl status rabbitmq-server
```

✅ **RabbitMQ is now ready!**

---

## 4️⃣ Tomcat Application Server Setup

### SSH into the VM
```bash
vagrant ssh app01
```

### Update and Setup
```bash
cat /etc/hosts
sudo dnf update -y
sudo dnf install epel-release -y
```

### Install Java
```bash
sudo dnf -y install java-17-openjdk java-17-openjdk-devel
sudo dnf install git wget -y
```

### Download and Install Tomcat
```bash
cd /tmp/
wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.26/bin/apache-tomcat-10.1.26.tar.gz
tar xzvf apache-tomcat-10.1.26.tar.gz
```

### Create Tomcat User
```bash
sudo useradd --home-dir /usr/local/tomcat --shell /sbin/nologin tomcat
```

### Copy Files and Set Permissions
```bash
sudo cp -r /tmp/apache-tomcat-10.1.26/* /usr/local/tomcat/
sudo chown -R tomcat.tomcat /usr/local/tomcat
```

### Create Systemd Service
```bash
sudo vi /etc/systemd/system/tomcat.service
```

Add the following content:
```ini
[Unit]
Description=Tomcat
After=network.target

[Service]
User=tomcat
Group=tomcat
WorkingDirectory=/usr/local/tomcat
Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_PID=/var/tomcat/%i/run/tomcat.pid
Environment=CATALINA_HOME=/usr/local/tomcat
Environment=CATALINA_BASE=/usr/local/tomcat
ExecStart=/usr/local/tomcat/bin/catalina.sh run
ExecStop=/usr/local/tomcat/bin/shutdown.sh
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
```

### Enable and Start Tomcat
```bash
sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl enable tomcat
```

### Configure Firewall
```bash
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
sudo firewall-cmd --reload
```

---

## 📦 Code Build & Deploy

### Install Maven
```bash
cd /tmp/
wget https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.zip
unzip apache-maven-3.9.9-bin.zip
sudo cp -r apache-maven-3.9.9 /usr/local/maven3.9
export MAVEN_OPTS="-Xmx512m"
```

### Clone Source Code
```bash
git clone -b local https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project
```

### Update Configuration File
```bash
vim src/main/resources/application.properties
```

**Make sure the settings point to the correct servers:**
- Database: `db01:3306`
- Memcache: `mc01:11211`
- RabbitMQ: `rmq01:5672`

### Build the Project
```bash
/usr/local/maven3.9/bin/mvn install
```

### Deploy the Application
```bash
sudo systemctl stop tomcat
sudo rm -rf /usr/local/tomcat/webapps/ROOT*
sudo cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
sudo chown tomcat.tomcat /usr/local/tomcat/webapps -R
sudo systemctl start tomcat
```

### Check Logs
```bash
tail -f /usr/local/tomcat/logs/catalina.out
```

✅ **Application is now ready!**

---

## 5️⃣ Nginx Web Server Setup

### SSH into the VM
```bash
vagrant ssh web01
sudo -i
```

### Update and Install
```bash
cat /etc/hosts
apt update && apt upgrade -y
apt install nginx -y
```

### Create Nginx Configuration File
```bash
vi /etc/nginx/sites-available/vproapp
```

Add the following content:
```nginx
upstream vproapp {
    server app01:8080;
}

server {
    listen 80;
    location / {
        proxy_pass http://vproapp;
    }
}
```

### Enable the Site
```bash
rm -rf /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp
```

### Restart Nginx
```bash
systemctl restart nginx
systemctl status nginx
```

✅ **Nginx is now ready!**

---

## 🧪 Testing the Application

### 1. Check All Services Status

**From db01:**
```bash
sudo systemctl status mariadb
```

**From mc01:**
```bash
sudo systemctl status memcached
```

**From rmq01:**
```bash
sudo systemctl status rabbitmq-server
```

**From app01:**
```bash
sudo systemctl status tomcat
```

**From web01:**
```bash
sudo systemctl status nginx
```

### 2. Test Connectivity Between Services

From app01:
```bash
# Test MySQL
mysql -h db01 -u admin -padmin123 accounts -e "SELECT 1;"

# Test Memcache
telnet mc01 11211

# Test RabbitMQ
telnet rmq01 5672
```

### 3. Access the Application in Browser

1. Get the IP address of web01:
```bash
vagrant ssh web01
ip addr show
```

2. Open your browser and navigate to:
```
http://<web01-ip>
```

Or use the hostname if configured in `/etc/hosts`:
```
http://web01
```

---

## 🔧 Useful Vagrant Commands

| Command | Description |
|---------|-------------|
| `vagrant up` | Start all VMs |
| `vagrant halt` | Stop all VMs |
| `vagrant destroy` | Delete all VMs |
| `vagrant ssh <vm-name>` | SSH into a specific VM |
| `vagrant status` | Show VMs status |
| `vagrant reload` | Restart VMs |
| `vagrant provision` | Run provisioning scripts |

### VM Names:
- `web01` - Nginx
- `app01` - Tomcat
- `rmq01` - RabbitMQ
- `mc01` - Memcache
- `db01` - MySQL

---

## ❗ Troubleshooting Common Issues

### Issue: Vagrant up stops in the middle
**Solution:**
```bash
vagrant destroy -f
vagrant up
```

### Issue: Cannot access the application
**Solution:**
1. Check Firewall on all VMs
2. Check status of all services
3. Review Tomcat logs:
```bash
vagrant ssh app01
sudo tail -f /usr/local/tomcat/logs/catalina.out
```

### Issue: Database connection error
**Solution:**
1. Verify MySQL is running on db01
2. Check `application.properties` file
3. Ensure Firewall allows port 3306

### Issue: Maven build fails
**Solution:**
```bash
# Clear Maven cache
rm -rf ~/.m2/repository

# Retry
/usr/local/maven3.9/bin/mvn clean install
```

### Issue: Nginx shows 502 Bad Gateway
**Solution:**
1. Verify Tomcat is running on app01
2. Check Nginx configuration:
```bash
nginx -t
```

---

## 📊 Default Connection Information

### MySQL
- **Host:** db01
- **Port:** 3306
- **Database:** accounts
- **Username:** admin
- **Password:** admin123

### RabbitMQ
- **Host:** rmq01
- **Port:** 5672
- **Username:** test
- **Password:** test

### Memcache
- **Host:** mc01
- **Port:** 11211 (TCP), 11111 (UDP)

### Tomcat
- **Host:** app01
- **Port:** 8080

### Nginx
- **Host:** web01
- **Port:** 80

---

## 📝 Important Notes

1. **Passwords:** In production environment, use strong and different passwords
2. **Resources:** Ensure your machine has sufficient memory (minimum 8GB RAM)
3. **Order:** Follow the setup order precisely to avoid issues
4. **Backup:** Keep a backup of data before running `vagrant destroy`

---

## 🎯 Next Steps

After completing the local setup, you can:
- Learn how to deploy the project on AWS
- Explore Docker/Kubernetes for deployment
- Add CI/CD pipeline using Jenkins
- Improve security and performance

---

## 📚 Additional Resources

- [Vagrant Documentation](https://www.vagrantup.com/docs)
- [VirtualBox Manual](https://www.virtualbox.org/manual/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Apache Tomcat Documentation](https://tomcat.apache.org/tomcat-10.1-doc/)
- [MySQL Documentation](https://dev.mysql.com/doc/)

---

## 🤝 Contributing

If you find any issues or have suggestions for improvement:
1. Open an Issue on GitHub
2. Submit a Pull Request
3. Share your experience with the community

---

**Made with ❤️ for DevOps learners**

*Last Updated: February 2026*
