# 🔐 **GitHub Secrets Setup Guide**

This guide explains how to configure all required secrets for the Elastic Terraform CI/CD pipeline across multiple environments.

---

## 📋 **Required Secrets Overview**

The project requires different sets of secrets for each environment to ensure proper isolation and security.

---

## 🌍 **Environment-Specific Secrets**

### **Development Environment**
- **Environment Name**: `development`
- **Branch**: `develop`
- **Required Secrets**:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AWS_ACCESS_KEY_ID_DEV` | AWS Access Key for Development | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY_DEV` | AWS Secret Key for Development | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AZURE_CREDENTIALS` | Azure Service Principal (if using Azure) | `{"clientId":"...","clientSecret":"...","subscriptionId":"...","tenantId":"..."}` |

### **Staging Environment**
- **Environment Name**: `staging`
- **Branch**: `develop`
- **Required Secrets**:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AWS_ACCESS_KEY_ID_STAGING` | AWS Access Key for Staging | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY_STAGING` | AWS Secret Key for Staging | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AZURE_CREDENTIALS` | Azure Service Principal (if using Azure) | `{"clientId":"...","clientSecret":"...","subscriptionId":"...","tenantId":"..."}` |

### **Production Environment**
- **Environment Name**: `production`
- **Branch**: `main`
- **Required Secrets**:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AWS_ACCESS_KEY_ID_PROD` | AWS Access Key for Production | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY_PROD` | AWS Secret Key for Production | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AZURE_CREDENTIALS` | Azure Service Principal (if using Azure) | `{"clientId":"...","clientSecret":"...","subscriptionId":"...","tenantId":"..."}` |

---

## 🛠️ **Setup Instructions**

### **Step 1: Create GitHub Environments**

1. Go to your GitHub repository: `https://github.com/InfraPlatformer/elastic-terraform-demo`
2. Navigate to **Settings** → **Environments**
3. Click **New environment** for each environment:
   - `development`
   - `staging`
   - `production`

### **Step 2: Configure Environment Protection Rules**

#### **Development Environment**
- **Deployment branches**: `develop`
- **Required reviewers**: Optional (recommended for team collaboration)
- **Wait timer**: 0 minutes
- **Environment secrets**: Add development-specific secrets

#### **Staging Environment**
- **Deployment branches**: `develop`
- **Required reviewers**: Required (at least 1)
- **Wait timer**: 5 minutes (recommended)
- **Environment secrets**: Add staging-specific secrets

#### **Production Environment**
- **Deployment branches**: `main`
- **Required reviewers**: Required (at least 2)
- **Wait timer**: 10 minutes (recommended)
- **Environment secrets**: Add production-specific secrets

### **Step 3: Add Environment Secrets**

For each environment, add the corresponding secrets:

1. Go to **Settings** → **Environments**
2. Click on the environment name (e.g., `development`)
3. Click **Add secret** for each required secret
4. Enter the secret name and value
5. Click **Add secret**

---

## 🔑 **AWS IAM Setup**

### **Required IAM Permissions**

Each environment needs an IAM user with the following policies:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:*",
                "eks:*",
                "iam:*",
                "s3:*",
                "kms:*",
                "cloudwatch:*",
                "logs:*",
                "route53:*",
                "acm:*",
                "elasticloadbalancing:*",
                "autoscaling:*"
            ],
            "Resource": "*"
        }
    ]
}
```

### **Creating IAM Users**

1. **Development User**:
   ```bash
   aws iam create-user --user-name elastic-dev-user
   aws iam attach-user-policy --user-name elastic-dev-user --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
   aws iam create-access-key --user-name elastic-dev-user
   ```

2. **Staging User**:
   ```bash
   aws iam create-user --user-name elastic-staging-user
   aws iam attach-user-policy --user-name elastic-staging-user --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
   aws iam create-access-key --user-name elastic-staging-user
   ```

3. **Production User**:
   ```bash
   aws iam create-user --user-name elastic-prod-user
   aws iam attach-user-policy --user-name elastic-prod-user --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
   aws iam create-access-key --user-name elastic-prod-user
   ```

---

## 🔒 **Security Best Practices**

### **1. IAM Security**
- Use IAM roles with minimal permissions for each environment
- Enable MFA for all AWS accounts
- Rotate access keys regularly (every 90 days)
- Use environment-specific AWS accounts when possible

### **2. Secret Management**
- Never commit secrets to the repository
- Use GitHub's encrypted secrets storage
- Rotate secrets regularly
- Monitor secret access logs

### **3. Environment Isolation**
- Use separate AWS accounts for production
- Implement network isolation between environments
- Use different S3 buckets for each environment
- Implement proper tagging for cost tracking

---

## 📊 **Cost Management**

### **Environment-Specific Recommendations**

| Environment | Instance Types | Storage | Monitoring |
|-------------|----------------|---------|------------|
| **Development** | `t3.medium`, `m5.large` | 50GB | Basic |
| **Staging** | `m5.large`, `m5.xlarge` | 100GB | Standard |
| **Production** | `m5.xlarge`, `m5.2xlarge` | 200GB+ | Enhanced |

### **Cost Optimization**
- Use spot instances for development
- Implement auto-scaling for staging
- Use reserved instances for production
- Set up automated cleanup for development resources

---

## 🚨 **Troubleshooting**

### **Common Issues**

1. **"Environment not found"**:
   - Ensure environment names match exactly in workflows
   - Check environment protection rules

2. **"Secrets not accessible"**:
   - Verify secrets are added to the correct environment
   - Check secret names match workflow requirements

3. **"Approval not working"**:
   - Verify environment protection rules are configured
   - Check required reviewers are assigned

4. **"AWS credentials invalid"**:
   - Verify IAM user has correct permissions
   - Check access key is not expired
   - Ensure secret key is correct

### **Verification Steps**

1. **Test Development**:
   ```bash
   git checkout develop
   git commit --allow-empty -m "Test development deployment"
   git push origin develop
   ```

2. **Test Staging**:
   ```bash
   git checkout develop
   git commit --allow-empty -m "Test staging deployment"
   git push origin develop
   ```

3. **Test Production**:
   ```bash
   git checkout main
   git commit --allow-empty -m "Test production deployment"
   git push origin main
   ```

---

## 📈 **Monitoring and Alerting**

### **Set Up Alerts**
1. **CloudWatch Alarms** for each environment
2. **Slack/Teams notifications** for deployment status
3. **Cost alerts** for unexpected usage
4. **Security alerts** for unauthorized access

### **Monitoring Dashboard**
- Resource usage per environment
- Deployment success/failure rates
- Cost tracking per environment
- Security compliance status

---

## ✅ **Verification Checklist**

- [ ] All three environments created (`development`, `staging`, `production`)
- [ ] Environment protection rules configured
- [ ] Required secrets added to each environment
- [ ] IAM users created with proper permissions
- [ ] Branch protection rules enabled
- [ ] Test deployments successful
- [ ] Monitoring and alerting configured
- [ ] Documentation updated

---

## 🔗 **Useful Links**

- **Repository**: `https://github.com/InfraPlatformer/elastic-terraform-demo`
- **Environments**: `https://github.com/InfraPlatformer/elastic-terraform-demo/settings/environments`
- **Secrets**: `https://github.com/InfraPlatformer/elastic-terraform-demo/settings/secrets/actions`
- **Actions**: `https://github.com/InfraPlatformer/elastic-terraform-demo/actions`

---

**🎉 Once all secrets are configured, your CI/CD pipeline will be ready for production use!**

**Happy deploying! 🚀**