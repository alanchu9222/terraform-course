# Internet VPC
resource "aws_vpc" "main" {
  cidr_block           = "172.16.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "main"
  }
}

# Subnets
resource "aws_subnet" "Subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.16.0.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-1a"

  tags = {
    Name = "Subnet 1 - Public"
  }
}
resource "aws_subnet" "Subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.16.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-1a"

  tags = {
    Name = "Subnet 2 - Public"
  }
}

resource "aws_subnet" "Subnet3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.16.2.0/24"
  availability_zone       = "eu-west-1a"

  tags = {
    Name = "Subnet 3 - Private"
  }
}

resource "aws_subnet" "Subnet4" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.16.3.0/24"
  availability_zone       = "eu-west-1a"

  tags = {
    Name = "Subnet 4 - Private"
  }
}


resource "aws_network_acl" "NetworkAclSubnet1" {
  vpc_id = aws_vpc.main.id
  subnet_ids = [aws_subnet.Subnet1.id]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "NetworkAclSubnet1"
  }
}

resource "aws_network_acl" "NetworkAclSubnet2" {
  vpc_id = aws_vpc.main.id
  subnet_ids = [aws_subnet.Subnet2.id]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "NetworkAclSubnet2"
  }
}

resource "aws_network_acl" "NetworkAclSubnet3" {
  vpc_id = aws_vpc.main.id
  subnet_ids = [aws_subnet.Subnet3.id]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "NetworkAclSubnet3"
  }
}

resource "aws_network_acl" "NetworkAclSubnet4" {
  vpc_id = aws_vpc.main.id
  subnet_ids = [aws_subnet.Subnet4.id]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "NetworkAclSubnet4"
  }
}


resource "aws_internet_gateway" "InternetGateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "InternetGateway"
  }
}

resource "aws_route" "Route2InternetGateway" {
  route_table_id         = aws_route_table.PublicRouteTable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id         = aws_internet_gateway.InternetGateway.id
}

/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc        = true
}

/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  depends_on    = [aws_eip.nat_eip]

  subnet_id     = aws_subnet.Subnet1.id

  tags = {
    Name        = "aws-datalake-nat"
  }
}

resource "aws_route" "Route2NatGateway" {
  depends_on    = [aws_nat_gateway.nat]
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.PrivateRouteTable.id
  nat_gateway_id    = aws_nat_gateway.nat.id
}


resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "PublicRouteTableSubnet1" {
  subnet_id      = aws_subnet.Subnet1.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route_table_association" "PublicRouteTableSubnet2" {
  subnet_id      = aws_subnet.Subnet2.id
  route_table_id = aws_route_table.PublicRouteTable.id
}


resource "aws_route_table" "PrivateRouteTable" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_route_table_association" "PrivateRouteTableSubnet3" {
  subnet_id      = aws_subnet.Subnet3.id
  route_table_id = aws_route_table.PrivateRouteTable.id
}

resource "aws_route_table_association" "PrivateRouteTableSubnet4" {
  subnet_id      = aws_subnet.Subnet4.id
  route_table_id = aws_route_table.PrivateRouteTable.id
}


# # Subnets
# resource "aws_subnet" "main-public-1" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = "10.0.1.0/24"
#   map_public_ip_on_launch = "true"
#   availability_zone       = "eu-west-1a"

#   tags = {
#     Name = "main-public-1"
#   }
# }

# resource "aws_subnet" "main-public-2" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = "10.0.2.0/24"
#   map_public_ip_on_launch = "true"
#   availability_zone       = "eu-west-1b"

#   tags = {
#     Name = "main-public-2"
#   }
# }

# resource "aws_subnet" "main-public-3" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = "10.0.3.0/24"
#   map_public_ip_on_launch = "true"
#   availability_zone       = "eu-west-1c"

#   tags = {
#     Name = "main-public-3"
#   }
# }

# resource "aws_subnet" "main-private-1" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = "10.0.4.0/24"
#   map_public_ip_on_launch = "false"
#   availability_zone       = "eu-west-1a"

#   tags = {
#     Name = "main-private-1"
#   }
# }

# resource "aws_subnet" "main-private-2" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = "10.0.5.0/24"
#   map_public_ip_on_launch = "false"
#   availability_zone       = "eu-west-1b"

#   tags = {
#     Name = "main-private-2"
#   }
# }

# resource "aws_subnet" "main-private-3" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = "10.0.6.0/24"
#   map_public_ip_on_launch = "false"
#   availability_zone       = "eu-west-1c"

#   tags = {
#     Name = "main-private-3"
#   }
# }

# # Internet GW
# resource "aws_internet_gateway" "main-gw" {
#   vpc_id = aws_vpc.main.id

#   tags = {
#     Name = "main"
#   }
# }

# route tables
# resource "aws_route_table" "main-public" {
#   vpc_id = aws_vpc.main.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.main-gw.id
#   }

#   tags = {
#     Name = "main-public-1"
#   }
# }

# # route associations public
# resource "aws_route_table_association" "main-public-1-a" {
#   subnet_id      = aws_subnet.main-public-1.id
#   route_table_id = aws_route_table.main-public.id
# }

# resource "aws_route_table_association" "main-public-2-a" {
#   subnet_id      = aws_subnet.main-public-2.id
#   route_table_id = aws_route_table.main-public.id
# }

# resource "aws_route_table_association" "main-public-3-a" {
#   subnet_id      = aws_subnet.main-public-3.id
#   route_table_id = aws_route_table.main-public.id
# }

