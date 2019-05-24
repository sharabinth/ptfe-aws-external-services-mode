# Define all Network related resources such as VPC, Subnet, Internet Gateway, Routing Table etc

# Obtain the list of availability zones the region
data "aws_availability_zones" "available" {
  state = "available"
}

# Setup Network services such as VPC and also create a Security Group to enable SSH into the instance
# 

# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags {
    Name = "${var.resource_prefix_name}-vpc"
  }
}

# Create primary and secondary subnets within VPC and attach them to two separate availability zones
resource "aws_subnet" "subnet" {
  count = 2

  #cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 3, 1)}"
  # instead of using the complex function, use the cidr block within the vpc cidr block
  cidr_block = "10.0.${count.index+1}.0/24"

  vpc_id            = "${aws_vpc.vpc.id}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

  tags {
    Name = "${var.resource_prefix_name}-subnet-${element(data.aws_availability_zones.available.names, count.index)}"
  }

  # May not be required to assign a public IP for the instance as elastic ip is defined and attached to the instance
  map_public_ip_on_launch = true
}

# To route traffic from internet setup Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.resource_prefix_name}-igw"
  }
}

# Setup Route Table and attach the Internet Gateway
resource "aws_route_table" "route_table" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "${var.resource_prefix_name}-route_table"
  }
}

# Associate the Route Table with subnets so that subnets are allowed to the internet for us to access
resource "aws_route_table_association" "route_table_association" {
  count          = 2
  route_table_id = "${aws_route_table.route_table.id}"
  subnet_id      = "${element(aws_subnet.subnet.*.id, count.index)}"
}

# Create DB subnet group
resource "aws_db_subnet_group" "db_subnet_group" {
  name_prefix = "${var.resource_prefix_name}"
  description = "${var.resource_prefix_name}-db_subnet_group"
  subnet_ids  = ["${aws_subnet.subnet.*.id}"]
}
