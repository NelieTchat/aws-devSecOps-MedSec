output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID."
}

output "private_subnet_ids" {
  value       = [for s in aws_subnet.private_subnets : s.id]
  description = "Private subnet IDs."
}

output "public_subnet_ids" {
  value       = try([for s in aws_subnet.public_subnets : s.id], [])
  description = "Public subnet IDs (if enabled)."
}

output "azs" {
  value       = [for s in aws_subnet.private_subnets : s.availability_zone]
  description = "AZs used for subnets."
}
