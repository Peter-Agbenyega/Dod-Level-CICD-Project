# DoD Tactical Operations Center Dashboard

A full-stack Military Operations Dashboard built with React and Express.js, featuring a production-grade CI/CD pipeline that mirrors the **DoD Enterprise DevSecOps Reference Design** with 13 security scanning stages.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Local Development](#local-development)
- [CI/CD Pipeline](#cicd-pipeline)
- [Pipeline Stages Explained](#pipeline-stages-explained)
- [GitHub Secrets Setup](#github-secrets-setup)
- [Docker Hub Setup](#docker-hub-setup)
- [SonarCloud Setup](#sonarcloud-setup)
- [Manual Deployment](#manual-deployment)
- [Running Scans Locally](#running-scans-locally)
- [Troubleshooting](#troubleshooting)

---

## Project Overview

The Tactical Operations Center (TOC) dashboard displays:
- **Mission Tracker** - Active operations with status, priority, and progress
- **Personnel Status** - Force readiness visualized with doughnut charts
- **Equipment Readiness** - Category-by-category bar chart
- **Threat Alerts** - Real-time alert feed with severity levels
- **KPI Status Cards** - Top-level metrics at a glance

The CI/CD pipeline implements every scanning stage mandated by the DoD DevSecOps Reference Design.

---

## Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Frontend | React 18, Chart.js | Dashboard UI with charts |
| Backend | Express.js, Node 20 | REST API serving mock data |
| Security | Helmet, CORS, Rate Limiting | HTTP hardening |
| Container | Docker (multi-stage), Alpine | Minimal attack surface |
| CI/CD | GitHub Actions | 13-stage DevSecOps pipeline |
| SAST | SonarCloud | Static code analysis |
| SCA | npm audit, OSV-Scanner | Dependency vulnerabilities |
| Container Scan | Trivy | Image CVE scanning |
| IaC Scan | Checkov | Dockerfile/Compose misconfigs |
| DAST | OWASP ZAP | Runtime vulnerability testing |
| Secrets | Gitleaks | Hardcoded secret detection |
| SBOM | Syft | Software Bill of Materials |
| Compliance | Docker Bench | CIS benchmark validation |
| Registry | Docker Hub | Container image publishing |
| Hosting | AWS EC2 (us-east-2) | Production deployment |

---

## Project Structure

```
DoD-Level-CICD-Project/
├── .github/workflows/
│   └── dod-pipeline.yml            # 13-stage DoD DevSecOps pipeline
├── client/
│   ├── public/index.html           # React HTML template
│   └── src/
│       ├── components/
│       │   ├── Header.jsx/css      # Classification banner + clock
│       │   ├── StatusCards.jsx/css  # KPI metric cards
│       │   ├── MissionTracker.jsx/css
│       │   ├── PersonnelStatus.jsx/css  # Doughnut chart
│       │   ├── EquipmentReadiness.jsx/css # Bar chart
│       │   └── ThreatAlerts.jsx/css     # Alert feed
│       ├── App.jsx/css             # Dashboard layout + dark theme
│       └── index.js                # Entry point
├── server/
│   ├── routes/                     # API endpoints
│   ├── data/mockData.js            # Mock military ops data
│   ├── middleware/security.js      # Helmet, CORS, rate limiting
│   ├── app.js                      # Express app
│   ├── server.js                   # Server entry
│   └── __tests__/api.test.js       # Jest + Supertest tests
├── Dockerfile                      # Multi-stage build
├── docker-compose.yml              # Local dev (with security opts)
├── .eslintrc.json                  # ESLint + security plugin
├── jest.config.js                  # Test configuration
├── sonar-project.properties        # SonarCloud config
├── .gitleaksignore                 # Gitleaks false-positive list
├── .gitignore
├── .dockerignore
└── README.md
```

---

## Local Development

### Prerequisites

- Node.js 20+
- Docker & Docker Compose
- Git

### Quick Start (Docker)

```bash
# Clone and build
git clone https://github.com/<your-username>/DoD-Level-CICD-Project.git
cd DoD-Level-CICD-Project
docker-compose up --build

# Access at http://localhost:5000
```

### Development Mode (without Docker)

```bash
# Terminal 1 - Start backend
cd server
npm install
npm start
# API running at http://localhost:5000

# Terminal 2 - Start frontend
cd client
npm install
npm start
# React dev server at http://localhost:3000 (proxies API to :5000)
```

### Run Tests

```bash
cd server && npm test
```

### Run Lint

```bash
cd server && npm run lint
```

---

## CI/CD Pipeline

The pipeline at `.github/workflows/dod-pipeline.yml` implements 13 stages following the DoD DevSecOps Reference Design.

### Pipeline Architecture

```
Push to main / Pull Request
         │
    ┌────┴────────────────────────┐
    │                             │
    ▼                             ▼
┌─────────┐                 ┌──────────┐
│ 1. Lint │                 │ 5. Secrets│
│ (ESLint)│                 │ (Gitleaks)│
└────┬────┘                 └──────────┘
     ▼                             │
┌──────────┐    ┌──────────┐       │
│ 2. Tests │    │ 4. SCA   │       │
│  (Jest)  │    │(npm+OSV) │       │
└────┬─────┘    └────┬─────┘       │
     ▼               │             │
┌──────────┐         │             │
│ 3. SAST  │         │             │
│(Sonar)   │         │             │
└────┬─────┘         │             │
     └───────┬───────┘─────────────┘
             ▼
     ┌───────────────┐    ┌────────────┐
     │ 6. Build &    │    │ 8. IaC     │
     │    Push       │    │ (Checkov)  │
     │ (Docker Hub)  │    └────────────┘
     └───────┬───────┘
     ┌───────┼───────────────────┐
     ▼       ▼        ▼         ▼
┌────────┐┌───────┐┌───────┐┌──────────┐
│7. Trivy││9. SBOM││10.DAST││11.Comply │
│Container││(Syft) ││ (ZAP) ││(Bench)   │
└────┬───┘└───┬───┘└───┬───┘└────┬─────┘
     └────────┼────────┘─────────┘
              ▼
     ┌────────────────┐
     │ 12. Publish    │
     │   Artifacts    │
     └───────┬────────┘
             ▼
     ┌────────────────┐
     │ 13. Deploy     │
     │   to EC2       │
     └────────────────┘
```

### Triggers

| Event | Stages 1-5 (Analysis) | Stage 6 (Build) | Stages 7-13 (Scan & Deploy) |
|-------|:---------------------:|:----------------:|:---------------------------:|
| Push to `main` | Yes | Yes | Yes |
| Pull Request | Yes | No | No |

---

## Pipeline Stages Explained

### Stage 1: Lint (ESLint + Security Plugin)
Runs ESLint with `eslint-plugin-security` to catch common security anti-patterns like `eval()`, unsafe regex, buffer overflows, and timing attacks.

### Stage 2: Unit Tests (Jest + Coverage)
Runs Jest test suite with Supertest for API endpoint testing. Generates coverage reports in LCOV format for SonarCloud consumption.

### Stage 3: SAST - Static Application Security Testing (SonarCloud)
Deep static analysis of source code for bugs, code smells, and security vulnerabilities. Detects OWASP Top 10 issues like injection, XSS, and insecure deserialization.

### Stage 4: SCA - Software Composition Analysis (npm audit + OSV-Scanner)
Scans all npm dependencies (server + client) for known CVEs. OSV-Scanner cross-references against the Google OSV vulnerability database for broader coverage.

### Stage 5: Secrets Detection (Gitleaks)
Scans the entire git history for accidentally committed secrets: API keys, tokens, passwords, private keys, and other credentials.

### Stage 6: Build & Push (Docker Hub)
Builds the multi-stage Docker image and pushes to Docker Hub with `latest` and commit SHA tags. Only runs on push to `main`.

### Stage 7: Container Scan (Trivy)
Scans the built Docker image for HIGH and CRITICAL CVEs in OS packages and application dependencies. Fails the pipeline on actionable vulnerabilities.

### Stage 8: IaC Scan (Checkov)
Analyzes `Dockerfile` and `docker-compose.yml` for security misconfigurations against CIS Docker benchmarks. Checks for issues like running as root, missing healthchecks, and privileged containers.

### Stage 9: SBOM Generation (Syft)
Generates a Software Bill of Materials in CycloneDX JSON format. Required by Executive Order 14028 for software supply chain transparency.

### Stage 10: DAST - Dynamic Application Security Testing (OWASP ZAP)
Starts the application in a container, then runs OWASP ZAP baseline scan against it. Tests for runtime vulnerabilities like XSS, CSRF, missing security headers, and information disclosure.

### Stage 11: Compliance (Docker Bench for Security)
Runs Docker Bench for Security against the running container to validate CIS Docker benchmark compliance. Checks container runtime configuration, image hardening, and security options.

### Stage 12: Publish Scan Artifacts
Aggregates all scan results from stages 1-11 into downloadable GitHub Actions artifacts. Retained for 30 days for audit purposes.

### Stage 13: Deploy to EC2
Pulls the published image from Docker Hub, deploys to EC2 with security options (`--read-only`, `--security-opt no-new-privileges`), and runs a health check verification.

---

## GitHub Secrets Setup

Navigate to your GitHub repo > **Settings** > **Secrets and variables** > **Actions** > **New repository secret**.

### Required Secrets

| Secret | Purpose | How to Get It |
|--------|---------|---------------|
| `DOCKERHUB_USERNAME` | Docker Hub login | Your Docker Hub username |
| `DOCKERHUB_TOKEN` | Docker Hub access token | Docker Hub > Account Settings > Security > New Access Token (Read & Write) |
| `SONAR_TOKEN` | SonarCloud authentication | SonarCloud > My Account > Security > Generate Token |
| `EC2_HOST` | EC2 public IP | From AWS Console after launching instance |
| `EC2_SSH_KEY` | SSH private key contents | `cat your-key.pem` (copy full output) |
| `EC2_USERNAME` | SSH username | `ubuntu` for Ubuntu AMI, `ec2-user` for Amazon Linux |

---

## Docker Hub Setup

1. Create an account at [hub.docker.com](https://hub.docker.com/)
2. Go to **Account Settings** > **Security** > **New Access Token**
3. Name: `github-actions-dod-pipeline`
4. Permissions: **Read & Write**
5. Copy the token and add it as `DOCKERHUB_TOKEN` in GitHub Secrets

---

## SonarCloud Setup

1. Sign up at [sonarcloud.io](https://sonarcloud.io/) using your GitHub account
2. Import your repository
3. Note your **Organization Key** -- update it in `sonar-project.properties`
4. Go to **My Account** > **Security** > **Generate Token**
5. Add the token as `SONAR_TOKEN` in GitHub Secrets

---

## Manual Deployment

```bash
# Build and run locally
docker-compose up --build -d

# Or deploy to EC2 manually
docker build -t dod-ops-dashboard .
docker save dod-ops-dashboard | ssh -i key.pem ubuntu@<IP> "docker load"
ssh -i key.pem ubuntu@<IP> "docker run -d --name dod-ops-dashboard \
  --restart unless-stopped -p 80:5000 \
  --read-only --tmpfs /tmp \
  --security-opt no-new-privileges:true \
  dod-ops-dashboard"
```

---

## Running Scans Locally

You can run each scanning tool locally before pushing:

```bash
# ESLint with security rules
cd server && npx eslint . --ext .js

# Jest tests with coverage
npx jest --coverage --forceExit

# Trivy container scan
docker build -t dod-ops-dashboard .
trivy image --severity HIGH,CRITICAL --ignore-unfixed dod-ops-dashboard

# Trivy IaC scan
trivy config .

# Checkov IaC scan
checkov -f Dockerfile
checkov -f docker-compose.yml

# Gitleaks secrets scan
gitleaks detect --source .

# Syft SBOM generation
syft dod-ops-dashboard -o cyclonedx-json > sbom.json

# OWASP ZAP (requires running app)
docker run -d -p 5000:5000 dod-ops-dashboard
docker run --rm --net host zaproxy/zap-stable zap-baseline.py -t http://localhost:5000

# npm audit
cd server && npm audit
cd client && npm audit
```

---

## Troubleshooting

### Pipeline fails on Trivy container scan
Update the Node.js Alpine base image in `Dockerfile` or add `RUN apk update && apk upgrade --no-cache` to patch known CVEs.

### SonarCloud scan shows "not authorized"
Verify `SONAR_TOKEN` is set correctly and the `sonar.organization` in `sonar-project.properties` matches your SonarCloud org key.

### OWASP ZAP reports many findings
ZAP baseline scans flag informational items. Review the HTML report artifact and address HIGH/MEDIUM findings first. Low/Informational items are often acceptable for internal tools.

### Docker Bench warns about root user
The Dockerfile uses `USER appuser` for the production stage. If Docker Bench still flags it, verify the `USER` directive is present after all `COPY` commands.

### npm audit shows vulnerabilities in dev dependencies
Dev dependencies (`devDependencies`) are not included in the production Docker image. Use `npm audit --production` to see only production-relevant issues.

### Checkov fails on docker-compose.yml
Ensure `read_only: true`, `security_opt: [no-new-privileges:true]`, and `tmpfs` are configured. These are CIS Docker benchmark requirements.
