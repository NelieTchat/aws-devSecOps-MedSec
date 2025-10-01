########################################
# VPC Gateway Endpoints (env layer)
########################################

# Resolve services (no deprecated .name usage)
data "aws_vpc_endpoint_service" "s3" {
  service_type = "Gateway"
  service      = "s3"
}

data "aws_vpc_endpoint_service" "dynamodb" {
  service_type = "Gateway"
  service      = "dynamodb"
}

# Find the route table for each private subnet (then de-dup)
data "aws_route_table" "private_by_subnet" {
  for_each  = toset(module.network.private_subnet_ids)
  subnet_id = each.value
  # Ensure module finishes creating before we query
  depends_on = [module.network]
}

locals {
  private_route_table_ids = tolist(toset([for rt in data.aws_route_table.private_by_subnet : rt.id]))
}

# S3 Gateway endpoint
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = module.network.vpc_id
  vpc_endpoint_type = "Gateway"
  service_name      = data.aws_vpc_endpoint_service.s3.service_name
  route_table_ids   = local.private_route_table_ids
  tags              = merge(local.common_tags, { Name = "medsec-dev-vpce-s3" })
}

# DynamoDB Gateway endpoint (optional—delete if not needed)
resource "aws_vpc_endpoint" "dynamodb_gateway" {
  vpc_id            = module.network.vpc_id
  vpc_endpoint_type = "Gateway"
  service_name      = data.aws_vpc_endpoint_service.dynamodb.service_name
  route_table_ids   = local.private_route_table_ids
  tags              = merge(local.common_tags, { Name = "medsec-dev-vpce-dynamodb" })
}
