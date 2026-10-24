terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

module "vpc" {
  source = "./modules/VPC"

  vpc_cidr            = var.vpc_cidr
  availability_zone   = var.availability_zone
  private_subnet_cidr = var.private_subnet_cidr
  public_subnet_cidr  = var.public_subnet_cidr
}

