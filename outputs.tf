// Get the public ip of the ec2 instance
output "wordpress_ec2_public_ip" {
  value = "${aws_instance.wp-ec2.public_ip}"
}

// Get the RDS connection string of RDS Instance
output "wordpress_rds_host_endpoint" {
  value = "${aws_db_instance.default.endpoint}"
}

