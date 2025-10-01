data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # Interface endpoints commonly needed for private ECS/Fargate
  interface_services = [
    "ecr.api",
    "ecr.dkr",
    "logs",
    "secretsmanager",
    "ssm",
    "ec2",
    "ecs",
    "ecs-agent",
    "ecs-telemetry",
    "sts"
  ]
}

# ---------------- VPC ----------------
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.name}-vpc"
  })
}
# ------------- Internet Gateway -------------
# Internet Gateway (only if public subnets enabled)
resource "aws_internet_gateway" "igw" {
  count  = var.enable_public_subnets ? 1 : 0
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "${var.name}-igw" })
}

# ------------- Public Subnets -------------
resource "aws_subnet" "public_subnets" {
  for_each                = var.enable_public_subnets ? toset(local.azs) : []
  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.value
  cidr_block              = cidrsubnet(var.cidr_block, var.public_subnet_newbits, 200 + index(local.azs, each.value))
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name = "${var.name}-public-${each.value}"
    Tier = "public"
  })
}

# One public route table, 0.0.0.0/0 via IGW
resource "aws_route_table" "public_rt" {
  count  = var.enable_public_subnets ? 1 : 0
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "${var.name}-public-rt" })
}

resource "aws_route" "public_igw" {
  count                  = var.enable_public_subnets ? 1 : 0
  route_table_id         = aws_route_table.public_rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt[0].id
}


# ------------- Private Subnets -------------
resource "aws_subnet" "private_subnets" {
  for_each                            = toset(local.azs)
  vpc_id                              = aws_vpc.main.id
  availability_zone                   = each.value
  cidr_block                          = cidrsubnet(var.cidr_block, var.subnet_newbits, index(local.azs, each.value))
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "resource-name"

  tags = merge(var.tags, {
    Name = "${var.name}-private-${each.value}"
    Tier = "private"
  })
}

# ------------- Route Tables (private only) -------------
resource "aws_route_table" "private_rts" {
  for_each = aws_subnet.private_subnets
  vpc_id   = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.name}-rt-${each.key}"
  })
}

resource "aws_route_table_association" "private_assoc" {
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rts[each.key].id
}

# # ------------- VPC Endpoints (optional) -------------

# # S3 Gateway endpoint (for ECR layer pulls)
# # Resolve service names instead of concatenating with the region
# data "aws_vpc_endpoint_service" "s3" {
#   service_type = "Gateway"
#   service      = "s3"
# }

# data "aws_vpc_endpoint_service" "dynamodb" {
#   service_type = "Gateway"
#   service      = "dynamodb"
# }

# resource "aws_vpc_endpoint" "s3_gateway" {
#   vpc_id            = aws_vpc.vpc.id
#   service_name      = data.aws_vpc_endpoint_service.s3.service_name
#   vpc_endpoint_type = "Gateway"
#   route_table_ids   = aws_route_table.private[*].id
#   tags              = merge(var.tags, { Name = "${var.name}-vpce-s3" })
# }

# resource "aws_vpc_endpoint" "dynamodb_gateway" {
#   vpc_id            = aws_vpc.vpc.id
#   service_name      = data.aws_vpc_endpoint_service.dynamodb.service_name
#   vpc_endpoint_type = "Gateway"
#   route_table_ids   = aws_route_table.private[*].id
#   tags              = merge(var.tags, { Name = "${var.name}-vpce-dynamodb" })
# }

# resource "aws_vpc_endpoint_route_table_association" "s3_assoc" {
#   for_each        = var.enable_endpoints ? aws_route_table.private_rts : {}
#   vpc_endpoint_id = aws_vpc_endpoint.s3_gateway[0].id
#   route_table_id  = each.value.id
# }

# # SG for Interface Endpoints
# resource "aws_security_group" "vpce_sg" {
#   count       = var.enable_endpoints ? 1 : 0
#   name        = "${var.name}-vpce-sg"
#   description = "Security group for VPC Interface Endpoints"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = [aws_vpc.main.cidr_block]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = [aws_vpc.main.cidr_block]
#   }

#   tags = merge(var.tags, {
#     Name = "${var.name}-vpce-sg"
#   })
# }
