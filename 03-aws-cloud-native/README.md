# 🌋 Strata-Ops: Phase 3 — Cloud-Native & Enterprise DevSecOps

<div align="center">

[![AWS](https://img.shields.io/badge/AWS-Cloud--Native-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Terraform](https://img.shields.io/badge/Terraform-IaC-623CE4?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![DevSecOps](https://img.shields.io/badge/DevSecOps-Zero--Trust-DC143C?style=for-the-badge&logo=shield&logoColor=white)]()
[![SonarCloud](https://img.shields.io/badge/SonarCloud-SAST-F3702A?style=for-the-badge&logo=sonarcloud&logoColor=white)](https://sonarcloud.io/)
[![CodePipeline](https://img.shields.io/badge/CodePipeline-4--Stage-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)]()
[![Java](https://img.shields.io/badge/Java-Maven-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)]()

> *"Security is not a feature — it's a gate. In this phase, I made it architecturally impossible to deploy insecure code."*

**— Amr Medhat Amer, Cloud & DevSecOps Engineer**

</div>

---

## 🧠 What I Architected Here

In this phase, I built a **fully automated, enterprise-grade DevSecOps platform** on AWS — zero to production with a single `terraform apply`. This is not a simple CI/CD pipeline. This is a **Zero-Trust delivery system** where security is a hard gate enforced at every layer before a single byte reaches production.

The same Java application from Phase 2 now runs on a **fully managed, auto-scaling, self-healing PaaS** — with zero manual deployments, zero hardcoded credentials, and three independent security scanners standing between code and cloud.

---

## 🗺️ Project Mind Map

```
                        STRATA-OPS PHASE 3
                               │
          ┌────────────────────┼────────────────────┐
          │                    │                    │
    🏗️ IaC Layer         🔐 Security           ☁️ Platform
    (Terraform)          (Zero-Trust)          (AWS PaaS)
          │                    │                    │
    ┌─────┴────┐        ┌──────┴──────┐      ┌─────┴──────┐
    │67 Resources│      │ TruffleHog  │      │  Beanstalk │
    │Remote State│      │   tfsec     │      │  RDS MySQL │
    │S3 Backend  │      │ SonarCloud  │      │ElastiCache │
    │IAM Scoped  │      │SSM Secrets  │      │ Amazon MQ  │
    └────────────┘      └─────────────┘      └────────────┘
          │                    │                    │
    🚀 CI/CD                📦 Artifacts       🔭 Observability
    (CodePipeline V2)       (CodeArtifact)     (CloudWatch+SNS)
          │                    │                    │
    Source → Scan       Private Maven          CPU Alarms
    → Build → Deploy    Proxy Repo             Email Alerts
```

---

## 🏗️ Architecture

![Architecture Diagram](../media/cloud-native/architecture-diagram.png)

> **What you're seeing:** The complete system from `git push` to production. Terraform provisions everything. The pipeline runs through 4 security-enforced stages. The VPC contains all managed services in private subnets, accessible only through the load balancer. Every secret lives in SSM — never in code.

---

## 🌐 Network Design — VPC Resource Map

![Network Design](../media/cloud-native/Network-design.png)

> **Eprofile-VPC** (`10.0.0.0/16`) spans **3 Availability Zones** (eu-central-1a/b/c) with 6 subnets — 3 public, 3 private. Private subnets reach the internet only via NAT Gateway. All backend services (RDS, ElastiCache, Amazon MQ) live exclusively in private subnets, unreachable from the public internet.

---
> **📊 Architecture Overview (C4 Model):**
> The diagram above illustrates the complete cloud-native infrastructure and continuous delivery flow for **Strata-Ops (Phase 3)**. 

![Architecture](../media/cloud-native/System.png)


> **Key Architectural Highlights:**
> * **Zero-Trust CI/CD:** Fully automated pipeline via AWS CodePipeline with strict security gates (TruffleHog, tfsec, SonarCloud).
> * **Dynamic Secrets Injection:** Utilizing **AWS SSM Parameter Store** to inject database credentials at runtime, completely eliminating hardcoded secrets from the source code.
> * **Highly Available Compute:** Java application (ROOT.war) deployed on a scalable **AWS Elastic Beanstalk (Tomcat)** Auto Scaling Group across multiple Availability Zones.
> * **Isolated Data Layer:** Backend services (`RDS MySQL`, `ElastiCache Memcached`, `Amazon MQ`) are secured within private subnets, accessible only via strictly configured Security Groups.

---
## 🛡️ Security Architecture: Three Gates, Zero Compromise

```
git push
    │
    ▼
┌─────────────────────────────────────────────────────┐
│            SECURITY STAGE (CodeBuild)               │
│                                                     │
│  GATE 1: TruffleHog ──► 507 chunks scanned        │
│          verified_secrets: 0  ✅                    │
│                   │                                 │
│  GATE 2: tfsec ───► scans ./terraform/             │
│          HIGH findings identified + logged  ⚠️      │
│                   │                                 │
│  GATE 3: SonarCloud ──► 24k lines analyzed         │
│          Quality Gate result checked via API        │
│                                                     │
└─────────────────────────────────────────────────────┘
    │
    ▼
BUILD STAGE ──► DEPLOY STAGE
```

### Gate 1 — TruffleHog (Secrets Scanning)
```yaml
- trufflehog filesystem . --only-verified --fail
# 507 chunks scanned | 0 verified secrets | Gate passed ✅
```

### Gate 2 — tfsec (IaC Security Scanning)
```yaml
- tfsec ./03-aws-cloud-native/terraform --soft-fail
# Findings: RDS encryption, SNS encryption → logged for next iteration
```

### Gate 3 — SonarCloud (SAST)
```yaml
- mvn test checkstyle:checkstyle sonar:sonar -Dsonar.login=$LOGIN
- curl https://sonarcloud.io/api/qualitygates/project_status?projectKey=$Project > result.json
```

---

## 🔑 Secrets Management: SSM Parameter Store

**Zero hardcoded credentials anywhere in this codebase.**

![SSM Parameter Store](../media/cloud-native/aws-ssm-secrets.png)

> **5 parameters auto-provisioned by Terraform on `terraform apply`:**
> - `/strata-ops/mysql-password` → **SecureString** (auto-generated, KMS-encrypted)
> - `/strata-ops/rabbitmq-password` → **SecureString** (auto-generated)
> - `/strata-ops/sonar-token` → **SecureString** (injected at pipeline runtime only)
> - `/strata-ops/sonar-org` → String
> - `/strata-ops/sonar-project` → String
>
> Even if this repository were fully public, there is nothing sensitive to steal.

```hcl
resource "random_password" "db_password" { length = 8 }

resource "aws_ssm_parameter" "mysql_password" {
  name  = "/strata-ops/mysql-password"
  type  = "SecureString"   # KMS encrypted at rest
  value = random_password.db_password.result
}
```

---

## 📦 CodeArtifact — Private Maven Proxy

![CodeArtifact Repository](../media/cloud-native/Code-Artifact.png)

> **`vprofile-repo`** proxies Maven Central. Packages are cached on first pull — subsequent builds are faster and independent of Maven Central availability. The build authenticates using a short-lived IAM token, never stored credentials.

```yaml
- export CODEARTIFACT_AUTH_TOKEN=`aws codeartifact get-authorization-token \
    --domain vprofile-domain --query authorizationToken --output text`
```

---

## 🚀 Pipeline: All 4 Stages Succeeded

![CodePipeline Success](../media/cloud-native/codepipeline-success.png)

> **`vprofile-pipeline` (V2)** — commit `fc31501d`. All 4 stages green: **Source** (GitHub App) → **security-scan** (AWS CodeBuild, 5 min ago) → **Build** (AWS CodeBuild, 1 min ago) → **Deploy** (AWS Elastic Beanstalk, just now). Zero manual intervention from push to production.

### Pipeline Flow

```
SOURCE         SECURITY SCAN      BUILD           DEPLOY
  │                 │               │               │
GitHub    TruffleHog+tfsec+Sonar  Maven→WAR    Beanstalk
  │           SSM injects          CodeArtifact   Rolling
  │           sonar-token          deps cached    deploy
  └──────────────►─────────────────►─────────────►
                ~5 min            ~1 min         74 sec
```

---

## 🔐 Security Scan Execution Logs

![Security Scan Logs](../media/cloud-native/security-scan-logs.png)

> **What the logs prove (line by line):**
> - **Line 394:** `trufflehog filesystem . --only-verified --fail` executes
> - **Line 398:** `507 chunks`, `verified_secrets: 0`, `unverified_secrets: 0` — **Gate 1 cleared**
> - **Line 403:** `tfsec ./03-aws-cloud-native/terraform --soft-fail` executes
> - **Lines 405–440:** 2 HIGH findings identified — RDS storage not encrypted, SNS topic not encrypted — **captured as technical debt**, pipeline continues with `--soft-fail`

---

## 📊 SonarCloud — SAST Analysis

![SonarCloud Analysis](../media/cloud-native/sonarcloud-passed.png)

> SonarCloud analyzed **24,000 lines** of Java, CSS, and JSP. The analysis surfaced security and reliability findings in the legacy application codebase — this is exactly the value of shift-left SAST: making hidden vulnerabilities visible and trackable before they reach users. All findings are now logged in the SonarCloud dashboard as actionable items.

---

## 🟢 Elastic Beanstalk — Health: Ok

![Elastic Beanstalk Healthy](../media/cloud-native/elastic-beanstalk-healthy.png)

> **`elbeanstalkenv`** on **Tomcat 10 + Corretto 21**, Amazon Linux 2023/5.9.3. Events log confirms the full deployment lifecycle in 74 seconds: environment started → new version deployed → instance deployment completed → health transitioned back to **Ok**. The running version is the artifact produced directly by CodePipeline — no manual upload.

---

## 📡 CloudWatch — Observability

![CloudWatch Alarm](../media/cloud-native/CloudWatch.png)

> **`vprofile-High-CPU-Alarm`**: `CPUUtilization >= 80` for 2 datapoints within 4 minutes. State: **OK**. When breached, CloudWatch triggers the SNS topic → developer email. The graph shows healthy CPU levels throughout the deployment, confirming the application is running well within instance capacity.

---

## 🖥️ Application — Live & Verified End-to-End

### Login UI — Live on Beanstalk Endpoint

![Application Login](../media/cloud-native/app-login-ui.png)

> The application is live at `eprofileapp254698.eu-central-1.elasticbeanstalk.com` — the CNAME configured in `variables.tf` (`beanstalk_cname = "eprofileapp254698"`). Deployed entirely via the pipeline.

---

### RDS Connected + Cache Written

![Database Records](../media/cloud-native/app-database-records.png)

> **"Data is From DB and Data Inserted In Cache !!"** — Two confirmations in one message: the app connected to **RDS MySQL** in the private subnet (port 3306), executed a SQL query, retrieved the user record, and immediately wrote it to **ElastiCache Memcached**. The full data layer is wired and operational.

---

### ElastiCache Cache Hit

![Memcached Cache Hit](../media/cloud-native/app-memcached-hit.png)

> **"[Data is From Cache]"** — Second request for the same user: served directly from **ElastiCache Memcached**, zero database queries. Read-through cache is working as designed — database load reduced, response time improved.

---

## ⚙️ What Terraform Provisions

```bash
terraform apply  # one command, ~12 minutes
```

| Category | What Gets Created |
|---|---|
| **Network** | VPC, 6 subnets (3 AZs), route tables, NAT GW, IGW |
| **Security** | 4 scoped Security Groups (LB / Tomcat / Data / Bastion) |
| **Compute** | Elastic Beanstalk App + Env, Bastion Host (t3.micro) |
| **Data** | RDS MySQL 8.0, ElastiCache Memcached 1.6, Amazon MQ 3.13 |
| **Secrets** | 5 SSM Parameters (3 SecureString via `random_password`) |
| **CI/CD** | CodePipeline V2, 2x CodeBuild, S3 artifact bucket |
| **Artifacts** | CodeArtifact domain + Maven proxy repository |
| **IAM** | Scoped roles for Beanstalk, CodeBuild, CodePipeline |
| **Observability** | CloudWatch CPU alarm, SNS topic + email |
| **State** | S3 remote backend (`s3-terraform-2026`) |

---

## 🛠️ Deploy It Yourself

```bash
# 1. SSH key for Beanstalk instances
ssh-keygen -t rsa -f bean-stack-key -N ""

# 2. Init Terraform
cd 03-aws-cloud-native/terraform && terraform init

# 3. Deploy everything
terraform apply -auto-approve \
  -var="sonar_token=YOUR_SONARCLOUD_TOKEN"

# 4. One-time: activate GitHub connection in AWS Console
# → CodePipeline → Connections → vprofile-github-conn → Activate

# 5. Trigger pipeline
git commit --allow-empty -m "ci: trigger" && git push origin main

# 6. Tear down
terraform destroy -auto-approve
```

---

## 🗂️ Project Structure

```
03-aws-cloud-native/
├── terraform/
│   ├── vpc.tf               # VPC + 6 subnets, 3 AZs
│   ├── secgrp.tf            # 4 security groups, least-privilege
│   ├── Data-services.tf     # RDS + ElastiCache + Amazon MQ
│   ├── bastion.tf           # Bastion + auto RDS schema init
│   ├── bean-env.tf          # Beanstalk + env var injection
│   ├── SSM.tf               # Auto-generated SecureString secrets
│   ├── CodeArtifact.tf      # Private Maven proxy
│   ├── code-build.tf        # Build + Security Scan projects
│   ├── code-pipline.tf      # 4-stage CodePipeline V2
│   ├── iam-cicd.tf          # Scoped IAM roles
│   ├── cloudwatch.tf        # CPU alarm → SNS
│   ├── backend-state.tf     # S3 remote state
│   └── templates/
│       └── bastion-init.sh  # RDS schema init on boot
├── buildspec-build.yml      # Maven → ROOT.war
├── buildspec-sec.yml        # TruffleHog + tfsec + SonarCloud
└── src/                     # Java application source
```

---

<div align="center">

**🔐 Zero hardcoded secrets · Zero manual deployments · Three security gates · One command to production**

*Strata-Ops Phase 3 — Architected by Amr Medhat Amer*

[![GitHub](https://img.shields.io/badge/GitHub-amramer101%2FStrata--Ops-181717?style=for-the-badge&logo=github)](https://github.com/amramer101/Strata-Ops)

</div>
