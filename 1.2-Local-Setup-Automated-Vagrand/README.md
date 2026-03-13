# 🌋 Strata-Ops: The Inner Core

## Automated Provisioning - Evolution Begins

> *From manual mastery to automated efficiency. Same architecture, smarter execution.*

---

## 🎯 The Evolution

You've conquered **manual provisioning** - every command, every configuration, every connection understood by hand. Now, we **codify that knowledge** into automation.

**This is not about skipping steps. This is about scaling what you've learned.**

### What Changes?

| Manual | Automated |
|--------|-----------|
| SSH into each VM manually | Vagrant provisions automatically |
| Run commands one by one | Shell scripts execute entire setup |
| 45-60 minutes setup time | 10-15 minutes deployment |
| Error-prone repetition | Consistent, repeatable results |

### What Stays The Same?

✅ Same 5 services  
✅ Same architecture  
✅ Same configuration values  
✅ Same VM network (192.168.56.x)  

**The difference:** Scripts do the typing. You orchestrate the symphony.

---

## 🏗️ Architecture (Unchanged)

```
     User
       ↓
   Nginx (web01)
       ↓
   Tomcat (app01)
    ↙  ↓  ↘
MySQL Memcd RMQ
db01  mc01  rmq01
```

**Same 5-tier architecture. Automated deployment.**

---

## 🚀 The Power of Automation

### Vagrant Orchestration

```ruby
# Vagrantfile - The conductor of your infrastructure
Vagrant.configure("2") do |config|
  
  # Database VM
  config.vm.define "db01" do |db01|
    db01.vm.box = "centos/stream9"
    db01.vm.hostname = "db01"
    db01.vm.network "private_network", ip: "192.168.56.15"
    db01.vm.provision "shell", path: "mysql.sh"  # ← Magic happens here
  end
  
  # Repeat for mc01, rmq01, app01, web01...
end
```

### Automated Scripts

Each service gets a **dedicated provisioning script**:

```bash
01-local-setup/Automated-Setup/
├── Vagrantfile              # Orchestration
├── mysql.sh                 # Database setup
├── memcache.sh             # Cache setup
├── rabbitmq.sh             # Queue setup
├── tomcat_ubuntu.sh        # App server setup
├── nginx.sh                # Web server setup
└── application.properties  # Config (auto-applied)
```

---

## ⚡ Quick Start

### One Command to Rule Them All

```bash
# Clone repository
git clone https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project
git checkout local
cd vagrant/Automated_provisioning

# Launch everything
vagrant up
```

⏱️ **Deployment time:** 10-15 minutes  
🎯 **Result:** Fully functional 5-tier application  
🔄 **Reproducibility:** 100%

---

## 🔍 How Automation Works

### The Provisioning Flow

```
vagrant up
    ↓
Vagrant reads Vagrantfile
    ↓
Creates 5 VMs in parallel
    ↓
Runs provisioning scripts on each VM
    ↓
Scripts install & configure services
    ↓
Services start automatically
    ↓
Application ready
```

### Script Anatomy: MySQL Example

```bash
#!/bin/bash
# mysql.sh - Automated database setup

DATABASE_PASS='admin123'

# Update system
sudo yum update -y
sudo yum install mariadb-server -y

# Start database
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Secure installation (automated)
sudo mysqladmin -u root password "$DATABASE_PASS"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# Create database and users
sudo mysql -u root -p"$DATABASE_PASS" -e "CREATE DATABASE accounts"
sudo mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%' IDENTIFIED BY 'admin123'"

# Import schema (from Git)
git clone -b main https://github.com/hkhcoder/vprofile-project.git /tmp/vprofile-project
sudo mysql -u root -p"$DATABASE_PASS" accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql

# Configure firewall
sudo firewall-cmd --add-port=3306/tcp --permanent
sudo firewall-cmd --reload
sudo systemctl restart mariadb
```

**Every manual command = One line in the script**

---

## 📋 Service-by-Service Breakdown

### 1️⃣ MySQL (db01)

**Script:** `mysql.sh`  
**What it automates:**
- ✅ MariaDB installation
- ✅ Root password configuration
- ✅ Database creation
- ✅ User privileges
- ✅ Schema import
- ✅ Firewall configuration

**Manual equivalent:** 15-20 commands, 5-7 minutes

### 2️⃣ Memcached (mc01)

**Script:** `memcache.sh`  
**What it automates:**
- ✅ Memcached installation
- ✅ Service startup
- ✅ External connection configuration
- ✅ Firewall rules (TCP 11211, UDP 11111)

**Manual equivalent:** 8-10 commands, 3-4 minutes

### 3️⃣ RabbitMQ (rmq01)

**Script:** `rabbitmq.sh`  
**What it automates:**
- ✅ RabbitMQ installation
- ✅ Service enablement
- ✅ User creation (test/test)
- ✅ Administrator permissions
- ✅ Firewall configuration

**Manual equivalent:** 10-12 commands, 4-5 minutes

### 4️⃣ Tomcat (app01)

**Script:** `tomcat_ubuntu.sh`  
**What it automates:**
- ✅ Java 8 installation
- ✅ Tomcat 8 installation
- ✅ Service configuration
- ✅ Git setup (for source cloning)

**Note:** Application build/deploy typically done separately or via CI/CD

**Manual equivalent:** 6-8 commands, 3-4 minutes

### 5️⃣ Nginx (web01)

**Script:** `nginx.sh`  
**What it automates:**
- ✅ Nginx installation
- ✅ Reverse proxy configuration
- ✅ Virtual host setup
- ✅ Service restart

**Manual equivalent:** 7-9 commands, 3-4 minutes

---

## 🎯 Configuration Management

### Centralized Configuration

**File:** `application.properties`

```properties
# Database
jdbc.url=jdbc:mysql://db01:3306/accounts
jdbc.username=admin
jdbc.password=admin123

# Memcached
memcached.active.host=mc01
memcached.active.port=11211

# RabbitMQ
rabbitmq.address=rmq01
rabbitmq.port=5672
rabbitmq.username=test
rabbitmq.password=test
```

**Key insight:** All service endpoints use **hostnames** (db01, mc01), not IP addresses.  
**Why?** Vagrant's hostmanager plugin manages /etc/hosts automatically.

---

## ✅ Verification

### Automated Testing

```bash
# Check all VMs are running
vagrant status

# Expected output:
# db01    running (virtualbox)
# mc01    running (virtualbox)
# rmq01   running (virtualbox)
# app01   running (virtualbox)
# web01   running (virtualbox)
```

### Service Verification

```bash
# Test database
vagrant ssh db01 -c "sudo systemctl status mariadb"

# Test cache
vagrant ssh mc01 -c "sudo systemctl status memcached"

# Test queue
vagrant ssh rmq01 -c "sudo systemctl status rabbitmq-server"

# Test app server
vagrant ssh app01 -c "sudo systemctl status tomcat8"

# Test web server
vagrant ssh web01 -c "sudo systemctl status nginx"
```

### Application Testing

```bash
# Get web01 IP
vagrant ssh web01 -c "hostname -I"

# Open in browser
http://192.168.56.11

# Login: admin_vp / admin_vp
```

---

## 🔧 Useful Commands

### VM Management

```bash
# Start all VMs
vagrant up

# Start specific VM
vagrant up db01

# Stop all VMs
vagrant halt

# Restart all VMs
vagrant reload

# Destroy and recreate
vagrant destroy -f && vagrant up

# SSH into VM
vagrant ssh web01
```

### Troubleshooting

```bash
# Re-run provisioning scripts
vagrant provision

# Re-provision specific VM
vagrant provision db01

# Check VM status
vagrant status

# View Vagrant logs
vagrant up --debug
```

---

## 🎓 What You Learn Here

### Automation Principles

- ✅ **Idempotency**: Scripts can run multiple times safely
- ✅ **Error handling**: Scripts exit on failures
- ✅ **Repeatability**: Same input = same output, always
- ✅ **Version control**: Infrastructure as code

### Shell Scripting Skills

- ✅ Bash scripting fundamentals
- ✅ Package management (yum/dnf/apt)
- ✅ Service management (systemctl)
- ✅ Firewall configuration
- ✅ File manipulation (sed, cat, grep)

### Infrastructure as Code

- ✅ Vagrant configuration (Ruby DSL)
- ✅ VM provisioning
- ✅ Network configuration
- ✅ Resource management

---

## 📊 Comparison: Manual vs Automated

| Metric | Manual | Automated |
|--------|--------|-----------|
| **Setup time** | 45-60 min | 10-15 min |
| **Error rate** | Medium-High | Very Low |
| **Repeatability** | Hard | Perfect |
| **Learning curve** | Steep | Moderate |
| **Troubleshooting** | Essential skill | Script debugging |
| **Scalability** | Linear effort | Near constant |
| **Documentation** | Required | Self-documenting |

---

## 🚨 Common Issues

### Issue: Script fails midway
**Solution:** Vagrant provisions in order. If one fails, subsequent scripts may not run.

```bash
# Check logs
vagrant up db01 2>&1 | tee provision.log

# Re-provision failed VM
vagrant provision db01
```

### Issue: Service not reachable
**Solution:** Verify firewall rules in script

```bash
vagrant ssh db01
sudo firewall-cmd --list-all
```

### Issue: /etc/hosts not updated
**Solution:** Hostmanager plugin issue

```bash
# Reinstall plugin
vagrant plugin uninstall vagrant-hostmanager
vagrant plugin install vagrant-hostmanager

# Reload
vagrant reload
```

---

## 🎯 Next Layer: The Mantle

From local automation, we ascend to the cloud. The **AWS Lift & Shift** layer awaits, where we migrate this exact architecture to production-grade infrastructure.

**Same application. Cloud scale.**

---

## 💡 Pro Tips

**For learning:**
- 📝 Read every script before running `vagrant up`
- 🔍 SSH into VMs during provisioning to watch real-time
- 🧪 Intentionally break scripts to understand error handling
- 📊 Time each service to identify bottlenecks

**For production:**
- 🔐 Change all default passwords
- 🌐 Use environment variables for secrets
- 📦 Version control your Vagrantfile
- 🧹 Add cleanup scripts for teardown

---

## 📁 Files Reference

```bash
Automated-Setup/
├── Vagrantfile                 # VM definitions
├── mysql.sh                    # DB provisioning
├── memcache.sh                 # Cache provisioning
├── rabbitmq.sh                 # Queue provisioning
├── tomcat_ubuntu.sh            # App provisioning
├── nginx.sh                    # Web provisioning
└── application.properties      # App configuration
```

---

## 🔄 The Journey So Far

```
Inner Core - Manual Setup
    ↓
Inner Core - Automated Setup  ← YOU ARE HERE
    ↓
The Mantle - AWS Lift & Shift
    ↓
The Outer Core - Containerization
    ↓
The Crust - Cloud Native
```

**Each layer builds on the last. Each leap requires mastery of the previous.**

---

<div align="center">

**⚡ Automation is not magic. It's captured mastery.**

*Made with evolution for DevOps architects*

</div>