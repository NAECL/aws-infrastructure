resource "aws_vpc" "VPC" {
  cidr_block    = "${local.vpc_CIDR}"
  tags = {
    Name = "${var.region_name}.${var.environment} VPC"
    ResourceGroup = "${var.region_name}.${var.environment}"
  }
}

resource "aws_subnet" "PublicA" {
  cidr_block              = "${local.publicA_CIDR}"
  availability_zone       = "${local.publicA_AZ}"
  vpc_id                  = "${aws_vpc.VPC.id}"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.region_name}.${var.environment} Public A"
    ResourceGroup = "${var.region_name}.${var.environment}"
  }
}

resource "aws_subnet" "PrivateA" {
  cidr_block              = "${local.privateA_CIDR}"
  availability_zone       = "${local.privateA_AZ}"
  vpc_id                  = "${aws_vpc.VPC.id}"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.region_name}.${var.environment} Private A"
    ResourceGroup = "${var.region_name}.${var.environment}"
  }
}

resource "aws_internet_gateway" "Gw" {
  vpc_id = "${aws_vpc.VPC.id}"
  tags = {
    Name = "${var.region_name}.${var.environment} IGW"
    ResourceGroup = "${var.region_name}.${var.environment}"
  }
}
