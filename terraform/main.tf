terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }

  backend "s3" {
    bucket         = "replace-with-your-terraform-state-bucket"
    key            = "eks/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "replace-with-your-terraform-lock-table"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "Secure-DevSecOps-Reference"
      Environment = "production"
      ManagedBy   = "Terraform"
    }
  }
}
