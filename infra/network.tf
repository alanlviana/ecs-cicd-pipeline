
# Get Availability Zones
data "aws_availability_zones" "available_zones" {
  state = "available"
}

// Create VPC
resource "aws_vpc" "vpc_ecs" {
  cidr_block = var.vpc_cidr
  
  tags = merge(local.common_tags, {
    Name = "${var.app_name}-vpc"
  })
}

// Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_ecs.id

  tags = merge(local.common_tags, {
    Name = "${var.app_name}-internet-gateway"
  })
}

// Create Public Subnets and Route table using the Internet Gateway
resource "aws_subnet" "public_subnets" {
  vpc_id = aws_vpc.vpc_ecs.id

  count             = 2
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]

  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.app_name}-public-subnet-${count.index + 1}"
  })
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc_ecs.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.app_name}-public-route-table"
  })

}

resource "aws_route_table_association" "public_rt_asso" {
  count          = 2
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}



// Create Private Subnets and Route table using the NAT Gateway through the Public Subnets
resource "aws_subnet" "private_subnets" {
  vpc_id = aws_vpc.vpc_ecs.id

  count             = 2
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 2 + count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]

  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${var.app_name}-private-subnet-${count.index + 1}"
  })
}

resource "aws_eip" "eip_natgw" {
  count = 2
}


resource "aws_nat_gateway" "natgateway" {
  count         = 2
  allocation_id = aws_eip.eip_natgw[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id
}

resource "aws_route_table_association" "private_rt_asso" {
  count          = 2
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.private_route_table[count.index].id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc_ecs.id

  count = 2
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway[count.index].id
  }

  tags = merge(local.common_tags, {
    Name = "${var.app_name}-private-rtable"
  })
}

