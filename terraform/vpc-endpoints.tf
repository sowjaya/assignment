# ============================================
# VPC ENDPOINTS
# ============================================

# ============================================
# S3 Gateway Endpoint
# ============================================

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  
  route_table_ids = [
    aws_route_table.public.id,
    aws_route_table.private_app.id,
    aws_route_table.private_db.id
  ]

  tags = {
    Name = "s3-endpoint"
  }
}

# S3 Endpoint Policy
resource "aws_vpc_endpoint_policy" "s3" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = "*"
      }
    ]
  })
}

# ============================================
# SQS Interface Endpoint
# ============================================

# Security Group for SQS Endpoint
resource "aws_security_group" "sqs_endpoint_sg" {
  name_prefix = "sqs-endpoint-sg-"
  description = "Security group for SQS VPC endpoint"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sqs-endpoint-sg"
  }
}

# SQS Interface Endpoint
resource "aws_vpc_endpoint" "sqs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.sqs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids          = [
    aws_subnet.app_instance_private_subnet.id,
    aws_subnet.db_instance_private_subnet.id
  ]

  security_group_ids  = [aws_security_group.sqs_endpoint_sg.id]

  tags = {
    Name = "sqs-endpoint"
  }
}

# SQS Endpoint Policy
resource "aws_vpc_endpoint_policy" "sqs" {
  vpc_endpoint_id = aws_vpc_endpoint.sqs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = "*"
      }
    ]
  })
}

# ============================================
# OUTPUTS
# ============================================

output "s3_endpoint_id" {
  description = "S3 Gateway Endpoint ID"
  value       = aws_vpc_endpoint.s3.id
}

output "sqs_endpoint_id" {
  description = "SQS Interface Endpoint ID"
  value       = aws_vpc_endpoint.sqs.id
}

output "sqs_endpoint_dns" {
  description = "SQS Endpoint DNS name"
  value       = aws_vpc_endpoint.sqs.dns_entry[0].dns_name
}

output "sqs_endpoint_network_interface_ids" {
  description = "SQS Endpoint Network Interface IDs"
  value       = aws_vpc_endpoint.sqs.network_interface_ids
}