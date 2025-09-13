# GitHub Secrets Template

## Required Secrets for Multi-Cloud Terraform CI/CD Pipeline

Copy this template and replace the placeholder values with your actual credentials.

### AWS Credentials (Development Environment)
```
AWS_ACCESS_KEY_ID_DEV=AKIA...
AWS_SECRET_ACCESS_KEY_DEV=...
AWS_ROLE_ARN_DEV=arn:aws:iam::YOUR-ACCOUNT-ID:role/GitHubActions-Dev-Role
```

### AWS Credentials (Staging Environment)
```
AWS_ACCESS_KEY_ID_STAGING=AKIA...
AWS_SECRET_ACCESS_KEY_STAGING=...
AWS_ROLE_ARN_STAGING=arn:aws:iam::YOUR-ACCOUNT-ID:role/GitHubActions-Staging-Role
```

### AWS Credentials (Production Environment)
```
AWS_ACCESS_KEY_ID_PROD=AKIA...
AWS_SECRET_ACCESS_KEY_PROD=...
AWS_ROLE_ARN_PROD=arn:aws:iam::YOUR-ACCOUNT-ID:role/GitHubActions-Prod-Role
```

### Azure Credentials
```
AZURE_CREDENTIALS={"clientId":"...","clientSecret":"...","subscriptionId":"...","tenantId":"...","activeDirectoryEndpointUrl":"...","resourceManagerEndpointUrl":"...","activeDirectoryGraphResourceId":"...","sqlManagementEndpointUrl":"...","galleryEndpointUrl":"...","managementEndpointUrl":"..."}
```

## How to Add Secrets to GitHub

1. Go to your repository: https://github.com/InfraPlatformer/elastic-terraform-demo
2. Click **Settings** tab
3. Click **Secrets and variables** > **Actions**
4. Click **New repository secret**
5. Add each secret with the exact name and value from above

## Security Notes

- ⚠️ **Never commit these secrets to your repository**
- 🔄 **Rotate credentials regularly**
- 🔒 **Use least privilege principle**
- 📊 **Monitor access logs**

## Testing Your Credentials

After adding the secrets, you can test them by:

1. Running the setup script: `.\setup-credentials.ps1`
2. Triggering a test workflow
3. Checking the GitHub Actions logs

## Troubleshooting

### Common Issues:
- **"Access Denied"**: Check IAM permissions and role ARNs
- **"Invalid credentials"**: Verify secret values are correct
- **"Role cannot be assumed"**: Check trust policy on IAM role

### Verification Commands:
```bash
# Test AWS credentials
aws sts get-caller-identity

# Test Azure credentials
az account show
```
