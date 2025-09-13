# 🔐 GitHub Actions Credentials Setup Guide

## Overview
This guide will help you set up all the necessary credentials for your multi-cloud Terraform CI/CD pipeline.

## Required GitHub Secrets

### AWS Credentials (3 Environments)

#### Development Environment
- `AWS_ACCESS_KEY_ID_DEV`
- `AWS_SECRET_ACCESS_KEY_DEV`
- `AWS_ROLE_ARN_DEV`

#### Staging Environment
- `AWS_ACCESS_KEY_ID_STAGING`
- `AWS_SECRET_ACCESS_KEY_STAGING`
- `AWS_ROLE_ARN_STAGING`

#### Production Environment
- `AWS_ACCESS_KEY_ID_PROD`
- `AWS_SECRET_ACCESS_KEY_PROD`
- `AWS_ROLE_ARN_PROD`

### Azure Credentials
- `AZURE_CREDENTIALS` (Service Principal JSON)

## Step-by-Step Setup

### 1. AWS Setup

#### Create IAM Users for Each Environment

```bash
# Development User
aws iam create-user --user-name github-actions-dev
aws iam attach-user-policy --user-name github-actions-dev --policy-arn arn:aws:iam::aws:policy/PowerUserAccess

# Staging User
aws iam create-user --user-name github-actions-staging
aws iam attach-user-policy --user-name github-actions-staging --policy-arn arn:aws:iam::aws:policy/PowerUserAccess

# Production User
aws iam create-user --user-name github-actions-prod
aws iam attach-user-policy --user-name github-actions-prod --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
```

#### Create Access Keys

```bash
# Development
aws iam create-access-key --user-name github-actions-dev

# Staging
aws iam create-access-key --user-name github-actions-staging

# Production
aws iam create-access-key --user-name github-actions-prod
```

#### Create IAM Roles for Cross-Account Access

```bash
# Development Role
aws iam create-role --role-name GitHubActions-Dev-Role --assume-role-policy-document '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::YOUR-ACCOUNT-ID:user/github-actions-dev"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}'

# Attach policies to roles
aws iam attach-role-policy --role-name GitHubActions-Dev-Role --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
aws iam attach-role-policy --role-name GitHubActions-Dev-Role --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
```

### 2. Azure Setup

#### Create Service Principal

```bash
# Login to Azure
az login

# Create service principal
az ad sp create-for-rbac --name "github-actions-terraform" --role contributor --scopes /subscriptions/{subscription-id} --sdk-auth
```

#### Required Azure Permissions
- **Contributor** role on the subscription
- **User Access Administrator** for role assignments
- **Key Vault Administrator** for secrets management

### 3. GitHub Secrets Configuration

Go to your repository: `Settings > Secrets and variables > Actions`

#### Add the following secrets:

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

AZURE_CREDENTIALS={"clientId":"...","clientSecret":"...","subscriptionId":"...","tenantId":"...","activeDirectoryEndpointUrl":"...","resourceManagerEndpointUrl":"...","activeDirectoryGraphResourceId":"...","sqlManagementEndpointUrl":"...","galleryEndpointUrl":"...","managementEndpointUrl":"..."}
```

## Security Best Practices

### 1. Use Least Privilege
- Only grant necessary permissions
- Use separate credentials for each environment
- Rotate credentials regularly

### 2. Use IAM Roles Instead of Access Keys
- Prefer role-based authentication
- Use temporary credentials
- Implement cross-account access patterns

### 3. Monitor Access
- Enable CloudTrail logging
- Set up alerts for unusual activity
- Regular access reviews

## Troubleshooting

### Common Issues

1. **"Access Denied" errors**
   - Check IAM permissions
   - Verify role ARNs are correct
   - Ensure policies are attached

2. **"Invalid credentials" errors**
   - Verify secret values are correct
   - Check for extra spaces or characters
   - Ensure credentials haven't expired

3. **"Role cannot be assumed" errors**
   - Check trust policy on IAM role
   - Verify principal ARN matches
   - Ensure role exists in correct account

### Testing Credentials

```bash
# Test AWS credentials
aws sts get-caller-identity

# Test Azure credentials
az account show
```

## Next Steps

1. Set up all required secrets in GitHub
2. Test the credentials locally
3. Run a test workflow
4. Monitor for any issues
5. Set up credential rotation schedule

## Support

If you encounter issues:
1. Check the GitHub Actions logs
2. Verify all secrets are set correctly
3. Test credentials locally first
4. Review IAM policies and permissions
