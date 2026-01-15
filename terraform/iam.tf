# ============================================
# IAM ROLES AND POLICIES
# ============================================

# ============================================
# EC2 INSTANCE ROLE FOR APP SERVERS
# ============================================

resource "aws_iam_role" "ec2_app_role" {
  name_prefix = "ec2-app-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "ec2-app-role"
  }
}

resource "aws_iam_instance_profile" "ec2_app_profile" {
  name_prefix = "ec2-app-profile-"
  role        = aws_iam_role.ec2_app_role.name
}

# Policy: EC2 to access S3 for application data
resource "aws_iam_role_policy" "ec2_s3_policy" {
  name_prefix = "ec2-s3-policy-"
  role        = aws_iam_role.ec2_app_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::application-bucket",
          "arn:aws:s3:::application-bucket/*"
        ]
      }
    ]
  })
}

# Policy: EC2 to access SQS
resource "aws_iam_role_policy" "ec2_sqs_policy" {
  name_prefix = "ec2-sqs-policy-"
  role        = aws_iam_role.ec2_app_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = "arn:aws:sqs:${var.aws_region}:*:application-queue"
      }
    ]
  })
}

# Policy: EC2 to access RDS
resource "aws_iam_role_policy" "ec2_rds_policy" {
  name_prefix = "ec2-rds-policy-"
  role        = aws_iam_role.ec2_app_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-db:connect"
        ]
        Resource = "arn:aws:rds:${var.aws_region}:*:db/applicationdb"
      }
    ]
  })
}

# Policy: EC2 to retrieve secrets from Secrets Manager
resource "aws_iam_role_policy" "ec2_secrets_policy" {
  name_prefix = "ec2-secrets-policy-"
  role        = aws_iam_role.ec2_app_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.db_password.arn
      }
    ]
  })
}

# Policy: CloudWatch Logs for application logging
resource "aws_iam_role_policy" "ec2_cloudwatch_logs_policy" {
  name_prefix = "ec2-cloudwatch-logs-policy-"
  role        = aws_iam_role.ec2_app_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:*:log-group:/aws/ec2/application*"
      }
    ]
  })
}

# Policy: EC2 Systems Manager Session Manager for secure access
resource "aws_iam_role_policy_attachment" "ec2_ssm_policy" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ============================================
# RDS MONITORING ROLE
# ============================================

# Already defined in db.tf - reference here for completeness
# This role is created in db.tf to avoid duplication

# ============================================
# LAMBDA EXECUTION ROLE (for future serverless workloads)
# ============================================

resource "aws_iam_role" "lambda_execution_role" {
  name_prefix = "lambda-execution-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "lambda-execution-role"
  }
}

# Lambda basic execution policy (CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda VPC execution policy (for private subnet access)
resource "aws_iam_role_policy_attachment" "lambda_vpc_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Lambda to access S3
resource "aws_iam_role_policy" "lambda_s3_policy" {
  name_prefix = "lambda-s3-policy-"
  role        = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::application-bucket/*"
      }
    ]
  })
}

# Lambda to access SQS
resource "aws_iam_role_policy" "lambda_sqs_policy" {
  name_prefix = "lambda-sqs-policy-"
  role        = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ]
        Resource = "arn:aws:sqs:${var.aws_region}:*:application-queue"
      }
    ]
  })
}

# ============================================
# AUTO SCALING SERVICE ROLE
# ============================================

resource "aws_iam_role" "asg_service_role" {
  name_prefix = "asg-service-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "autoscaling.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "asg-service-role"
  }
}

resource "aws_iam_role_policy_attachment" "asg_service_policy" {
  role       = aws_iam_role.asg_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ServiceRoleForAutoScaling"
}

# ============================================
# OUTPUTS
# ============================================

output "ec2_app_role_arn" {
  description = "ARN of EC2 app instance role"
  value       = aws_iam_role.ec2_app_role.arn
}

output "ec2_app_instance_profile_arn" {
  description = "ARN of EC2 app instance profile"
  value       = aws_iam_instance_profile.ec2_app_profile.arn
}

output "lambda_execution_role_arn" {
  description = "ARN of Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.arn
}

output "asg_service_role_arn" {
  description = "ARN of ASG service role"
  value       = aws_iam_role.asg_service_role.arn
}