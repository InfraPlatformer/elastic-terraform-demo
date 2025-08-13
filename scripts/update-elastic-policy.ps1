# PowerShell script to update the existing IAM policy with new permissions
# Run this script with appropriate AWS credentials that have admin access

param(
    [string]$PolicyName = "ElasticTerraformPolicy"
)

Write-Host "Updating IAM policy: $PolicyName" -ForegroundColor Green

# Get the current policy ARN
Write-Host "Getting current policy ARN..." -ForegroundColor Yellow
$policyArn = aws iam list-policies --query "Policies[?PolicyName=='$PolicyName'].Arn" --output text

if ($LASTEXITCODE -eq 0 -and $policyArn) {
    Write-Host "Found policy: $policyArn" -ForegroundColor Green
} else {
    Write-Host "Policy not found. Please check the policy name." -ForegroundColor Red
    exit 1
}

# Get the current policy version
Write-Host "Getting current policy version..." -ForegroundColor Yellow
$currentVersion = aws iam get-policy --policy-arn $policyArn --query 'Policy.DefaultVersionId' --output text

if ($LASTEXITCODE -eq 0) {
    Write-Host "Current version: $currentVersion" -ForegroundColor Green
} else {
    Write-Host "Failed to get policy version." -ForegroundColor Red
    exit 1
}

# Create new policy version
Write-Host "Creating new policy version..." -ForegroundColor Yellow
$policyContent = Get-Content -Path "..\elastic-permissions-policy.json" -Raw

aws iam create-policy-version --policy-arn $policyArn --policy-document $policyContent --set-as-default

if ($LASTEXITCODE -eq 0) {
    Write-Host "New policy version created successfully" -ForegroundColor Green
} else {
    Write-Host "Failed to create new policy version." -ForegroundColor Red
    exit 1
}

# Delete the old version (optional - only if you want to clean up)
Write-Host "Deleting old policy version..." -ForegroundColor Yellow
aws iam delete-policy-version --policy-arn $policyArn --version-id $currentVersion

if ($LASTEXITCODE -eq 0) {
    Write-Host "Old policy version deleted successfully" -ForegroundColor Green
} else {
    Write-Host "Failed to delete old policy version (this is not critical)." -ForegroundColor Yellow
}

Write-Host "Policy updated successfully!" -ForegroundColor Green
Write-Host "You can now run: terraform plan" -ForegroundColor Cyan

