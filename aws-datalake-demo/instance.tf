resource "aws_iam_instance_profile" "EC2InstanceProfile" {
  name = "datagen_profile"
  role = aws_iam_role.EC2AccessRole.name
}

resource "aws_instance" "JumpBoxInstance" {
  ami           = "ami-0c841cc412b3474b1"
  instance_type = "t2.medium"

  # the public SSH key
  key_name = aws_key_pair.key.key_name

  # the VPC subnet
  subnet_id = aws_subnet.Subnet1.id

  # the security group
  vpc_security_group_ids = [aws_security_group.DMZSecurityGroup.id]

  # Tags
  tags = {
    Name = "Jump Box"
  }  
}

resource "aws_instance" "DataGatewayInstance" {
  ami           = "ami-0c841cc412b3474b1"
  instance_type = "t2.medium"

  # the public SSH key
  key_name = aws_key_pair.key.key_name

  # the VPC subnet
  subnet_id = aws_subnet.Subnet3.id

  # the security group
  vpc_security_group_ids = [aws_security_group.DataGatewaySecurityGroup.id]

  # Tags
  tags = {
    Name = "Data Gateway"
  }  
}

