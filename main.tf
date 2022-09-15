provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region  = "${var.aws_region}"
}
resource "random_string" "random" {
  length           = 6
  special          = false
}
resource "aws_vpc" "test_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true
}
resource "aws_internet_gateway" "test_internet_gateway" {
  vpc_id = "${aws_vpc.test_vpc.id}"
}
resource "aws_route_table" "test_public_rt" {
  vpc_id = "${aws_vpc.test_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.test_internet_gateway.id}"
  }
}
resource "aws_default_route_table" "test_private_rt" {
  default_route_table_id = "${aws_vpc.test_vpc.default_route_table_id}"
}
resource "aws_subnet" "test_public1_subnet" {
  vpc_id                  = "${aws_vpc.test_vpc.id}"
  cidr_block              = "${var.cidrs_public1}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"
}
resource "aws_subnet" "test_private1_subnet" {
  vpc_id                  = "${aws_vpc.test_vpc.id}"
  cidr_block              = "${var.cidrs_private1}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"
}
resource "aws_route_table_association" "test_public_assoc" {
  subnet_id      = "${aws_subnet.test_public1_subnet.id}"
  route_table_id = "${aws_route_table.test_public_rt.id}"
}
resource "aws_route_table_association" "test_private1_assoc" {
  subnet_id      = "${aws_subnet.test_private1_subnet.id}"
  route_table_id = "${aws_default_route_table.test_private_rt.id}"
}
resource "aws_security_group" "test_ssh_sg" {
  name        = "test_ssh_sg"
  description = "Used for SSH access to instances"
  vpc_id      = "${aws_vpc.test_vpc.id}"
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
}
resource "aws_security_group" "test_internal_sg" {
  name        = "test_internal_sg"
  description = "Usd for  internal ports communication between manager and worker node"
  vpc_id      = "${aws_vpc.test_vpc.id}"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.cidrs_public1}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "test_808x_sg" {
  name        = "test_908x_sg"
  description = "Usd for  manager communication with ELB or outside world"
  vpc_id      = "${aws_vpc.test_vpc.id}"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  
  ingress {
    from_port   = 9086
    to_port     = 9086
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "test_database_sg" {
  name        = "test_database_sg"
  description = "Usd for  DB communication with worker nodes"
  vpc_id      = "${aws_vpc.test_vpc.id}"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${var.cidrs_public1}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "test_private_sg" {
  name        = "test_private_sg"
  description = "Used for private instances"
  vpc_id      = "${aws_vpc.test_vpc.id}"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.vpc_cidr}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_key_pair" "test_auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "test_manager" {
  count         = "${var.manager_count}"
  instance_type = "${var.instance_type}"
  ami           = "${var.ami}"
  key_name               = "${aws_key_pair.test_auth.id}"
  vpc_security_group_ids = ["${aws_security_group.test_808x_sg.id}","${aws_security_group.test_internal_sg.id}","${aws_security_group.test_ssh_sg.id}"]
  subnet_id              = "${aws_subnet.test_public1_subnet.id}"
  connection {
    user="ubuntu"
    private_key="${file(var.private_key_path)}"
  }
  tags = {
    Name = "test_manager"
  }  
}
resource "aws_instance" "test_worker" {
  count         = "${var.worker_count}"
  instance_type = "${var.instance_type}"
  ami           = "${var.ami}"
  key_name               = "${aws_key_pair.test_auth.id}"
  vpc_security_group_ids = ["${aws_security_group.test_ssh_sg.id}","${aws_security_group.test_internal_sg.id}"]
  subnet_id              = "${aws_subnet.test_public1_subnet.id}"
  connection {
      user="ubuntu"
      private_key="${file(var.private_key_path)}"
  }
  tags = {
    Name = "test_worker"
  }
 }
resource "aws_instance" "test_database" {
  instance_type = "${var.instance_type}"
  ami           = "${var.ami}"
  key_name               = "${aws_key_pair.test_auth.id}"
  vpc_security_group_ids = ["${aws_security_group.test_ssh_sg.id}","${aws_security_group.test_database_sg.id}"]
  subnet_id              = "${aws_subnet.test_public1_subnet.id}"
  connection {
    user="ubuntu"
    private_key="${file(var.private_key_path)}"
  }
  tags = {
    Name = "test_database"
  }
 }