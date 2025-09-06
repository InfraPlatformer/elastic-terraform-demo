# 🚀 Elasticsearch & Terraform: The Infrastructure Comedy Show

**Because manually configuring Elasticsearch clusters is like trying to herd cats... but with more YAML and fewer lives.**

[![CI/CD Pipeline](https://github.com/InfraPlatformer/elastic-terraform-demo/workflows/Terraform%20Infrastructure%20Pipeline/badge.svg)](https://github.com/InfraPlatformer/elastic-terraform-demo/actions)
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-blue.svg)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.28+-blue.svg)](https://kubernetes.io/)
[![Elasticsearch](https://img.shields.io/badge/Elasticsearch-8.5+-green.svg)](https://www.elastic.co/)
[![Sanity](https://img.shields.io/badge/Sanity-Lost-red.svg)](https://github.com/InfraPlatformer/elastic-terraform-demo)

## 🎭 **The Plot Twist**

Once upon a time, a developer thought: *"What if I could deploy Elasticsearch without crying into my coffee every morning?"* 

This project is the result of that existential crisis. It's a complete, production-ready Elasticsearch monitoring stack that actually works (most of the time) across multiple cloud providers using Terraform. Because why choose one cloud when you can confuse yourself with two?

### **🎪 The Circus Acts (Features)**

- 🏗️ **Infrastructure as Code** - Because clicking buttons in AWS Console is for peasants
- 🌐 **Multi-Cloud Support** - Deploy on AWS EKS, Azure AKS, or both (because we love complexity)
- 🚀 **Automated CI/CD** - GitHub Actions that work 90% of the time (the other 10% is debugging)
- 🔒 **Enterprise Security** - X-Pack security, SSL/TLS, and RBAC (because hackers are real)
- 📊 **Monitoring Stack** - Elasticsearch, Kibana, and enough dashboards to make your eyes bleed
- 🌍 **Multi-Environment** - Dev, Staging, and Production (because breaking production is a rite of passage)
- 💰 **Cost Optimization** - Auto-scaling, spot instances, and resource management (because AWS bills are scary)
- 🔄 **GitOps Ready** - ArgoCD integration (because we're not masochists)

## 🎪 **The Architecture (A.K.A. "How We Made It Complicated")**

```
┌─────────────────────────────────────────────────────────────┐
│              GitHub Repository (The Command Center)        │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   Development   │  │     Staging     │  │ Production  │ │
│  │  (The Wild West)│  │ (The Test Lab)  │  │(The Big Leagues)│ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│            GitHub Actions CI/CD (The Magic Factory)        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Security  │  │   Validate  │  │   Deploy & Test    │ │
│  │    Scan     │  │  Terraform  │  │   Environments     │ │
│  │ (Paranoid)  │  │ (Grammar Nazi)│  │  (Hope & Pray)    │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│         Multi-Cloud Infrastructure (The Money Pit)         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │     AWS     │  │    Azure    │  │   Elasticsearch     │ │
│  │     EKS     │  │     AKS     │  │   + Kibana Stack    │ │
│  │ (Expensive) │  │ (Also Expensive)│  │  (The Star)      │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 🎬 **The Opening Scene (Quick Start)**

### **Prerequisites (A.K.A. "Things That Should Work But Don't")**

- [Terraform](https://www.terraform.io/downloads.html) >= 1.5.0 (because older versions are like using a flip phone)
- [AWS CLI](https://aws.amazon.com/cli/) configured (and your credit card ready)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) configured (because one cloud wasn't enough)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) >= 1.28 (the Swiss Army knife of Kubernetes)
- [GitHub Account](https://github.com/) with repository access (and a strong password)

### **1. Clone the Repository (A.K.A. "Download the Chaos")**

```bash
git clone https://github.com/InfraPlatformer/elastic-terraform-demo.git
cd elastic-terraform-demo
# Take a deep breath, you're about to enter the matrix
```

### **2. Configure Cloud Credentials (A.K.A. "Sell Your Soul to the Cloud")**

#### **AWS Configuration (The Expensive One)**
```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and Region
# Pro tip: Set up billing alerts. Trust us.
```

#### **Azure Configuration (The Other Expensive One)**
```bash
az login
az account set --subscription "your-subscription-id"
# Because managing one cloud provider's billing is for amateurs
```

### **3. Deploy Development Environment (A.K.A. "The Test Run")**

```bash
# Navigate to development environment
cd environments/development

# Initialize Terraform (this is where the magic happens)
terraform init
# If this fails, check your internet connection and try again
# If it still fails, check your sanity

# Plan deployment (multi-cloud, because we're ambitious)
terraform plan
# This will show you what Terraform wants to create
# Spoiler alert: it's a lot of expensive things

# Apply infrastructure (the point of no return)
terraform apply -auto-approve
# Go grab some coffee, this might take a while
# And maybe some tissues for when you see the bill
```

### **4. Access Your Multi-Cloud Stack (A.K.A. "The Moment of Truth")**

```bash
# Configure kubectl for AWS EKS (the expensive cluster)
aws eks update-kubeconfig --region us-west-2 --name advanced-elastic-development-aws

# Configure kubectl for Azure AKS (the other expensive cluster)
az aks get-credentials --resource-group multi-cloud-elastic-rg --name advanced-elastic-development-aws-azure

# Check Elasticsearch on AWS (fingers crossed)
kubectl get pods -n elasticsearch --context=aws
# If you see "Running" status, congratulations! You've achieved the impossible

# Check Elasticsearch on Azure (double fingers crossed)
kubectl get pods -n elasticsearch --context=azure
# If this also works, you might be a wizard

# Port forward Kibana (AWS) - because we need pretty dashboards
kubectl port-forward -n elasticsearch svc/advanced-elastic-development-aws-elasticsearch-aws 9200:9200 --context=aws

# Port forward Kibana (Azure) - because one dashboard isn't enough
kubectl port-forward -n elasticsearch svc/advanced-elastic-development-aws-elasticsearch-azure 9200:9200 --context=azure
```

## 🎭 **The CI/CD Pipeline Setup (A.K.A. "Automating the Chaos")**

### **1. Configure GitHub Secrets (A.K.A. "The Password Manager")**

Follow the [Secrets Setup Guide](.github/SETUP_SECRETS.md) to configure:
- AWS credentials for each environment (because one set isn't enough)
- Azure credentials for each environment (because we love complexity)
- Environment protection rules (because production is sacred)
- Deployment permissions (because we're not anarchists)

### **2. Push to Trigger Pipeline (A.K.A. "The Moment of Truth")**

```bash
git add .
git commit -m "Initial CI/CD setup"
git push origin develop  # Triggers development deployment
# Cross your fingers and hope for the best
```

### **3. Monitor Pipeline (A.K.A. "The Anxiety-Inducing Part")**

- View runs in GitHub Actions tab (and refresh every 30 seconds)
- Check deployment status in AWS Console (while watching your bill increase)
- Check deployment status in Azure Portal (while watching your other bill increase)
- Monitor Kubernetes resources with kubectl (and pray to the Kubernetes gods)

## 🌍 **Environment Configurations (A.K.A. "The Three Stages of Grief")**

### **Development Environment (The Wild West)**
- **Purpose**: Local development and testing (and breaking things)
- **Resources**: Multi-cloud (AWS EKS + Azure AKS) (because one cloud is boring)
- **Auto-deploy**: ✅ On `develop` branch (because manual deployment is for peasants)
- **Security**: Basic (disabled for development) (because security is hard)
- **Cloud Providers**: AWS (us-west-2) + Azure (West US 2) (because we love time zones)

### **Staging Environment (The Test Lab)**
- **Purpose**: Pre-production testing (and finding bugs before production)
- **Resources**: Medium (t3.large instances) (because we're not made of money)
- **Auto-deploy**: ✅ On `main` branch (because automation is life)
- **Security**: Production-like with SSL (because we're not completely reckless)
- **Cloud Providers**: AWS (us-west-2) (because one cloud is enough for staging)

### **Production Environment (The Big Leagues)**
- **Purpose**: Live production workloads (and keeping the business running)
- **Resources**: High (m5.large/xlarge instances) (because production deserves the best)
- **Auto-deploy**: ❌ Manual approval required (because production is sacred)
- **Security**: Enterprise-grade with full encryption (because hackers are real)
- **Cloud Providers**: AWS (us-west-2) (because we're not completely insane)

## 📁 **Project Structure (A.K.A. "The Organized Chaos")**

```
elastic-terraform/
├── .github/                          # GitHub Actions CI/CD (the automation magic)
│   ├── workflows/
│   │   └── terraform-deploy.yml     # Main CI/CD pipeline (the conductor)
│   └── SETUP_SECRETS.md             # Secrets configuration guide (the password manager)
├── environments/                     # Environment-specific configs (the three stages)
│   ├── development/                 # The wild west
│   │   ├── main.tf                  # Development environment main config
│   │   ├── variables.tf             # Development environment variables
│   │   ├── outputs.tf               # Development environment outputs
│   │   └── terraform.tfvars         # Development environment variables
│   ├── staging/                     # The test lab
│   │   └── terraform.tfvars         # Staging environment variables
│   └── production/                  # The big leagues
│       └── terraform.tfvars         # Production environment variables
├── modules/                          # Reusable Terraform modules (the building blocks)
│   ├── eks/                         # EKS cluster module (the expensive one)
│   ├── azure-aks/                   # Azure AKS cluster module (the other expensive one)
│   ├── elasticsearch/               # Elasticsearch module (the star of the show)
│   ├── kibana/                      # Kibana module (the pretty face)
│   ├── monitoring/                  # Monitoring stack module (the watchdog)
│   ├── networking/                  # VPC and networking module (the nervous system)
│   └── multi-cloud-elasticsearch/   # Multi-cloud Elasticsearch module (the overachiever)
├── elasticsearch-values.yaml         # Elasticsearch Helm values (the configuration)
├── kibana-values.yaml               # Kibana Helm values (the other configuration)
├── main.tf                          # Main Terraform configuration (the conductor)
├── variables.tf                     # Variable definitions (the parameters)
├── outputs.tf                       # Output values (the results)
└── README.md                        # This file (the manual)
```

## 🔒 **Security Features (A.K.A. "The Paranoia Settings")**

- **X-Pack Security**: Authentication and authorization (because we don't trust anyone)
- **SSL/TLS Encryption**: In-transit and at-rest encryption (because privacy matters)
- **RBAC**: Role-based access control (because not everyone needs admin access)
- **Network Policies**: Kubernetes network security (because network security is hard)
- **IAM Integration**: AWS IAM roles and policies (because AWS security is a maze)
- **Azure RBAC**: Azure role-based access control (because Azure security is another maze)
- **Secret Management**: Kubernetes secrets and cloud provider secret management (because secrets are secret)

## 📊 **Monitoring & Observability (A.K.A. "The Watchtower")**

- **Elasticsearch**: Centralized logging and search across clouds (the data hoarder)
- **Kibana**: Data visualization and management (the pretty dashboard)
- **Prometheus**: Metrics collection (the data collector)
- **Grafana**: Advanced dashboards (the other pretty dashboard)
- **Alerting**: Automated notifications (the alarm system)
- **Log Aggregation**: Centralized log management (the log hoarder)
- **Multi-Cloud Visibility**: Cross-cloud monitoring and alerting (because one cloud isn't enough)

## 💰 **Cost Optimization (A.K.A. "The Money Saver")**

- **Auto-scaling**: Automatic resource scaling based on demand (because manual scaling is for peasants)
- **Spot Instances**: Use of AWS spot instances for non-critical workloads (because we're cheap)
- **Resource Limits**: Proper CPU and memory limits (because unlimited resources don't exist)
- **Storage Optimization**: Efficient EBS volume management (because storage is expensive)
- **Multi-Cloud Cost Management**: Cost tracking across cloud providers (because we love spreadsheets)
- **Monitoring**: Cost tracking and optimization recommendations (because money doesn't grow on trees)

## 🚨 **Troubleshooting (A.K.A. "The Debugging Chronicles")**

### **Common Issues (A.K.A. "Things That Will Go Wrong")**

1. **Multi-Cloud Connection Issues**
   ```bash
   # Check AWS Elasticsearch status
   kubectl get pods -n elasticsearch --context=aws
   # If you see "Error" or "CrashLoopBackOff", you're in for a fun time
   
   # Check Azure Elasticsearch status
   kubectl get pods -n elasticsearch --context=azure
   # If this also shows errors, congratulations! You've achieved maximum complexity
   
   # Check cross-cloud connectivity
   kubectl logs -n elasticsearch elasticsearch-aws-0 --context=aws
   kubectl logs -n elasticsearch elasticsearch-azure-0 --context=azure
   # These logs will either solve your problem or give you a headache
   ```

2. **Terraform State Issues**
   ```bash
   # Reinitialize Terraform
   terraform init -reconfigure
   # This fixes 90% of Terraform issues (the other 10% require therapy)
   
   # Import existing resources
   terraform import aws_eks_cluster.main cluster-name
   terraform import azurerm_kubernetes_cluster.main cluster-name
   # Because sometimes you need to tell Terraform about resources it doesn't know about
   ```

3. **CI/CD Pipeline Failures**
   - Check GitHub Actions logs (and prepare for a debugging session)
   - Verify AWS and Azure credentials (because authentication is hard)
   - Check environment protection rules (because security is important)
   - Verify multi-cloud configuration (because complexity is our middle name)

### **Getting Help (A.K.A. "The Support Network")**

- 📖 [Documentation](docs/) (because reading is fundamental)
- 🐛 [Issues](https://github.com/InfraPlatformer/elastic-terraform-demo/issues) (because bugs happen)
- 💬 [Discussions](https://github.com/InfraPlatformer/elastic-terraform-demo/discussions) (because talking helps)

## 🤝 **Contributing (A.K.A. "Join the Chaos")**

1. Fork the repository (because copying is the sincerest form of flattery)
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request (and wait for the review process)

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
Because we're not lawyers, and MIT is simple.

## 🙏 **Acknowledgments**

- [HashiCorp Terraform](https://www.terraform.io/) for infrastructure automation (and the occasional headache)
- [Elastic](https://www.elastic.co/) for the Elasticsearch stack (and the learning curve)
- [AWS](https://aws.amazon.com/) for cloud infrastructure (and the bills)
- [Microsoft Azure](https://azure.microsoft.com/) for cloud infrastructure (and the other bills)
- [Kubernetes](https://kubernetes.io/) for container orchestration (and the complexity)

---

**⭐ Star this repository if you find it helpful! (And if you don't, that's okay too)**

**🔗 Connect with us:**
- [GitHub](https://github.com/InfraPlatformer) (because we're social)
- [LinkedIn](https://www.linkedin.com/in/alam-ahmed-133360291/) (because networking is important)

---

*"Infrastructure as Code: Because manually configuring servers is like trying to teach a cat to fetch... but with more YAML and fewer lives."* 🐱

*P.S. If this README made you laugh, the infrastructure will probably work. If it made you cry, you're in the right place.* 😅
