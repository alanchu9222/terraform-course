variable "environment" {
  description = "The environment"
}

variable "region" {
  description = "Region that the instances will be created in"
}

variable "project_name" {
  /* Used to prefix AWS resource names - should be as short as possible */
  description = "Name of project used to identify resources"
  default     = "dimeo-portal"
}

variable "image_uri" {
  description = "Explicit value to set as the image URI if provided"
  default     = ""
}

variable "client" {
  description = "The name of the client"
  default     = "Dimeo"
}

/*====
Production specific variables
======*/

variable "windows_server_ami" {
  description = "The region specific windows server image"
}

variable "domain" {
  description = "The domain for the production API"
}

variable "bucket_name" {
  description = "The name of the S3 bucket used by the API"
}

variable "database_name" {
  description = "The production database"
}

variable "database_username" {
  description = "The username for the master RDS database user"
}
