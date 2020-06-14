variable "project_name" {
  description = "Name of the project"
}

variable "environment" {
  description = "The envinroment"
}

variable "key_name" {
  description = "The public key for the bastion host"
}

variable "vpc_id" {
  description = "The VPC ID"
}

variable "subnets_id" {
  type        = list(string)
  description = "Subnet ids"
}

variable "security_groups_ids" {
  type        = list(string)
  description = "The SGs to use"
}

