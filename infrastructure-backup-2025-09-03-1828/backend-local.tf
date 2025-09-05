# =============================================================================
# LOCAL DEVELOPMENT BACKEND CONFIGURATION
# =============================================================================
# This file provides a local backend for development without AWS credentials
# Comment out or remove this file when deploying to production
# =============================================================================

# Uncomment the following block to use local backend for development
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# Comment out the S3 backend for local development
# terraform {
#   backend "s3" {
#     bucket = "elastic-terraform-state-2024-alamz"
#     key    = "advanced-elastic/terraform.tfstate"
#     region = "us-west-2"
#     encrypt = true
#   }
# }

