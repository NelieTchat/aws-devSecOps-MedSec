output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID."
}

output "private_subnet_ids" {
  value       = [for s in aws_subnet.private_subnets : s.id]
  description = "Private subnet IDs."
}

output "public_subnet_ids" {
  value       = [for s in aws_subnet.public_subnets : s.id]
  description = "Public subnet IDs (if enabled)."
}

output "private_route_table_ids" {
  value       = [for rt in aws_route_table.private_rts : rt.id]
  description = "Private route table IDs."
}

output "azs" {
  value       = local.azs
  description = "AZs used for subnets."
}
