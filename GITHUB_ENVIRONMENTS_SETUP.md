# GitHub Environments and Secrets Setup Guide

## Overview
This guide explains how to set up GitHub Environments and Secrets for the Elastic Terraform CI/CD pipeline to support multiple environments (development, staging, production).

## Required GitHub Environments

### 1. Development Environment
- **Name**: `development`
- **Branch protection**: `develop` branch
- **Required secrets**:
  - `AWS_ACCESS_KEY_ID_DEV`
  - `AWS_SECRET_ACCESS_KEY_DEV`
  - `AZURE_CREDENTIALS` (if using Azure)

### 2. Staging Environment
- **Name**: `staging`
- **Branch protection**: `develop` branch
- **Required secrets**:
  - `AWS_ACCESS_KEY_ID_STAGING`
  - `AWS_SECRET_ACCESS_KEY_STAGING`
  - `AZURE_CREDENTIALS` (if using Azure)

### 3. Production Environment
- **Name**: `production`
- **Branch protection**: `main` branch
- **Required secrets**:
  - `AWS_ACCESS_KEY_ID_PROD`
  - `AWS_SECRET_ACCESS_KEY_PROD`
  - `AZURE_CREDENTIALS` (if using Azure)

## Setup Instructions

### Step 1: Create GitHub Environments

1. Go to your GitHub repository
2. Navigate to **Settings** → **Environments**
3. Click **New environment** for each environment:
   - `development`
   - `staging`
   - `production`

### Step 2: Configure Environment Protection Rules

#### Development Environment
- **Deployment branches**: `develop`
- **Required reviewers**: Optional (recommended for team collaboration)
- **Wait timer**: 0 minutes

#### Staging Environment
- **Deployment branches**: `develop`
- **Required reviewers**: Required (at least 1)
- **Wait timer**: 5 minutes (recommended)

#### Production Environment
- **Deployment branches**: `main`
- **Required reviewers**: Required (at least 2)
- **Wait timer**: 10 minutes (recommended)

### Step 3: Add Environment Secrets

For each environment, add the corresponding AWS credentials:

#### Development Environment Secrets
```
AWS_ACCESS_KEY_ID_DEV=your_dev_access_key
AWS_SECRET_ACCESS_KEY_DEV=your_dev_secret_key
```

#### Staging Environment Secrets
```
AWS_ACCESS_KEY_ID_STAGING=your_staging_access_key
AWS_SECRET_ACCESS_KEY_STAGING=your_staging_secret_key
```

#### Production Environment Secrets
```
AWS_ACCESS_KEY_ID_PROD=your_prod_access_key
AWS_SECRET_ACCESS_KEY_PROD=your_prod_secret_key
```

## Branch-to-Environment Mapping

| Branch | Environment | Trigger | Approval Required |
|--------|-------------|---------|-------------------|
| `develop` | `development` | Auto | No |
| `develop` | `staging` | Auto | Yes (1 reviewer) |
| `main` | `production` | Auto | Yes (2 reviewers) |

## Pipeline Flow

1. **Code Quality & Security**: Runs on all branches
2. **Infrastructure Testing**: Uses development credentials for planning
3. **Development Deployment**: Auto-deploys to development environment
4. **Staging Deployment**: Requires approval, deploys to staging
5. **Production Deployment**: Requires approval, deploys to production

## Troubleshooting

### Common Issues

1. **Environment not found**: Ensure the environment name matches exactly in the workflow
2. **Secrets not accessible**: Verify secrets are added to the correct environment
3. **Approval not working**: Check environment protection rules and required reviewers
4. **Branch protection conflicts**: Ensure branch protection rules don't conflict with environment rules

### Verification Steps

1. **Test Development**: Push to `develop` branch
2. **Test Staging**: Create PR to `develop` branch
3. **Test Production**: Create PR to `main` branch

## Security Best Practices

1. **Use IAM roles with minimal permissions** for each environment
2. **Rotate access keys regularly**
3. **Enable MFA for all AWS accounts**
4. **Use environment-specific AWS accounts when possible**
5. **Monitor access logs and audit trails**

## Cost Management

1. **Development**: Use spot instances and smaller instance types
2. **Staging**: Use on-demand instances with moderate sizing
3. **Production**: Use reserved instances and appropriate sizing for production workloads

## Monitoring and Alerting

1. **Set up CloudWatch alarms** for each environment
2. **Configure Slack/Teams notifications** for deployment status
3. **Monitor resource usage** and costs per environment
4. **Set up automated cleanup** for development/staging resources
