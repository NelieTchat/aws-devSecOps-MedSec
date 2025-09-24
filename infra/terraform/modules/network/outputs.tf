output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private_subnets : s.id]
}

output "azs" {
  value = [for s in aws_subnet.private_subnets : s.availability_zone]
}
