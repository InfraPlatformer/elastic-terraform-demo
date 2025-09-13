# 🔐 GitHub Secrets Setup Guide

## Required Secrets for GitHub Actions

Your GitHub Actions workflow needs these secrets to work properly:

### **AWS Secrets** (Required)
```yaml
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

### **Optional Secrets** (For advanced features)
```yaml
AZURE_CREDENTIALS  # Only if using Azure
```

## 🚀 How to Add Secrets

### **Method 1: GitHub Web Interface**
1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `AWS_ACCESS_KEY_ID` | `AKIA...` | Your AWS Access Key ID |
| `AWS_SECRET_ACCESS_KEY` | `your-secret-key` | Your AWS Secret Access Key |

### **Method 2: GitHub CLI** (if you have it installed)
```bash
# Add AWS secrets
gh secret set AWS_ACCESS_KEY_ID --body "your-aws-access-key-id"
gh secret set AWS_SECRET_ACCESS_KEY --body "your-aws-secret-key"
```

## 🔍 How to Get AWS Credentials

### **Option 1: AWS Console**
1. Go to AWS Console → IAM → Users
2. Select your user → Security credentials
3. Create access key
4. Copy Access Key ID and Secret Access Key

### **Option 2: AWS CLI** (if configured)
```bash
aws configure list
# Shows your current credentials
```

## ✅ Test Your Setup

After adding secrets, your workflow should:
1. ✅ **Code Quality**: Pass formatting and validation checks
2. ✅ **Security Scan**: Run Checkov security scan
3. ✅ **Terraform Plan**: Create plan on pull requests
4. ✅ **Deploy**: Deploy to staging/production on push

## 🚨 Common Issues

### **"Secret not found" Error**
- Make sure secret names match exactly (case-sensitive)
- Check that secrets are added to the correct repository

### **"AWS credentials invalid" Error**
- Verify your AWS credentials are correct
- Check that your AWS user has necessary permissions

### **"Terraform plan failed" Error**
- Check that your terraform.tfvars files exist
- Verify your Terraform configuration is valid

## 🔧 Quick Test

To test if your secrets are working:

1. **Push a small change** to trigger the workflow
2. **Check the Actions tab** in your GitHub repository
3. **Look for the "Elastic Stack - Working CI/CD" workflow**
4. **Verify all steps pass** ✅

## 📋 Next Steps

1. **Add the required secrets** to your GitHub repository
2. **Push a test commit** to trigger the workflow
3. **Check the Actions tab** to see if it passes
4. **Let me know if you see any errors** and I'll help fix them!

Your GitHub Actions should now work properly! 🎉
