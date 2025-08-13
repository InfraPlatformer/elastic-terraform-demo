# PowerShell script to create IAM user with Elastic permissions
# Run this script with appropriate AWS credentials that have admin access

param(
    [string]$UserName = "elastic-terraform-user",
    [string]$PolicyName = "ElasticTerraformPolicy"
)

Write-Host "Setting up IAM user with Elastic permissions..." -ForegroundColor Green

# Create the IAM policy
Write-Host "Creating IAM policy: $PolicyName" -ForegroundColor Yellow
$policyContent = Get-Content -Path "..\elastic-permissions-policy.json" -Raw
$policyArn = aws iam create-policy --policy-name $PolicyName --policy-document $policyContent --query 'Policy.Arn' --output text

if ($LASTEXITCODE -eq 0) {
    Write-Host "Policy created successfully: $policyArn" -ForegroundColor Green
} else {
    Write-Host "Failed to create policy. Please check your AWS credentials and permissions." -ForegroundColor Red
    exit 1
}

# Create the IAM user
Write-Host "Creating IAM user: $UserName" -ForegroundColor Yellow
aws iam create-user --user-name $UserName

if ($LASTEXITCODE -eq 0) {
    Write-Host "User created successfully" -ForegroundColor Green
} else {
    Write-Host "Failed to create user. Please check your AWS credentials and permissions." -ForegroundColor Red
    exit 1
}

# Attach the policy to the user
Write-Host "Attaching policy to user..." -ForegroundColor Yellow
aws iam attach-user-policy --user-name $UserName --policy-arn $policyArn

if ($LASTEXITCODE -eq 0) {
    Write-Host "Policy attached successfully" -ForegroundColor Green
} else {
    Write-Host "Failed to attach policy." -ForegroundColor Red
    exit 1
}

# Create access keys for the user
Write-Host "Creating access keys..." -ForegroundColor Yellow
$accessKeys = aws iam create-access-key --user-name $UserName --query 'AccessKey' --output json | ConvertFrom-Json

if ($LASTEXITCODE -eq 0) {
    Write-Host "Access keys created successfully" -ForegroundColor Green
    Write-Host ""
    Write-Host "=== AWS CREDENTIALS FOR TERRAFORM ===" -ForegroundColor Cyan
    Write-Host "Access Key ID: $($accessKeys.AccessKeyId)" -ForegroundColor White
    Write-Host "Secret Access Key: $($accessKeys.SecretAccessKey)" -ForegroundColor White
    Write-Host ""
    Write-Host "=== NEXT STEPS ===" -ForegroundColor Cyan
    Write-Host "1. Configure these credentials in your AWS CLI:" -ForegroundColor White
    Write-Host "   aws configure --profile elastic-terraform" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "2. Or set environment variables:" -ForegroundColor White
    Write-Host "   `$env:AWS_ACCESS_KEY_ID=`"$($accessKeys.AccessKeyId)`"" -ForegroundColor Yellow
    Write-Host "   `$env:AWS_SECRET_ACCESS_KEY=`"$($accessKeys.SecretAccessKey)`"" -ForegroundColor Yellow
    Write-Host "   `$env:AWS_DEFAULT_REGION=`"us-west-2`"" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "3. Test the credentials:" -ForegroundColor White
    Write-Host "   aws sts get-caller-identity --profile elastic-terraform" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "4. Run Terraform:" -ForegroundColor White
    Write-Host "   terraform plan" -ForegroundColor Yellow
    Write-Host "   terraform apply" -ForegroundColor Yellow
} else {
    Write-Host "Failed to create access keys." -ForegroundColor Red
    exit 1
}

Write-Host "Setup completed successfully!" -ForegroundColor Green

