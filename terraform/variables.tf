# ============================================
# GLOBAL VARIABLES
# ============================================

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "application"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    CreatedAt = "2026-01-13"
  }
}

# ============================================
# NETWORK VARIABLES
# ============================================

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
  description = "CIDR block for app private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "db_instance_private_subnet_cidr" {
  description = "CIDR block for DB private subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
  default     = true
}

# ============================================
# LOAD BALANCER VARIABLES
# ============================================

variable "alb_name" {
  description = "Application Load Balancer name"
  type        = string
  default     = "application-alb"
}

variable "alb_internal" {
  description = "ALB is internal"
  type        = bool
  default     = false
}

variable "target_group_health_check" {
  description = "Target group health check configuration"
  type = object({
    healthy_threshold   = number
    unhealthy_threshold = number
    timeout             = number
    interval            = number
    path                = string
    matcher             = string
  })
  default = {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    matcher             = "200"
  }
}

# ============================================
# AUTO SCALING VARIABLES
# ============================================

variable "asg_config" {
  description = "Auto Scaling Group configuration"
  type = object({
    name             = string
    min_size         = number
    max_size         = number
    desired_capacity = number
    health_check_grace_period = number
  })
  default = {
    name             = "app-asg"
    min_size         = 1
    max_size         = 3
    desired_capacity = 2
    health_check_grace_period = 300
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "cpu_scale_up_threshold" {
  description = "CPU threshold to scale up"
  type        = number
  default     = 70
}

variable "cpu_scale_down_threshold" {
  description = "CPU threshold to scale down"
  type        = number
  default     = 30
}

variable "scaling_adjustment_cooldown" {
  description = "Cooldown period for scaling adjustments (seconds)"
  type        = number
  default     = 300
}

# ============================================
# DATABASE VARIABLES
# ============================================

variable "db_config" {
  description = "RDS database configuration"
  type = object({
    identifier     = string
    engine         = string
    engine_version = string
    instance_class = string
    db_name        = string
    username       = string
    allocated_storage    = number
    max_allocated_storage = number
    storage_type         = string
    storage_encrypted    = bool
    multi_az             = bool
    backup_retention_period = number
    backup_window        = string
    maintenance_window   = string
  })
  default = {
    identifier     = "postgres-primary"
    engine         = "postgres"
    engine_version = "15.3"
    instance_class = "db.t3.micro"
    db_name        = "applicationdb"
    username       = "postgres"
    allocated_storage    = 20
    max_allocated_storage = 100
    storage_type         = "gp3"
    storage_encrypted    = true
    multi_az             = true
    backup_retention_period = 30
    backup_window        = "03:00-04:00"
    maintenance_window   = "mon:04:00-mon:05:00"
  }
}

variable "db_password_length" {
  description = "Password length for RDS"
  type        = number
  default     = 16
}

variable "create_read_replicas" {
  description = "Create RDS read replicas"
  type        = bool
  default     = true
}

variable "read_replica_count" {
  description = "Number of read replicas to create"
  type        = number
  default     = 2
}

# ============================================
# SECURITY VARIABLES
# ============================================

variable "security_group_rules" {
  description = "Security group ingress rules"
  type = map(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string))
    description = string
  }))
  default = {
    http = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP access"
    }
    https = {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS access"
    }
    ssh = {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH access"
    }
  }
}

# ============================================
# DNS VARIABLES
# ============================================

variable "dns_zone_name" {
  description = "Route 53 hosted zone name"
  type        = string
  default     = "painting.marketplace.com"
}

variable "dns_record_name" {
  description = "DNS A record name"
  type        = string
  default     = "painting.marketplace.com"
}

# ============================================
# TAGS VARIABLES
# ============================================

variable "vpc_tags" {
  description = "Tags for VPC resources"
  type        = map(string)
  default = {
    Name = "application-vpc"
  }
}

variable "igw_tags" {
  description = "Tags for Internet Gateway"
  type        = map(string)
  default = {
    Name = "application-igw"
  }
}

variable "alb_tags" {
  description = "Tags for ALB resources"
  type        = map(string)
  default = {
    Name = "application-alb"
  }
}

variable "db_tags" {
  description = "Tags for database resources"
  type        = map(string)
  default = {
    Name = "application-database"
  }
}