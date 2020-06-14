variable "project_name" {
  description = "Name of the project"
}

variable "public_subnet_id" {
  description = "The public subnet id"
}

variable "private_subnet_id" {
  description = "The private subnet id"
}

variable "environment" {
  description = "The environment"
}

variable "key_name" {
  description = "The public key for the bastion host"
}

// dimeo-data
variable "athena_database" {
  description = "The database for the aws data catalog"
}

// dimeo-tf-raw-bucket
variable "query_results_bucket" {
  description = "The results for athena query is stored in this bucket"
}

// dimeo-tf-transformed-bucket
variable "data_source_bucket" {
  description = "The athena queries are made with raw data from this bucket"
}

// TODO - make this region specific "ami-0c841cc412b3474b1"
variable "regionspecific_windows_server_ami" {
  description = "The EC2 image for windows server"
}

// aws_security_group.DMZSecurityGroup.id
variable "dmz_security_group_id" {
  description = "The security group for accessing the jump box"
}
