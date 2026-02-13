# 🌋 Strata-Ops: The Mantle

## AWS Cloud-Native PaaS - Managed Services Evolution

> *From managing infrastructure to leveraging platforms. Same application, zero server management.*

<div align="center">

[![Terraform](https://img.shields.io/badge/Terraform-1.14.0-623CE4?style=for-the-badge&logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-PaaS-FF9900?style=for-the-badge&logo=amazon-aws)](https://aws.amazon.com/)
[![CI/CD](https://img.shields.io/badge/CI/CD-Automated-00C853?style=for-the-badge)]()

</div>

---

## 🎯 The Transformation

You've conquered EC2 instances in the Outer Core. Now we **evolve beyond servers** - eliminating the need to manage, patch, or scale VMs manually. This is **Platform as a Service (PaaS)**: AWS manages infrastructure, you focus on code.

**This is Cloud-Native:** Managed services, automated deployments, infrastructure that scales itself.

### The Evolution Path

```
Inner Core (Manual)          → Local VMs, manual setup
Inner Core (Automated)       → Shell scripts, Vagrant
Outer Core (Lift & Shift)    → EC2, manual scaling, SSH access
The Mantle (Cloud-Native)    → PaaS, auto-scaling, CI/CD    ← YOU ARE HERE
The Crust (Containerized)    → Docker, Kubernetes, serverless
```

### What Changes?

| Outer Core (IaaS) | The Mantle (PaaS) |
|-------------------|-------------------|
| EC2 instances (manual management) | Elastic Beanstalk (auto-managed) |
| Manual artifact deployment via S3 | CI/CD pipeline (CodePipeline) |
| Self-managed MySQL on EC2 | RDS (managed database) |
| Self-managed Memcached | ElastiCache (managed caching) |
| Self-managed RabbitMQ | Amazon MQ (managed messaging) |
| Manual scaling via ASG | Automatic scaling built-in |
| Manual deployments | Git push → Auto deploy |

### What Stays The Same?

✅ Same Java application code  
✅ Same 5-tier architecture  
✅ Same VPC network design  
✅ Same security group patterns  

**The difference:** AWS manages servers. You manage code.

---

## 🏗️ Cloud-Native Architecture

![Cloud-Native Architecture](media/architecture.png)

### The Managed Services Stack

```
┌─────────────────────────────────────────┐
│       Elastic Beanstalk (PaaS)          │
│   ┌───────────────────────────────┐     │
│   │  Load Balancer (Auto-created) │     │
│   └───────────────┬───────────────┘     │
│                   ↓                      │
│   ┌───────────────────────────────┐     │
│   │ EC2 Auto Scaling Group        │     │
│   │ (Managed by Beanstalk)        │     │
│   │ - Auto-scales 1-2 instances   │     │
│   │ - Auto-deploys from pipeline  │     │
│   └───────────────┬───────────────┘     │
└───────────────────┼───────────────────┘
                    ↓
        ┌───────────────────────┐
        │   Managed Services    │
        ├───────────────────────┤
        │ RDS MySQL             │ → Automated backups
        │ ElastiCache Memcached │ → Automatic failover
        │ Amazon MQ RabbitMQ    │ → Managed broker
        └───────────────────────┘
```

### Terraform Automation Scope

![Terraform Resource Map](media/terraform-1.png)

**67 resources created in one command:**
- VPC & networking (15 resources)
- Elastic Beanstalk environment + app (2 resources)
- RDS database (2 resources)
- ElastiCache cluster (2 resources)
- Amazon MQ broker (1 resource)
- IAM roles & policies (8 resources)
- Security groups (4 resources)
- CI/CD pipeline (4 resources)
- Load balancer + Auto Scaling (auto-created by Beanstalk)

---

## 🚀 CI/CD Pipeline: The Game Changer

### Before (Outer Core)
```bash
# Build locally
mvn clean package

# Upload to S3
aws s3 cp target/app.war s3://bucket/

# SSH into each server
ssh ec2-user@server
sudo systemctl restart tomcat
```

**Time:** 30-45 minutes  
**Error prone:** High  
**Scalability:** Manual

### After (The Mantle)
```bash
# Make code change
vim src/main/java/MyClass.java

# Commit and push
git add .
git commit -m "Feature: add new endpoint"
git push origin main
```

**Time:** 5-10 minutes (fully automated)  
**Error prone:** Low (consistent builds)  
**Scalability:** Automatic

![CI/CD Pipeline](media/04-cicd-pipeline-build.png)

### Pipeline Stages

```
┌──────────────────────────────────────────────────┐
│                 CodePipeline                     │
├──────────────────────────────────────────────────┤
│                                                  │
│  1️⃣ SOURCE (GitHub)                              │
│     ↓                                            │
│     Trigger: Push to main branch                │
│     Filter: 03-aws-cloud-native/src/**          │
│                                                  │
│  2️⃣ BUILD (CodeBuild)                            │
│     ↓                                            │
│     • mvn clean package                         │
│     • Run tests                                 │
│     • Create WAR file                           │
│                                                  │
│  3️⃣ DEPLOY (Elastic Beanstalk)                   │
│     ↓                                            │
│     • Upload WAR to Beanstalk                   │
│     • Rolling deployment (zero downtime)        │
│     • Health check validation                   │
│                                                  │
│  ✅ LIVE                                          │
└──────────────────────────────────────────────────┘
```

**Key Innovation:** Pipeline only triggers on changes to `03-aws-cloud-native/src/**`  
**Why?** Multiple projects in one repo - surgical deployments

---

## 📊 Infrastructure Dependency Graph

![Terraform Dependencies](media/relations.png)

### Resource Creation Order

Terraform automatically resolves dependencies:

```
1. VPC + Subnets
   ↓
2. Security Groups
   ↓
3. RDS Subnet Group → RDS Instance
   ElastiCache Subnet Group → ElastiCache Cluster
   ↓
4. Amazon MQ Broker
   ↓
5. Bastion Host (initializes RDS)
   ↓
6. IAM Roles → Instance Profiles
   ↓
7. Elastic Beanstalk App → Environment
   ↓
8. CodePipeline + CodeBuild
   ↓
9. Auto-deploy on first run
```

**Total deployment time:** ~12 minutes

---

## 💡 Key Innovations

### 1. **Environment Variable Injection**

**No hardcoded configs. Everything passed via environment variables.**

```hcl
# Terraform automatically injects into Beanstalk
setting {
  namespace = "aws:elasticbeanstalk:application:environment"
  name      = "RDS_HOSTNAME"
  value     = aws_db_instance.RDS.address
}
```

```properties
# Application reads from environment
jdbc.url=jdbc:mysql://${RDS_HOSTNAME}:3306/${RDS_DB_NAME}
jdbc.username=${RDS_USERNAME}
jdbc.password=${RDS_PASSWORD}

memcached.active.host=${MEMCACHED_HOSTNAME}
rabbitmq.address=${RABBITMQ_HOSTNAME}
```

**Benefits:**
- ✅ Zero configuration in code
- ✅ Same code works in dev/staging/prod
- ✅ Secrets managed securely
- ✅ Easy to rotate credentials

### 2. **Bastion-Driven Database Initialization**

![RDS Provisioned](media/03-aws-rds-provisioned.jpg)

**Problem:** RDS starts empty. Application needs schema + seed data.

**Solution:** Bastion host runs initialization script:

```bash
# Terraform user_data on bastion
#!/bin/bash
# Wait for RDS to be ready
# Clone repo → Get db_backup.sql
# mysql -h $RDS_ENDPOINT < db_backup.sql
```

**Flow:**
1. Terraform creates RDS + Bastion
2. Bastion boots → Runs init script
3. Script imports schema + users
4. Beanstalk app connects to pre-loaded DB

**Terraform output verification:**

```
bastion_ip       = "18.197.1.176"
rds_endpoint     = "terraform-20260213162019875900000004.c7g1q8ucqo75.eu-central-1.rds.amazonaws.com"
elasticache_endpoint = "elasticache.ugm0kh.cfg.euc1.cache.amazonaws.com:11211"
mq_endpoint      = ["amqps://b-41185c5a-f07d-44c0-9868-4313c2de59c0.mq.eu-central-1.on.aws:5671"]
```

### 3. **Rolling Deployments (Zero Downtime)**

![Beanstalk Environment Healthy](media/05-beanstalk-environment-green.png)

**Elastic Beanstalk deployment strategy:**
```
Old Version (v1.0) running on 2 instances
              ↓
Deploy v1.1 to instance 1 → Health check → Success
              ↓
Traffic shifts to instance 1
              ↓
Deploy v1.1 to instance 2 → Health check → Success
              ↓
Both instances on v1.1 → Old version terminated
```

**Green = Healthy environment, all checks passed**

**Status indicators:**
- ✅ Environment health: OK
- ✅ Platform: Tomcat 10 with Corretto 21
- ✅ Running version: Latest from pipeline
- ✅ Connections: 1 active

---

## ✅ Verification: End-to-End Success

### 1. Terraform Deployment Success

![Terraform Apply Success](media/01-terraform-apply-success.png)

**Outputs prove infrastructure is live:**
```
bastion_ip = "18.197.1.176"
beanstalk_env_url = "awseb-e-s-AWSEBLoa-SV9M41I0Q6QN-2036248934.eu-central-1.elb.amazonaws.com"
rds_endpoint = "terraform-2026021316201987590000004.c7g1q8ucqo75.eu-central-1.rds.amazonaws.com"
elasticache_endpoint = "elasticache.ugm0kh.cfg.euc1.cache.amazonaws.com:11211"
mq_endpoint = ["amqps://b-41185c5a-f07d-44c0-9868-4313c2de59c0.mq.eu-central-1.on.aws:5671"]
```

**All 5 managed services confirmed operational.**

### 2. Database Connection Working

![Data from Database](media/07-app-dashboard-data-insert.png)

**Message:** "Data is From DB and Data Inserted In Cache !!"

✅ RDS connection established  
✅ SQL queries executing  
✅ User data retrieved  
✅ Cache write successful

**User Details Retrieved:**
```
ID: 7
Name: admin_vp
Email: admin@hkhinfo.com
```

### 3. Cache Hit Verified

![Data from Cache](media/07-app-dashboard-cache.png)

**Message:** "[Data is From Cache]" (red badge)

✅ ElastiCache serving cached data  
✅ Database query skipped (performance win)  
✅ Cache invalidation working  

**Same user, instant retrieval from Memcached.**

### 4. Backend Services Connectivity

![ElastiCache Working](media/08-backend-cache-services-verification.png)

**ElastiCache Details:**
- Cluster ID: `elasticache`
- Engine: Memcached 1.6.22
- Node type: cache.t3.micro
- Status: ✅ Available
- Configuration endpoint: Active

![Amazon MQ Working](media/08-backend-mq-services-verification.png)

**Amazon MQ Details:**
- Broker name: `example`
- Engine: RabbitMQ 3.13.7
- Instance type: mq.t3.micro
- Status: ✅ Running
- Deployment: Single-instance broker

**All backend services healthy and connected.**

---

## 📋 Quick Start

### Prerequisites

```bash
# Install required tools
terraform --version  # >= 1.14.0
aws --version        # >= 2.0
git --version
```

### Deploy in 3 Commands

```bash
# 1. Configure AWS credentials
aws configure

# 2. Initialize Terraform
cd 03-aws-cloud-native/terraform
terraform init

# 3. Deploy everything
terraform apply -auto-approve
```

**Wait:** ~12 minutes

**Access application:**
```bash
# Get Beanstalk URL
terraform output beanstalk_env_url

# Open in browser
http://awseb-e-s-AWSEBLoa-<YOUR-ID>.eu-central-1.elb.amazonaws.com
```

**Login:**
- Username: `admin_vp`
- Password: `admin_vp`

### Trigger CI/CD Pipeline

```bash
# Make any code change
cd 03-aws-cloud-native/src
vim main/java/com/visualpathit/account/controller/MyController.java

# Commit and push
git add .
git commit -m "Update: new feature"
git push origin main
```

**Pipeline auto-triggers → Builds → Deploys in ~5 minutes**

### Destroy

```bash
terraform destroy -auto-approve
```

**All resources deleted. Zero orphaned services.**

---

## 🎓 What You Learn Here

### PaaS Principles

- ✅ **Managed infrastructure:** No server patching/updates
- ✅ **Auto-scaling:** Traffic spikes handled automatically
- ✅ **Rolling deployments:** Zero downtime releases
- ✅ **Health monitoring:** Auto-recovery from failures

### CI/CD Mastery

- ✅ **Source control integration:** Git as deployment trigger
- ✅ **Automated builds:** CodeBuild pipelines
- ✅ **Deployment automation:** Push-to-production workflows
- ✅ **Pipeline as code:** Terraform manages CI/CD

### AWS Managed Services

- ✅ **RDS:** Multi-AZ, automated backups, point-in-time recovery
- ✅ **ElastiCache:** Managed Memcached, auto-failover
- ✅ **Amazon MQ:** RabbitMQ without broker management
- ✅ **Elastic Beanstalk:** Full application platform

### Advanced Terraform

- ✅ **Complex dependencies:** 67-resource orchestration
- ✅ **User data templates:** Dynamic script generation
- ✅ **Environment variables:** Secure config injection
- ✅ **Output chaining:** Resources reference each other

---

## 🔧 Common Issues

### Issue: Pipeline not triggering

**Symptom:** Code pushed but pipeline doesn't run

**Solution:** Check file path filter
```hcl
# Pipeline only watches this path
file_paths {
  includes = ["03-aws-cloud-native/src/.*"]
}
```

If you changed files outside this path, pipeline won't trigger.

### Issue: Beanstalk deployment fails

**Symptom:** Environment turns red after deployment

**Solution:** Check logs
```bash
# Via AWS CLI
aws elasticbeanstalk describe-events \
  --environment-name elbeanstalkenv \
  --max-items 50
```

Common causes:
- Java version mismatch (use Corretto 21)
- Missing environment variables
- Database connection timeout

### Issue: RDS connection refused

**Symptom:** Application can't connect to database

**Solution:** Verify security group
```bash
# Check Data-SG allows Tomcat-SG on port 3306
aws ec2 describe-security-groups \
  --group-ids sg-xxxxx
```

Verify bastion initialized database:
```bash
ssh -i bean-stack-key ubuntu@$(terraform output -raw bastion_ip)
mysql -h $RDS_ENDPOINT -u admin -padmin123 accounts -e "SHOW TABLES;"
```

---

## 📊 Cost Comparison

### The Mantle (Current)

| Service | Type | Monthly Cost |
|---------|------|--------------|
| Elastic Beanstalk | 2x t3.micro instances | $14.60 |
| Load Balancer | Application LB | $16.20 |
| RDS MySQL | db.t3.micro | $15.33 |
| ElastiCache | cache.t3.micro | $12.41 |
| Amazon MQ | mq.t3.micro | $74.88 |
| NAT Gateway | 1x NAT | $32.40 |
| Data Transfer | ~50GB | $4.50 |
| **Total** | | **~$170/month** |

### Outer Core (Previous)

| Service | Type | Monthly Cost |
|---------|------|--------------|
| EC2 | 5x t2.micro | $36.50 |
| NAT Gateway | 1x NAT | $32.40 |
| S3 | 1GB | $0.03 |
| Route53 | 1 zone | $0.50 |
| **Total** | | **~$70/month** |

**Cost increase:** +$100/month  
**Value gained:**
- Automated scaling
- Managed databases (no maintenance)
- CI/CD pipeline
- Zero downtime deployments
- Automated backups
- 99.95% SLA on managed services

**Break-even:** 1-2 hours/month of manual operations saved = ROI positive

---

## 🎯 Next Layer: The Crust

From PaaS to **containers and orchestration**. The final evolution where we package this application into Docker containers and deploy with Kubernetes or ECS.

**Same app. Portable across any cloud. True cloud-agnostic architecture.**

---

## 💡 Pro Tips

**Cost Optimization:**
- 🕐 Use dev environment schedulers (turn off nights/weekends)
- 💾 RDS: Use single-AZ for non-prod
- 📊 Review CloudWatch metrics for right-sizing

**Performance Tuning:**
- ⚡ Enable ElastiCache cluster mode for scaling
- 🔀 Use ALB path-based routing for microservices
- 📈 Configure auto-scaling policies based on CPU/requests

**Security Hardening:**
- 🔐 Rotate RDS passwords via Secrets Manager
- 🛡️ Enable RDS encryption at rest
- 📝 Use IAM database authentication
- 🚨 Enable CloudTrail for audit logs

**Operational Excellence:**
- 📊 Set up CloudWatch alarms for critical metrics
- 🔔 Configure SNS topics for deployment notifications
- 💾 Test RDS restore procedures quarterly
- 📖 Document runbooks for common issues

---

## 📁 Project Structure

```
03-aws-cloud-native/
├── media/                              # Architecture diagrams
│   ├── architecture.png               # Managed services diagram
│   ├── relations.png                  # Terraform dependency graph
│   ├── terraform-1.png                # Resource creation plan
│   ├── 01-terraform-apply-success.png # Deployment outputs
│   ├── 03-aws-rds-provisioned.jpg    # RDS database details
│   ├── 04-cicd-pipeline-build.png    # Pipeline visualization
│   ├── 05-beanstalk-environment-green.png # Healthy environment
│   ├── 07-app-dashboard-cache.png    # Cache verification
│   ├── 07-app-dashboard-data-insert.png # DB verification
│   ├── 08-backend-cache-services-verification.png
│   └── 08-backend-mq-services-verification.png
│
├── terraform/
│   ├── providers.tf                  # AWS provider config
│   ├── backend-state.tf              # S3 backend (remote state)
│   ├── variables.tf                  # Input variables
│   ├── output.tf                     # Output values
│   ├── vpc.tf                        # VPC module
│   ├── secgrp.tf                     # Security groups
│   ├── Data-services.tf              # RDS, ElastiCache, MQ
│   ├── bastion.tf                    # Bastion host + DB init
│   ├── bean-app.tf                   # Beanstalk application
│   ├── bean-env.tf                   # Beanstalk environment
│   ├── iam-bean.tf                   # Beanstalk IAM roles
│   ├── iam-cicd.tf                   # Pipeline IAM roles
│   ├── code-build.tf                 # CodeBuild + CodePipeline
│   ├── keypairs.tf                   # SSH keys
│   └── templates/
│       └── bastion-init.sh           # Database initialization
│
├── src/                               # Java application source
│   └── main/
│       ├── java/                     # Application code
│       └── resources/
│           └── application.properties # Config with env vars
│
├── buildspec.yml                      # CodeBuild instructions
└── README.md                          # This file
```

---

## 🔄 The Journey So Far

```
✅ Inner Core - Manual Setup
    ↓
✅ Inner Core - Automated Setup
    ↓
✅ Outer Core - AWS Lift & Shift
    ↓
✅ The Mantle - Cloud-Native PaaS    ← YOU ARE HERE
    ↓
⬜ The Crust - Containerization
```

**Each layer abstracts complexity. Each leap increases velocity.**

---

## 🌟 The Transformation Summary

### Before (Outer Core)
- Manual server management
- SSH-based deployments
- Self-managed databases
- Manual scaling
- Deployment time: 30-45 minutes

### After (The Mantle)
- Zero server management
- Git-based deployments
- Managed databases with auto-backups
- Automatic scaling
- Deployment time: 5-10 minutes

**Same application. Less ops work. More time for features.**

---

<div align="center">

**🌋 The deeper you go, the hotter it gets. PaaS is pure power.**

*Made with managed services for DevOps engineers*

</div>
