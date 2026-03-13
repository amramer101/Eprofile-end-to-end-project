# 🌋 Strata-Ops: The Inner Core

## Manual Provisioning - Where It All Begins

> *Every great infrastructure starts from the core. This is where we build from first principles, understanding every service, every configuration, every connection.*

---

## 🎯 What Is The Inner Core?

The **Inner Core** represents the foundation of our journey - a multi-tier Java application deployed locally using **manual provisioning**. No automation, no shortcuts. Just you, the terminal, and a deep understanding of how each service fits together.

This phase teaches you:
- ✅ How services communicate
- ✅ The proper order of initialization
- ✅ Manual configuration and troubleshooting
- ✅ Foundation for automation (next layers)

---

## 🏗️ Architecture at a Glance

```
┌─────────────────────────────────────────────────┐
│           🌐 Nginx (web01)                      │
│           Frontend · Port 80                     │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│           ☕ Tomcat (app01)                      │
│           Application Server · Port 8080         │
└──┬───────────┬──────────────┬───────────────────┘
   │           │              │
   ▼           ▼              ▼
┌─────┐    ┌─────┐       ┌─────┐
│MySQL│    │Memcd│       │RMQ  │
│db01 │    │mc01 │       │rmq01│
│:3306│    │11211│       │:5672│
└─────┘    └─────┘       └─────┘
```

**5 Virtual Machines, 5 Services, Infinite Learning**

---

## 📦 The Services

| Service | VM Name | Purpose | Port |
|---------|---------|---------|------|
| **Nginx** | web01 | Reverse proxy, frontend gateway | 80 |
| **Tomcat** | app01 | Java application server | 8080 |
| **MySQL** | db01 | Relational database | 3306 |
| **Memcached** | mc01 | Caching layer | 11211 |
| **RabbitMQ** | rmq01 | Message queue | 5672 |

---

## ⚙️ Prerequisites

Before diving into the core, ensure you have:

```bash
# Required Tools
✓ Oracle VirtualBox 6.0+
✓ Vagrant 2.2+
✓ Git Bash (Windows) / Terminal (Mac/Linux)
✓ 8GB RAM minimum
✓ 20GB free disk space

# Install Vagrant Plugin
vagrant plugin install vagrant-hostmanager
```

---

## 🚀 The Manual Journey

### **The Golden Rule of Manual Provisioning**

> **Setup order matters.** Backend services first, frontend last.

### Setup Sequence

```
1️⃣ MySQL      (Database foundation)
      ↓
2️⃣ Memcached  (Caching layer)
      ↓
3️⃣ RabbitMQ   (Message broker)
      ↓
4️⃣ Tomcat     (Application server)
      ↓
5️⃣ Nginx      (Frontend gateway)
```

---

## 📝 Quick Start

### 1. Clone & Initialize

```bash
git clone https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project
git checkout local
cd vagrant/Manual_provisioning
vagrant up
```

⏱️ **Wait time:** 15-30 minutes for all VMs to boot

### 2. Setup Each Service

#### 🗄️ MySQL (db01)

```bash
vagrant ssh db01

# Install & configure
sudo dnf update -y
sudo dnf install mariadb-server -y
sudo systemctl start mariadb
sudo mysql_secure_installation  # Password: admin123

# Create database
mysql -u root -padmin123
CREATE DATABASE accounts;
GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%' IDENTIFIED BY 'admin123';
FLUSH PRIVILEGES;
EXIT;

# Import schema
git clone -b local https://github.com/hkhcoder/vprofile-project.git
mysql -u root -padmin123 accounts < vprofile-project/src/main/resources/db_backup.sql

# Open firewall
sudo firewall-cmd --add-port=3306/tcp --permanent
sudo firewall-cmd --reload
```

#### 💾 Memcached (mc01)

```bash
vagrant ssh mc01

sudo dnf install memcached -y
sudo systemctl start memcached

# Allow external connections
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached
sudo systemctl restart memcached

# Configure firewall
sudo firewall-cmd --add-port=11211/tcp --permanent
sudo firewall-cmd --reload
```

#### 🐰 RabbitMQ (rmq01)

```bash
vagrant ssh rmq01

sudo dnf install rabbitmq-server -y
sudo systemctl enable --now rabbitmq-server

# Configure user
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator
sudo rabbitmqctl set_permissions -p / test ".*" ".*" ".*"

# Open firewall
sudo firewall-cmd --add-port=5672/tcp --permanent
sudo firewall-cmd --reload
```

#### ☕ Tomcat (app01)

```bash
vagrant ssh app01

# Install Java & Tomcat
sudo dnf install java-17-openjdk-devel -y
wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.26/bin/apache-tomcat-10.1.26.tar.gz
tar xzvf apache-tomcat-10.1.26.tar.gz
sudo cp -r apache-tomcat-10.1.26/* /usr/local/tomcat/

# Build application
cd /tmp
git clone -b local https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project
/usr/local/maven3.9/bin/mvn install

# Deploy
sudo cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
sudo systemctl start tomcat
```

#### 🌐 Nginx (web01)

```bash
vagrant ssh web01

sudo apt install nginx -y

# Configure reverse proxy
cat <<EOF | sudo tee /etc/nginx/sites-available/vproapp
upstream vproapp {
    server app01:8080;
}
server {
    listen 80;
    location / {
        proxy_pass http://vproapp;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo systemctl restart nginx
```

---

## ✅ Verification

### Test All Services

```bash
# From host machine
vagrant ssh web01 -c "ip addr show"  # Get web01 IP

# Open browser
http://<web01-ip>

# Login credentials
Username: admin_vp
Password: admin_vp
```

### Expected Results

✅ Login page loads  
✅ Database connection successful  
✅ Data cached in Memcached  
✅ RabbitMQ processes messages  

---

## 🔧 Configuration Details

### Database Connection

```properties
# src/main/resources/application.properties
jdbc.url=jdbc:mysql://db01:3306/accounts
jdbc.username=admin
jdbc.password=admin123
```

### Service Discovery

All services communicate via **hostname resolution** managed by Vagrant's hostmanager plugin:

```
192.168.56.15  →  db01
192.168.56.14  →  mc01
192.168.56.16  →  rmq01
192.168.56.12  →  app01
192.168.56.11  →  web01
```

---

## 🎓 What You Learn Here

### Technical Skills
- ✅ Manual service installation and configuration
- ✅ Multi-tier application architecture
- ✅ Network configuration and firewall rules
- ✅ Database initialization and schema management
- ✅ Reverse proxy configuration

### DevOps Principles
- ✅ **Order matters**: Dependencies drive sequence
- ✅ **Configuration management**: Every setting has a purpose
- ✅ **Troubleshooting**: When automation fails, manual skills save you
- ✅ **Foundation for automation**: Understanding manual process is essential

---

## 🚨 Common Issues

### Issue: Cannot connect to database
**Solution:** Check firewall rules and verify MySQL is listening on 0.0.0.0

```bash
sudo firewall-cmd --list-all
sudo netstat -tulpn | grep 3306
```

### Issue: Nginx 502 Bad Gateway
**Solution:** Verify Tomcat is running and accessible

```bash
vagrant ssh app01
sudo systemctl status tomcat
curl localhost:8080
```

### Issue: Vagrant up hangs
**Solution:** Destroy and restart

```bash
vagrant destroy -f
vagrant up
```

---

## 🎯 Next Layer: The Outer Core

Once you've mastered manual provisioning, you're ready for **automated provisioning** where shell scripts eliminate repetitive tasks while maintaining full control.

The journey continues upward through the strata...

---

## 💡 Pro Tips

- **Take screenshots** at each step - documentation is power
- **Understand before automating** - automation of confusion creates automated confusion
- **Break things intentionally** - controlled failures teach troubleshooting
- **Time each service** - know where bottlenecks exist

---

## 📚 Resources

- [Vagrant Documentation](https://www.vagrantup.com/docs)
- [VirtualBox Manual](https://www.virtualbox.org/manual/)
- [MySQL Documentation](https://dev.mysql.com/doc/)
- [Nginx Configuration Guide](https://nginx.org/en/docs/)

---

<div align="center">

**🌋 From the Inner Core, we build upward**

*Made with depth for DevOps explorers*

</div>
