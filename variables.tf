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
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDheySbPaCWcKF4d3uC6tuvAuheZuQKn71Lac7xI5iJW6NAu2Lfipvx/eME7/Mf5xoiYTWpYsYEV2sUiDokolqrFI1VwbFacW4hV9IVz0lW40spaAYylDoGUBEZu/pelA0842lWau9OQwRk+gN7gyAfAUi2lBmmBMhH4UzweLxopZ2YdbH96e17Q8h5/4e7W+2tb4A+Bm/wrB3mI2uUv8GG0rUYTIcg4Cm7TkuUm1hAI9RLtg2k62+AOfe2CBMtZcOWh7MQG2xbovAK8T8WU09VlOMg1WNjGsbpGLpYstGgqwQZ9L817+PWebjan82aQqdiaCSZ5hRKCOiFNn7XF0Xd wordpress-key"
}

