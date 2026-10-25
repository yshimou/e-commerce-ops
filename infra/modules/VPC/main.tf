resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr

  tags = {
    Name = "main"
    Project = "e-commerce-ops"
  }
}


resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "Private Subnet ${count.index}"
    Project = "e-commerce-ops"
  }
}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet ${count.index}"
    Project = "e-commerce-ops"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
    Project = "e-commerce-ops"
  }
}

resource "aws_eip" "eip" {
  count = length(var.public_subnet_cidrs)
  domain = "vpc"
  tags = {
    Name = "EIP ${count.index}"
    Project = "e-commerce-ops"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  count = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = {
    Name = "NAT-gw ${count.index}"
    Project = "e-commerce-ops"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private_RT" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }

  tags = {
    Name = "private-RT ${count.index}"
    Project = "e-commerce-ops"
  }
}

resource "aws_route_table" "public_RT" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-RT"
    Project = "e-commerce-ops"
  }
}

resource "aws_route_table_association" "private_association" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_RT[count.index].id
}

resource "aws_route_table_association" "public_association" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_RT.id
}



