# Define our VPC
resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags = {
    Name = "aruna003-vpc"
  }
}

# Define the public subnets
resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnets_cidr)
  vpc_id = aws_vpc.default.id
  cidr_block = element(var.public_subnets_cidr,count.index)
  availability_zone = element(var.azs,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "aruna003-public-Subnet-${count.index+1}"
  }
}

# Define the private subnets
resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnets_cidr)
  vpc_id = aws_vpc.default.id
  cidr_block = element(var.private_subnets_cidr,count.index)
  availability_zone = element(var.azs,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "aruna003-private-Subnet-${count.index+1}"
  }
}

# Define the internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.default.id}"

  tags = {
    Name = "aruna003 VPC IGW"
  }
}

# Define the NAT gateway
resource "aws_nat_gateway" "ngw" {
  count = length(var.private_subnets_cidr)
  connectivity_type = "private"
  subnet_id = element(aws_subnet.private_subnet.*.id,count.index)
  tags = {
    Name = "aruna003 VPC NGW"
  }
}

# Define the route table for public subnet
resource "aws_route_table" "public-rt" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "aruna003 Public Subnet RT"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "public-rt-assoc" {
    count = length(var.public_subnets_cidr)
    subnet_id = element(aws_subnet.public_subnet.*.id,count.index)
    route_table_id = "${aws_route_table.public-rt.id}"
}

# Define the route table for private subnet
resource "aws_route_table" "private-rt" {
  vpc_id   = aws_vpc.default.id
  count = length(var.public_subnets_cidr)

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.ngw.*.id,count.index)
  }

  tags = {
    Name = "Private Route Table"
  }
}

# Assign the route table to the private Subnets
resource "aws_route_table_association" "nat" {
  count = length(var.private_subnets_cidr)
  route_table_id = element(aws_route_table.private-rt.*.id,count.index)
  subnet_id      = element(aws_subnet.private_subnet.*.id,count.index)
}

