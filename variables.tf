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

// SSH Public Key for accessing wordpress EC2 instance
variable "wordpress_ssh_key_pub" {
  description = "Public key for ec2 access."
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCn0qTqOnzxbJ0eKcnT6m2QpX6th4tJXItpb+VbLOumJau2w2QXDVGIUa3SGBSKKijwXVSWzrEMV1ucW8jlMysBdogVeIcoXPEq+XVz4X9FrkuIWEOSeBQuZ/C1fgt1u27O5R4Y+8SNtK+sLoQBcgt8ycQKsubpSn0oFgklqCJcQbldOId+hfwIdtGs6zehcgOQWuXaHrHJVk4pVU4wJ0mpZ+0fYuk0BPGdmA3FUvzjV2mwp9bwBR4cnMcvOIk4yV3ovVE2dA+QXbd4smgUrYPk3nvqxuOTyieh+q6pbVcGcp5iVLC4UvxZmPqAH2FQ3pAe3mN8qIPNvd5/fmskMjMZ wordpress-key"
}

