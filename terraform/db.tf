# ============================================
# RDS SUBNET GROUP
# ============================================

resource "aws_db_subnet_group" "main" {
  name_prefix = "db-subnet-group-"
  subnet_ids  = [
    aws_subnet.db_instance_private_subnet.id,
    aws_subnet.app_instance_private_subnet.id
  ]

  tags = {
    Name = "db-subnet-group"
  }
}

# ============================================
# RDS POSTGRES - PRIMARY INSTANCE
# ============================================

resource "aws_db_instance" "postgres_primary" {
  identifier     = "postgres-primary"
  engine         = "postgres"
  engine_version = "15.3"
  instance_class = "db.t3.medium"

  allocated_storage    = 20
  max_allocated_storage = 100
  storage_type        = "gp3"
  storage_encrypted   = true

  db_name  = "applicationdb"
  username = "postgres"
  password = random_password.db_password.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  # Multi-AZ Configuration
  multi_az               = true
  availability_zone      = data.aws_availability_zones.available.names[0]

  # Backup Configuration
  backup_retention_period = 30
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"

  # Performance and Monitoring
  performance_insights_enabled    = true
  performance_insights_retention_period = 7
  enabled_cloudwatch_logs_exports = ["postgresql"]
  monitoring_interval             = 60
  monitoring_role_arn             = aws_iam_role.rds_monitoring.arn

  # Deletion Protection
  deletion_protection = true
  skip_final_snapshot = false
  final_snapshot_identifier = "postgres-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  tags = {
    Name = "postgres-primary"
  }

  depends_on = [aws_security_group.db_sg]
}

# ============================================
# RDS READ REPLICA - AZ2
# ============================================

resource "aws_db_instance" "postgres_replica_1" {
  identifier          = "postgres-replica-1"
  replicate_source_db = aws_db_instance.postgres_primary.identifier
  instance_class      = "db.t3.medium"

  availability_zone = data.aws_availability_zones.available.names[1]
  storage_encrypted = true

  performance_insights_enabled = true
  monitoring_interval          = 60
  monitoring_role_arn          = aws_iam_role.rds_monitoring.arn

  skip_final_snapshot = true

  tags = {
    Name = "postgres-replica-1"
  }

  depends_on = [aws_db_instance.postgres_primary]
}

# ============================================
# RDS READ REPLICA - AZ3
# ============================================

resource "aws_db_instance" "postgres_replica_2" {
  identifier          = "postgres-replica-2"
  replicate_source_db = aws_db_instance.postgres_primary.identifier
  instance_class      = "db.t3.medium"

  availability_zone = data.aws_availability_zones.available.names[0]
  storage_encrypted = true

  performance_insights_enabled = true
  monitoring_interval          = 60
  monitoring_role_arn          = aws_iam_role.rds_monitoring.arn

  skip_final_snapshot = true

  tags = {
    Name = "postgres-replica-2"
  }

  depends_on = [aws_db_instance.postgres_primary]
}

# ============================================
# RANDOM PASSWORD FOR DB
# ============================================

resource "random_password" "db_password" {
  length  = 16
  special = true
}

# ============================================
# SECRETS MANAGER - STORE DB PASSWORD
# ============================================

resource "aws_secretsmanager_secret" "db_password" {
  name_prefix             = "postgres-password-"
  recovery_window_in_days = 7

  tags = {
    Name = "postgres-password"
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = "postgres"
    password = random_password.db_password.result
    engine   = "postgres"
    host     = aws_db_instance.postgres_primary.address
    port     = aws_db_instance.postgres_primary.port
    dbname   = "applicationdb"
  })
}

# ============================================
# IAM ROLE FOR RDS MONITORING
# ============================================

resource "aws_iam_role" "rds_monitoring" {
  name_prefix = "rds-monitoring-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# ============================================
# OUTPUTS
# ============================================

output "db_primary_endpoint" {
  description = "Primary RDS endpoint"
  value       = aws_db_instance.postgres_primary.endpoint
}

output "db_primary_address" {
  description = "Primary RDS address"
  value       = aws_db_instance.postgres_primary.address
}

output "db_replica_1_endpoint" {
  description = "Read Replica 1 endpoint"
  value       = aws_db_instance.postgres_replica_1.endpoint
}

output "db_replica_2_endpoint" {
  description = "Read Replica 2 endpoint"
  value       = aws_db_instance.postgres_replica_2.endpoint
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.postgres_primary.db_name
}

output "db_username" {
  description = "Database username"
  value       = aws_db_instance.postgres_primary.username
  sensitive   = true
}

output "db_password_secret_arn" {
  description = "Secrets Manager secret ARN for DB password"
  value       = aws_secretsmanager_secret.db_password.arn
}

output "db_security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.db_sg.id
}