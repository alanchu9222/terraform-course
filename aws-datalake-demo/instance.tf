
resource "aws_ebs_volume" "datagen_volume" {
  availability_zone = "eu-west-1a"
  size              = 50

  tags = {
    Name = "Datagen Volume"
  }
}


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


resource "aws_instance" "DataGeneratorInstance" {
  ami           = "ami-0ea3405d2d2522162"
  instance_type = "t2.xlarge"

  # the public SSH key
  key_name = aws_key_pair.key.key_name

  # the VPC subnet
  subnet_id = aws_subnet.Subnet1.id

  # the security group
  vpc_security_group_ids = [aws_security_group.DMZSecurityGroup.id]

  # Block Device Mappings
  ebs_block_device {
    device_name = "/dev/xvda"
    volume_size = "50"
    volume_type = "standard"
  }

  # Iam Instance Profile
  iam_instance_profile = aws_iam_instance_profile.EC2InstanceProfile.name

  # Tags
  tags = {
    Name = "Datagen Instance"
  }  
}



resource "aws_redshift_subnet_group" "RedshiftSubnetGroup" {
  name       = "redshift-subnet-group"
  subnet_ids = [aws_subnet.Subnet4.id, aws_subnet.Subnet3.id]
  description = "Redshift in private subnets"
  tags = {
    environment = "Production"
  }
}

resource "aws_redshift_cluster" "RedshiftCluster" {
  cluster_identifier = "tf-redshift-cluster"
  database_name      = "dev"
  master_username    = "awsuser"
  master_password    = "Abcd1234"
  node_type          = "dc2.large"
  cluster_type       = "multi-node"
  number_of_nodes    = "2"
  publicly_accessible = false
  port               = "5439"
  cluster_subnet_group_name = aws_redshift_subnet_group.RedshiftSubnetGroup.name
  iam_roles          = [aws_iam_role.RedshiftAccessRole.arn]
  vpc_security_group_ids = [aws_security_group.RedshiftSecurityGroup.id]
}

/*====
S3 Bucket to store the App and its assets
=====*/
resource "aws_s3_bucket" "dimeo-tf-redshift-bucket" {
  bucket = "dimeo-tf-test-bucket"
  acl    = "private"
  versioning {
    enabled = false
  }  
  tags = {
    Name        = "redshift bucket"
  }
}


