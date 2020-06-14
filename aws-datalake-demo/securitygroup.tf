
resource "aws_security_group" "DMZSecurityGroup" {
  vpc_id      = aws_vpc.main.id
  name        = "DMZSecurityGroup"
  description = "Allow RDP to access Jump Box from my IP"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DMZSecurityGroup"
  }
}


resource "aws_security_group" "DataGatewaySecurityGroup" {
  vpc_id      = aws_vpc.main.id
  name        = "DataGatewaySecurityGroup"
  description = "Allow RDP to Data Gateway from Jump Box"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DataGatewaySecurityGroup"
  }
}

# resource "aws_security_group" "RedshiftSecurityGroup" {
#   vpc_id      = aws_vpc.main.id
#   name        = "RedshiftSecurityGroup"
#   description = "Security group for Redshift"
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 5439
#     to_port     = 5439
#     protocol    = "tcp"
#     cidr_blocks = ["172.16.0.0/24"]
#   }

#   ingress {
#     from_port   = 5439
#     to_port     = 5439
#     protocol    = "tcp"
#     cidr_blocks = ["172.16.1.0/24"]
#   }

#   ingress {
#     from_port   = 5439
#     to_port     = 5439
#     protocol    = "tcp"
#     cidr_blocks = ["172.16.2.0/24"]
#   }

#   ingress {
#     from_port   = 5439
#     to_port     = 5439
#     protocol    = "tcp"
#     cidr_blocks = ["172.16.3.0/24"]
#   }

#   tags = {
#     Name = "RedshiftSecurityGroup"
#   }
# }
