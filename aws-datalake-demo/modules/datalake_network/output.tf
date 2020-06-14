output "vpc_id" {
  value = aws_vpc.main.id
}

output "datalake_public_subnet_id" {
  value = aws_subnet.Subnet1.id
}

output "datalake_private_subnet_id" {
  value = aws_subnet.Subnet3.id
}

output "default_sg_id" {
  value = aws_security_group.DMZSecurityGroup.id
}

output "datagateway_sg_id" {
  value = aws_security_group.DataGatewaySecurityGroup.id
}



