# GitHub Secrets Setup for Multi-Cloud CI/CD Pipeline

## 🔐 **Required GitHub Secrets**

This document outlines all the GitHub secrets required for the multi-cloud Terraform CI/CD pipeline to function properly.

## 🚨 **Critical Secrets (Required)**

### **AWS Credentials - Development Environment**
```
AWS_ACCESS_KEY_ID_DEV
AWS_SECRET_ACCESS_KEY_DEV
```

### **AWS Credentials - Staging Environment**
```
AWS_ACCESS_KEY_ID_STAGING
AWS_SECRET_ACCESS_KEY_STAGING
```

### **AWS Credentials - Production Environment**
```
AWS_ACCESS_KEY_ID_PROD
AWS_SECRET_ACCESS_KEY_PROD
```

### **Azure Credentials (All Environments)**
```
AZURE_CREDENTIALS
```

## 📋 **How to Set Up Secrets**

### **Step 1: Go to GitHub Repository Settings**
1. Navigate to your repository: `https://github.com/InfraPlatformer/elastic-terraform-demo`
2. Click on **Settings** tab
3. Click on **Secrets and variables** → **Actions**

### **Step 2: Add AWS Secrets**

#### **Development Environment**
```
Name: AWS_ACCESS_KEY_ID_DEV
Value: [Your AWS Access Key ID for dev environment]

Name: AWS_SECRET_ACCESS_KEY_DEV
Value: [Your AWS Secret Access Key for dev environment]
```

#### **Staging Environment**
```
Name: AWS_ACCESS_KEY_ID_STAGING
Value: [Your AWS Access Key ID for staging environment]

Name: AWS_SECRET_ACCESS_KEY_STAGING
Value: [Your AWS Secret Access Key for staging environment]
```

#### **Production Environment**
```
Name: AWS_ACCESS_KEY_ID_PROD
Value: [Your AWS Access Key ID for production environment]

Name: AWS_SECRET_ACCESS_KEY_PROD
Value: [Your AWS Secret Access Key for production environment]
```

### **Step 3: Add Azure Secret**

#### **Azure Service Principal Credentials**
```
Name: AZURE_CREDENTIALS
Value: [JSON string with Azure service principal details]
```

**Azure Credentials JSON Format:**
```json
{
  "clientId": "your-client-id",
  "clientSecret": "your-client-secret",
  "subscriptionId": "your-subscription-id",
  "tenantId": "your-tenant-id"
}
```

## 🔑 **How to Create Azure Service Principal**

### **Step 1: Install Azure CLI**
```bash
# Windows (PowerShell)
winget install Microsoft.AzureCLI

# macOS
brew install azure-cli

# Linux
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### **Step 2: Login to Azure**
```bash
az login
```

### **Step 3: Create Service Principal**
```bash
az ad sp create-for-rbac \
  --name "elastic-terraform-sp" \
  --role contributor \
  --scopes /subscriptions/[YOUR-SUBSCRIPTION-ID] \
  --sdk-auth
```

### **Step 4: Copy Output**
The command will output a JSON object. Copy the entire JSON and use it as the `AZURE_CREDENTIALS` secret value.

## 🔐 **How to Create AWS IAM Users**

### **Step 1: Create IAM Users for Each Environment**
1. Go to AWS IAM Console
2. Create users: `elastic-terraform-dev`, `elastic-terraform-staging`, `elastic-terraform-prod`

### **Step 2: Attach Policies**
Attach the following policies to each user:
- `AmazonEKSClusterPolicy`
- `AmazonEKSWorkerNodePolicy`
- `AmazonEKS_CNI_Policy`
- `AmazonEC2ContainerRegistryReadOnly`
- `AmazonS3FullAccess` (for state management)

### **Step 3: Generate Access Keys**
1. Select each user
2. Go to **Security credentials** tab
3. Click **Create access key**
4. Copy the Access Key ID and Secret Access Key

## 🚨 **Security Best Practices**

### **1. Principle of Least Privilege**
- Only grant necessary permissions
- Use separate credentials for each environment
- Regularly rotate access keys

### **2. Environment Isolation**
- Never share credentials between environments
- Use different AWS accounts for production if possible
- Implement proper network segmentation

### **3. Secret Management**
- Never commit secrets to code
- Use GitHub's encrypted secrets
- Consider using AWS Secrets Manager or Azure Key Vault for production

## ✅ **Verification Steps**

### **Step 1: Test Development Deployment**
1. Push to `develop` branch
2. Check GitHub Actions tab
3. Verify all secrets are accessible
4. Confirm deployment succeeds

### **Step 2: Test Staging Deployment**
1. Push to `develop` branch
2. Verify staging environment deployment
3. Check multi-cloud connectivity

### **Step 3: Test Production Deployment**
1. Push to `main` branch
2. Verify manual approval workflow
3. Confirm production deployment

## 🆘 **Troubleshooting**

### **Common Issues**

#### **"Secret not found" Error**
- Verify secret names match exactly (case-sensitive)
- Check if secrets are set in the correct repository
- Ensure secrets are not set at organization level

#### **"Invalid credentials" Error**
- Verify AWS/Azure credentials are correct
- Check if credentials have expired
- Confirm IAM permissions are sufficient

#### **"Permission denied" Error**
- Verify service principal has correct roles
- Check if subscription is active
- Confirm resource group permissions

## 📞 **Support**

If you encounter issues:
1. Check GitHub Actions logs for detailed error messages
2. Verify all secrets are properly configured
3. Test credentials manually using AWS CLI/Azure CLI
4. Review IAM policies and Azure RBAC assignments

## 🔄 **Regular Maintenance**

### **Monthly Tasks**
- Review and rotate AWS access keys
- Verify Azure service principal permissions
- Audit IAM policies and Azure RBAC
- Update documentation

### **Quarterly Tasks**
- Review security policies
- Update CI/CD pipeline configurations
- Conduct security assessments
- Update dependencies and tools
