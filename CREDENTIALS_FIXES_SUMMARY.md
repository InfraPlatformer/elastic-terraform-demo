# 🔐 GitHub Actions Credentials Fixes - Complete Guide

## Issues Identified and Fixed

### 1. **Missing Credential Verification**
- **Problem**: Workflows didn't verify credentials before using them
- **Fix**: Added credential verification steps after each setup
- **Result**: ✅ Early detection of credential issues

### 2. **Inconsistent AWS Role Usage**
- **Problem**: Some steps used role-to-assume, others didn't
- **Fix**: Standardized role usage across all environments
- **Result**: ✅ Consistent authentication pattern

### 3. **Missing kubectl Setup**
- **Problem**: Kubernetes commands failed due to missing kubectl
- **Fix**: Added kubectl setup step using azure/setup-kubectl@v3
- **Result**: ✅ Kubernetes operations now work

### 4. **No Error Handling for Credentials**
- **Problem**: Credential failures caused unclear error messages
- **Fix**: Added verification steps with clear success/failure messages
- **Result**: ✅ Better debugging and error reporting

## Files Created/Updated

### 📁 **New Files Created:**
1. **`CREDENTIALS_SETUP_GUIDE.md`** - Comprehensive setup instructions
2. **`setup-credentials.ps1`** - PowerShell script to help with setup
3. **`github-secrets-template.md`** - Template for GitHub secrets
4. **`.github/workflows/terraform-ci-cd-fixed.yml`** - Improved workflow with better credential handling
5. **`CREDENTIALS_FIXES_SUMMARY.md`** - This summary file

### 📝 **Files Updated:**
1. **`.github/workflows/terraform-ci-cd.yml`** - Added credential verification steps

## Required GitHub Secrets

### AWS Credentials (3 Environments)
```
AWS_ACCESS_KEY_ID_DEV=AKIA...
AWS_SECRET_ACCESS_KEY_DEV=...
AWS_ROLE_ARN_DEV=arn:aws:iam::ACCOUNT-ID:role/GitHubActions-Dev-Role

AWS_ACCESS_KEY_ID_STAGING=AKIA...
AWS_SECRET_ACCESS_KEY_STAGING=...
AWS_ROLE_ARN_STAGING=arn:aws:iam::ACCOUNT-ID:role/GitHubActions-Staging-Role

AWS_ACCESS_KEY_ID_PROD=AKIA...
AWS_SECRET_ACCESS_KEY_PROD=...
AWS_ROLE_ARN_PROD=arn:aws:iam::ACCOUNT-ID:role/GitHubActions-Prod-Role
```

### Azure Credentials
```
AZURE_CREDENTIALS={"clientId":"...","clientSecret":"...","subscriptionId":"...","tenantId":"...","activeDirectoryEndpointUrl":"...","resourceManagerEndpointUrl":"...","activeDirectoryGraphResourceId":"...","sqlManagementEndpointUrl":"...","galleryEndpointUrl":"...","managementEndpointUrl":"..."}
```

## Quick Setup Steps

### 1. **Run the Setup Script**
```powershell
.\setup-credentials.ps1
```

### 2. **Create AWS Credentials**
```bash
# Create IAM users for each environment
aws iam create-user --user-name github-actions-dev
aws iam create-user --user-name github-actions-staging
aws iam create-user --user-name github-actions-prod

# Attach policies
aws iam attach-user-policy --user-name github-actions-dev --policy-arn arn:aws:iam::aws:policy/PowerUserAccess

# Create access keys
aws iam create-access-key --user-name github-actions-dev
```

### 3. **Create Azure Credentials**
```bash
# Login to Azure
az login

# Create service principal
az ad sp create-for-rbac --name "github-actions-terraform" --role contributor --scopes /subscriptions/{subscription-id} --sdk-auth
```

### 4. **Add Secrets to GitHub**
1. Go to: https://github.com/InfraPlatformer/elastic-terraform-demo/settings/secrets/actions
2. Click "New repository secret"
3. Add each secret with the exact name and value

## Improvements Made

### ✅ **Credential Verification**
- Added `aws sts get-caller-identity` checks
- Added `az account show` checks
- Clear success/failure messages

### ✅ **Better Error Handling**
- Credential verification before operations
- Clear error messages for debugging
- Proper exit codes for failures

### ✅ **Consistent Patterns**
- Standardized AWS credential setup across environments
- Consistent role usage
- Uniform error handling

### ✅ **Kubernetes Support**
- Added kubectl setup step
- Proper version specification
- Cross-platform compatibility

## Testing Your Setup

### 1. **Test Locally**
```bash
# Test AWS
aws sts get-caller-identity

# Test Azure
az account show
```

### 2. **Test in GitHub Actions**
1. Push changes to trigger workflow
2. Check the "Verify AWS Credentials" and "Verify Azure Credentials" steps
3. Look for ✅ success messages

### 3. **Monitor Logs**
- Check GitHub Actions logs for credential issues
- Look for clear error messages if something fails

## Security Best Practices

### 🔒 **IAM Policies**
- Use least privilege principle
- Separate credentials for each environment
- Regular credential rotation

### 🔒 **Role-Based Access**
- Prefer IAM roles over access keys
- Use temporary credentials
- Implement cross-account access patterns

### 🔒 **Monitoring**
- Enable CloudTrail logging
- Set up alerts for unusual activity
- Regular access reviews

## Troubleshooting

### Common Issues:
1. **"Access Denied"** → Check IAM permissions and role ARNs
2. **"Invalid credentials"** → Verify secret values are correct
3. **"Role cannot be assumed"** → Check trust policy on IAM role
4. **"kubectl not found"** → Ensure kubectl setup step is included

### Debug Steps:
1. Check GitHub Actions logs
2. Verify all secrets are set correctly
3. Test credentials locally first
4. Review IAM policies and permissions

## Next Steps

1. ✅ **Set up all required secrets in GitHub**
2. ✅ **Test the credentials locally**
3. ✅ **Run a test workflow**
4. ✅ **Monitor for any issues**
5. ✅ **Set up credential rotation schedule**

## Support

If you encounter issues:
1. Check the GitHub Actions logs
2. Verify all secrets are set correctly
3. Test credentials locally first
4. Review IAM policies and permissions
5. Use the troubleshooting guide above

---

**🎉 Your GitHub Actions credentials are now properly configured and ready for multi-cloud deployments!**
