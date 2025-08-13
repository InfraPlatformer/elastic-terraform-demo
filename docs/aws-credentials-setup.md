# AWS Credentials Setup for Elastic Terraform

This guide will help you set up AWS credentials with the necessary permissions to deploy and manage your Elasticsearch infrastructure using Terraform.

## Option 1: Create IAM User with Elastic Permissions (Recommended)

### Step 1: Create IAM Policy
1. Go to AWS Console → IAM → Policies → Create Policy
2. Choose JSON tab and paste the contents of `elastic-permissions-policy.json`
3. Name: `ElasticTerraformPolicy`
4. Description: `Policy for managing Elasticsearch infrastructure with Terraform`

### Step 2: Create IAM User
1. Go to AWS Console → IAM → Users → Create User
2. Username: `elastic-terraform-user`
3. Access type: Programmatic access
4. Attach the `ElasticTerraformPolicy` created in Step 1

### Step 3: Get Access Keys
1. After creating the user, go to Security credentials tab
2. Create access key
3. Save the Access Key ID and Secret Access Key

## Option 2: Use Existing IAM User/Role

If you already have an IAM user or role, ensure it has these permissions:
- `es:*` - Elasticsearch Service
- `eks:*` - EKS (Kubernetes)
- `ec2:*` - EC2 (VPC, Security Groups, etc.)
- `iam:*` - IAM (Roles, Policies)
- `s3:*` - S3 (Backups)
- `elasticloadbalancing:*` - Load Balancers
- `autoscaling:*` - Auto Scaling Groups

## Option 3: Use AWS SSO

If your organization uses AWS SSO:
```bash
aws configure sso
```

## Configure Credentials

### Method 1: AWS CLI Profile
```bash
aws configure --profile elastic-terraform
# Enter your Access Key ID, Secret Access Key, and Region (us-west-2)
```

### Method 2: Environment Variables
```powershell
# PowerShell
$env:AWS_ACCESS_KEY_ID="your_access_key_here"
$env:AWS_SECRET_ACCESS_KEY="your_secret_key_here"
$env:AWS_DEFAULT_REGION="us-west-2"
```

```bash
# Bash
export AWS_ACCESS_KEY_ID="your_access_key_here"
export AWS_SECRET_ACCESS_KEY="your_secret_key_here"
export AWS_DEFAULT_REGION="us-west-2"
```

### Method 3: AWS Credentials File
Create `~/.aws/credentials`:
```ini
[elastic-terraform]
aws_access_key_id = your_access_key_here
aws_secret_access_key = your_secret_key_here
```

Create `~/.aws/config`:
```ini
[profile elastic-terraform]
region = us-west-2
output = json
```

## Test Your Credentials

```bash
# Test with default profile
aws sts get-caller-identity

# Test with specific profile
aws sts get-caller-identity --profile elastic-terraform

# Test with environment variables
aws sts get-caller-identity
```

## Deploy with Terraform

Once credentials are configured:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Security Best Practices

1. **Principle of Least Privilege**: Only grant necessary permissions
2. **Rotate Keys Regularly**: Change access keys every 90 days
3. **Use IAM Roles**: For EC2 instances, use IAM roles instead of access keys
4. **Monitor Usage**: Enable CloudTrail to monitor API calls
5. **MFA**: Enable Multi-Factor Authentication for IAM users

## Troubleshooting

### Common Errors

**InvalidClientTokenId**: Credentials are invalid or expired
- Check your access key and secret key
- Verify the credentials haven't expired
- Ensure you're using the correct profile

**Access Denied**: Insufficient permissions
- Verify the IAM policy is attached to your user
- Check if the policy has the required permissions
- Ensure you're in the correct AWS region

**Region Mismatch**: Resources in different regions
- Verify your AWS region configuration
- Check Terraform variables for region settings
- Ensure all resources are in the same region

### Getting Help

1. Check AWS CloudTrail for detailed error logs
2. Verify IAM permissions in AWS Console
3. Test individual AWS CLI commands
4. Check Terraform logs with `TF_LOG=DEBUG terraform plan`

