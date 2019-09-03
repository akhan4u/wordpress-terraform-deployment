provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "wp-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags {
    Name = "wordpress"
  }
}

resource "aws_internet_gateway" "wp" {
  vpc_id = "${aws_vpc.wp-vpc.id}"

  tags = {
    Name = "wordpress"
  }
}

resource "aws_route_table" "wp-rt" {
  vpc_id = "${aws_vpc.wp-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.wp.id}"
  }

  tags {
    Name = "wordpress-public-rt"
  }
}

resource "aws_subnet" "wp-subnet" {
  availability_zone               = "us-west-2b"
  cidr_block                      = "10.0.1.0/24"
  vpc_id                          = "${aws_vpc.wp-vpc.id}"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
}

resource "aws_subnet" "rds-subnet" {
  availability_zone               = "us-west-2a"
  cidr_block                      = "10.0.2.0/24"
  vpc_id                          = "${aws_vpc.wp-vpc.id}"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
}

resource "aws_route_table_association" "wp-a" {
  count          = "${length(var.subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.wp-subnet.*.id,count.index)}"
  route_table_id = "${aws_route_table.wp-rt.id}"
}

resource "aws_security_group" "wp-sg" {
  description = "wordpress site"
  name        = "wordpress"

  tags {
    Name = "wordpress"
  }

  vpc_id = "${aws_vpc.wp-vpc.id}"

  ingress {
    cidr_blocks = [
      "0.0.0.0/0",
    ]

    from_port = 22
    protocol  = "tcp"
    to_port   = 22
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0",
    ]

    from_port = 80
    protocol  = "tcp"
    to_port   = 80
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0",
    ]

    from_port = 3306
    protocol  = "tcp"
    to_port   = 3306
  }

  egress {
    cidr_blocks = [
      "0.0.0.0/0",
    ]

    from_port = 0
    to_port   = 0
    protocol  = "-1"
  }
}

resource "aws_db_subnet_group" "default" {
  name        = "main_subnet_group"
  description = "Our main group of subnets"
  subnet_ids  = ["${aws_subnet.wp-subnet.id}", "${aws_subnet.rds-subnet.id}"]
}

resource "aws_db_instance" "default" {
  depends_on              = ["aws_security_group.wp-sg"]
  identifier              = "aurora-cluster-wordpress"
  allocated_storage       = 8
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "5.7"
  port                    = 3306
  instance_class          = "db.t2.micro"
  name                    = "${var.rds_database_name}"
  username                = "${var.rds_database_user}"
  password                = "${var.rds_database_pass}"
  parameter_group_name    = "default.mysql5.7"
  multi_az                = false
  backup_retention_period = 10
  deletion_protection     = false
  publicly_accessible     = true
  skip_final_snapshot     = true
  availability_zone       = "us-west-2b"
  vpc_security_group_ids  = ["${aws_security_group.wp-sg.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.default.id}"

  tags {
    Name = "wordpress"
  }
}

// Add ssh public key to aws
resource "aws_key_pair" "wp-key" {
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDheySbPaCWcKF4d3uC6tuvAuheZuQKn71Lac7xI5iJW6NAu2Lfipvx/eME7/Mf5xoiYTWpYsYEV2sUiDokolqrFI1VwbFacW4hV9IVz0lW40spaAYylDoGUBEZu/pelA0842lWau9OQwRk+gN7gyAfAUi2lBmmBMhH4UzweLxopZ2YdbH96e17Q8h5/4e7W+2tb4A+Bm/wrB3mI2uUv8GG0rUYTIcg4Cm7TkuUm1hAI9RLtg2k62+AOfe2CBMtZcOWh7MQG2xbovAK8T8WU09VlOMg1WNjGsbpGLpYstGgqwQZ9L817+PWebjan82aQqdiaCSZ5hRKCOiFNn7XF0Xd amaan-khan"
  key_name   = "wp-ec2-key"
}

resource "aws_instance" "wp-ec2" {
  ami                         = "ami-06f2f779464715dc5"
  associate_public_ip_address = true
  depends_on                  = ["aws_internet_gateway.wp", "aws_db_instance.default"]
  instance_type               = "t2.micro"
  key_name                    = "wp-ec2-key"
  availability_zone           = "us-west-2b"
  subnet_id                   = "${aws_subnet.wp-subnet.id}"
  ebs_optimized               = false

  vpc_security_group_ids = [
    "${aws_security_group.wp-sg.id}",
  ]

  source_dest_check = true

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags {
    Name = "wordpress"
  }
}

resource "null_resource" "wordpress_deployment" {
  triggers {
    // trigger the deployment after getting the ec2 public ip
    public_ip = "${aws_instance.wp-ec2.public_ip}"
  }

  // Connection type defination for remote-exec
  connection {
    type        = "ssh"
    host        = "${aws_instance.wp-ec2.public_ip}"
    user        = "${var.ssh_user}"
    port        = "${var.ssh_port}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  // Configure and Install wordpress on ec2 node
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable'",
      "sudo apt update",
      "sudo apt install docker-ce -y",
      "sudo docker run -e WORDPRESS_DB_HOST=${aws_db_instance.default.endpoint} -e WORDPRESS_DB_NAME=${var.rds_database_name} -e WORDPRESS_DB_USER=${var.rds_database_user} -e WORDPRESS_DB_PASSWORD=${var.rds_database_pass} --name wordpress -p 80:80 -d wordpress",
    ]
  }
}

