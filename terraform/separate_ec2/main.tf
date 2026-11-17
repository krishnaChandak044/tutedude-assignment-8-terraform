resource "aws_vpc" "app" {

  cidr_block           = "10.44.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "${var.project_name}-split-vpc"
  }
}
resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id
}
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.app.id
  cidr_block              = "10.44.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"
  tags = { Name = "${var.project_name}-public"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.app.id
  route {

    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app.id
  }
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
resource "aws_security_group" "app" {

  name   = "${var.project_name}-split"
  vpc_id = aws_vpc.app.id
  ingress {
    description = "SSH from operator"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }
  ingress {
    description = "Express public"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Flask public API"
    from_port   = 5000
    to_port     = 5000
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
resource "aws_instance" "flask" {

  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  user_data                   = file("${path.module}/flask_user_data.sh")
  user_data_replace_on_change = true
  root_block_device {
    volume_size = 10
    volume_type = "gp3"
    encrypted   = true
  }
  tags = { Name = "${var.project_name}-flask"
  }
}
resource "aws_instance" "express" {

  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app.id]
  user_data = templatefile("${path.module}/express_user_data.sh", { backend_ip = aws_instance.flask.private_ip
  })
  user_data_replace_on_change = true
  root_block_device {
    volume_size = 10
    volume_type = "gp3"
    encrypted   = true
  }
  tags = { Name = "${var.project_name}-express"
  }
}
