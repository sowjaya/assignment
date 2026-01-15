# AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "app_instance_private_subnet_cidr" {
  description = "CIDR block for first private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "db_instance_private_subnet_cidr" {
  description = "CIDR block for second private subnet"
  type        = string
  default     = "10.0.3.0/24"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "application-vpc"
  }
}


# Public Subnet
resource "aws_subnet" "app_public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "app_public_subnet"
    Type = "Public"
  }
}

# Private Subnet App Instance
resource "aws_subnet" "app_instance_private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.app_instance_private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "app_instance_private_subnet"
    Type = "Private"
  }
}

# Private Subnet DB Istance
resource "aws_subnet" "db_instance_private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_instance_private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "db_instance_private_subnet"
    Type = "Private"
  }
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Route Table Association for Public Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.app_public_subnet.id
  route_table_id = aws_route_table.public.id
}


# ============================================
# OUTPUTS
# ============================================

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.app_public_subnet.id
}

output "private_subnet_1_id" {
  description = "Private App subnet ID"
  value       = aws_subnet.app_instance_private_subnet.id
}

output "private_subnet_2_id" {
  description = "Private DB subnet ID"
  value       = aws_subnet.db_instance_private_subnet.id
}




# Route Table for Private Subnet App Instance
resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "private-app-rt"
  }
}

# Route Table Association for Private Subnet App Instance
resource "aws_route_table_association" "private_app" {
  subnet_id      = aws_subnet.app_instance_private_subnet.id
  route_table_id = aws_route_table.private_app.id
}

# Route Table for Private Subnet DB Instance
resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "private-db-rt"
  }
}

# Route Table Association for Private Subnet DB Instance
resource "aws_route_table_association" "private_db" {
  subnet_id      = aws_subnet.db_instance_private_subnet.id
  route_table_id = aws_route_table.private_db.id
}
