terraform {
  backend "s3" {
    bucket         = "elo7-devops-engineer"
    key            = "terraform/ecs-staging/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "elo7_project-terraform-locking"
    encrypt        = true
  }
}

data "aws_caller_identity" "current" {
}

/*
data "aws_security_group" "selected" {
  name = "ecs-elo7"
}
*/

// Cria uma tabela no DynamoDB para lock do estado do terraform
module "dynamodb" {
  source               = "./modules/dynamodb"
  dynamo_db_table_name = "elo7_project-terraform-locking"
}

module "vpc" {
  source = "./modules/vpc"
  name   = "vpc-${var.ENVIRONMENT}"
  cidr   = "10.0.0.0/16"

  azs             = ["${var.AWS_REGION}a", "${var.AWS_REGION}b", "${var.AWS_REGION}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway                   = true # Cria NAT Gateway nas subnets privadas
  single_nat_gateway                   = true # Deve ser verdadeiro se você deseja provisionar UM ÚNICO NAT Gateway compartilhado em todas as subnets privadas
  enable_vpn_gateway                   = false
  enable_dns_hostnames                 = true
  enable_s3_endpoint                   = true  # Habilita VPC Endpoint para S3
  enable_sqs_endpoint                  = false # Habilita VPC Endpoint para SQS
  enable_ecr_api_endpoint              = false # Habilita VPC Endpoint para ECR
  enable_apigw_endpoint                = false # Habilita VPC Endpoint para API Gateway
  ecr_dkr_endpoint_private_dns_enabled = false # Se deve ou não associar uma zona privada ao VPC Endpoint especificado para ECR DKR

  #enable_ecr_dkr_endpoint             = true # Habilita VPC Endpoint para ECR dkr
  // O ID de um ou mais grupos de segurança a serem associados à interface de rede para o VPC Endpoint ECR DKR
  // É necessário 
  # ecr_dkr_endpoint_security_group_ids = [data.aws_security_group.selected.id]

  tags = {
    Terraform   = "true"
    Environment = var.ENVIRONMENT
  }
}

module "my-ecs" {
  source         = "./modules/ecs-cluster"
  VPC_ID         = module.vpc.vpc_id
  CLUSTER_NAME   = "ecs-elo7"
  INSTANCE_TYPE  = "t2.micro"
  SSH_KEY_NAME   = aws_key_pair.mykeypair.key_name
  VPC_SUBNETS    = join(",", module.vpc.private_subnets)
  ENABLE_SSH     = true
  SSH_SG         = aws_security_group.allow-ssh.id
  LOG_GROUP      = var.LOG_GROUP
  AWS_ACCOUNT_ID = data.aws_caller_identity.current.account_id
  AWS_REGION     = var.AWS_REGION
}

module "my-service" {
  source              = "./modules/ecs-service"
  VPC_ID              = module.vpc.vpc_id
  APPLICATION_NAME    = "my-service"
  APPLICATION_PORT    = "80"
  APPLICATION_VERSION = "latest"
  CLUSTER_ARN         = module.my-ecs.cluster_arn
  SERVICE_ROLE_ARN    = module.my-ecs.service_role_arn
  AWS_REGION          = var.AWS_REGION
  HEALTHCHECK_MATCHER = "200"
  CPU_RESERVATION     = "256"
  MEMORY_RESERVATION  = "128"
  LOG_GROUP           = "elo7"
  DESIRED_COUNT       = 2
  ALB_ARN             = module.my-alb.alb_arn
}

module "my-alb" {
  source             = "./modules/alb"
  VPC_ID             = module.vpc.vpc_id
  ALB_NAME           = "my-alb"
  VPC_SUBNETS        = join(",", module.vpc.public_subnets)
  DEFAULT_TARGET_ARN = module.my-service.target_group_arn
  #  DOMAIN             = "*.ecs.elo"
  INTERNAL = false
  ECS_SG   = module.my-ecs.cluster_sg
}

module "my-alb-rule" {
  source           = "./modules/alb-rule"
  LISTENER_ARN     = module.my-alb.http_listener_arn
  PRIORITY         = 100
  TARGET_GROUP_ARN = module.my-service.target_group_arn
  CONDITION_FIELD  = "host-header"
  CONDITION_VALUES = ["subdomain.ecs.elo"]
}

