/*=======
EC2
- Create a utility EC2 instance which serves as an SSH host
- Equip with tools to connect to Postgres resources
========*/
# Get the list of official Canonical Ubuntu 16.04 AMIs
data "aws_ami" "ubuntu-1604" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "startup" {
  template = file("${path.module}/templates/startup.sh.tpl")
}

resource "aws_security_group" "ssh_inbound" {
  name   = "Allow SSH from anywhere into VPC"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}-${var.environment}-ssh-inbound-sg"
  }
}

resource "aws_instance" "ssh_util" {
  ami           = data.aws_ami.ubuntu-1604.id
  instance_type = "t2.nano"
  key_name      = var.key_name
  subnet_id     = element(var.subnets_id, 0)
  vpc_security_group_ids = flatten([
    var.security_groups_ids,
    aws_security_group.ssh_inbound.id,
  ])
  user_data = data.template_file.startup.rendered

  tags = {
    Name = "${var.project_name}-${var.environment}-ssh-host"
  }
}

resource "aws_eip" "bastion_eip" {
  vpc      = true
  instance = aws_instance.ssh_util.id
  lifecycle {
    prevent_destroy = true
  }
  depends_on = [aws_instance.ssh_util]

  tags = {
    Name        = "${var.environment}-bastion-eip"
    Environment = var.environment
  }
}
