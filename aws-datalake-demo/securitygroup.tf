
/*====
SECURITY_GROUP.TF: New contents added 5-6-2020
TODO - the IP address should allow only one specific IP address
====*/
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

