# ============================================
# TERRAFORM CONFIGURATION VALUES
# ============================================

aws_region  = "us-east-1"
project_name = "painting-marketplace"
environment = "dev"

# ============================================
# NETWORK CONFIGURATION
# ============================================

vpc_cidr                             = "10.0.0.0/16"
public_subnet_cidr                   = "10.0.1.0/24"
app_instance_private_subnet_cidr     = "10.0.2.0/24"
db_instance_private_subnet_cidr      = "10.0.3.0/24"
enable_dns_hostnames                 = true
enable_dns_support                   = true

# ============================================
# LOAD BALANCER CONFIGURATION
# ============================================

alb_name     = "application-alb"
alb_internal = false

target_group_health_check = {
  healthy_threshold   = 2
  unhealthy_threshold = 2
  timeout             = 3
  interval            = 30
  path                = "/"
  matcher             = "200"
}

# ============================================
# AUTO SCALING CONFIGURATION
# ============================================

instance_type               = "t2.micro"
cpu_scale_up_threshold      = 70
cpu_scale_down_threshold    = 30
scaling_adjustment_cooldown = 300

asg_config = {
  name             = "app-asg"
  min_size         = 1
  max_size         = 3
  desired_capacity = 2
  health_check_grace_period = 300
}

# ============================================
# DATABASE CONFIGURATION
# ============================================

db_password_length = 16
create_read_replicas = true
read_replica_count = 2

db_config = {
  identifier              = "postgres-primary"
  engine                  = "postgres"
  engine_version          = "15.3"
  instance_class          = "db.t3.micro"
  db_name                 = "applicationdb"
  username                = "postgres"
  allocated_storage       = 20
  max_allocated_storage   = 100
  storage_type            = "gp3"
  storage_encrypted       = true
  multi_az                = true
  backup_retention_period = 30
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"
}

# ============================================
# SECURITY CONFIGURATION
# ============================================

security_group_rules = {
  http = {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from internet"
  }
  https = {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from internet"
  }
  ssh = {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH from internet"
  }
}

# ============================================
# DNS CONFIGURATION
# ============================================

dns_zone_name    = "painting.marketplace.com"
dns_record_name  = "painting.marketplace.com"

# ============================================
# TAGS
# ============================================

common_tags = {
  ManagedBy   = "Terraform"
  Environment = "dev"
  Project     = "painting-marketplace"
  CreatedAt   = "2026-01-13"
}

vpc_tags = {
  Name = "application-vpc"
}

igw_tags = {
  Name = "application-igw"
}

alb_tags = {
  Name = "application-alb"
}

db_tags = {
  Name = "application-database"
}