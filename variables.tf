// Database Name for Wordpress
variable "rds_database_name" {
  type    = "string"
  default = "wordpressdb"
}

// Database User for Wordpress
variable "rds_database_user" {
  description = "master user for wordpress rds instance"
  default     = "wordadmin"
}

// Database Password for Wordpress
variable "rds_database_pass" {
  default = "Word2admin"
}

// Subnet CIDR
variable "subnets_cidr" {
  type    = "list"
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

// SSH port for executing remote scripts
variable "ssh_port" {
  description = "The port the EC2 Instance should listen on for SSH requests."
  default     = 22
}

// SSH Username for establishing the connection
variable "ssh_user" {
  description = "SSH user name to use for remote exec connections,"
  default     = "ubuntu"
}

