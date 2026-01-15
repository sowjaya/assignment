# ============================================
# LOCAL VALUES
# ============================================

locals {
  # Common naming convention
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Merged tags
  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      Project     = var.project_name
    }
  )
  
  # Resource naming
  vpc_name                    = "${local.name_prefix}-vpc"
  igw_name                    = "${local.name_prefix}-igw"
  nat_gateway_name            = "${local.name_prefix}-nat-gw"
  public_subnet_name          = "${local.name_prefix}-public-subnet"
  app_private_subnet_name     = "${local.name_prefix}-app-subnet"
  db_private_subnet_name      = "${local.name_prefix}-db-subnet"
  public_rt_name              = "${local.name_prefix}-public-rt"
  private_app_rt_name         = "${local.name_prefix}-private-app-rt"
  private_db_rt_name          = "${local.name_prefix}-private-db-rt"
  
  alb_sg_name                 = "${local.name_prefix}-alb-sg"
  public_sg_name              = "${local.name_prefix}-public-sg"
  app_sg_name                 = "${local.name_prefix}-app-sg"
  db_sg_name                  = "${local.name_prefix}-db-sg"
  
  public_nacl_name            = "${local.name_prefix}-public-nacl"
  private_nacl_name           = "${local.name_prefix}-private-nacl"
  
  db_subnet_group_name        = "${local.name_prefix}-db-subnet-group"
  
  ec2_app_role_name           = "${local.name_prefix}-ec2-app-role"
  lambda_role_name            = "${local.name_prefix}-lambda-role"
  asg_role_name               = "${local.name_prefix}-asg-role"
  rds_monitoring_role_name    = "${local.name_prefix}-rds-monitoring-role"
}