resource "aws_vpc" "vpc_ecs" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.vpc_ecs.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "sa-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.app_name}-private-subnet-a"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.vpc_ecs.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "sa-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.app_name}-private-subnet-b"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.vpc_ecs.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "sa-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name}-public-subnet-a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.vpc_ecs.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "sa-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name}-public-subnet-b"
  }
}