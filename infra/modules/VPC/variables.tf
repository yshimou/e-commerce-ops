variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnets"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnets"
  type        = string
}