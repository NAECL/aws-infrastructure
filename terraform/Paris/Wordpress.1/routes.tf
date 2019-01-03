resource "aws_route_table" "PublicRouteTable" {
  vpc_id     = "${aws_vpc.VPC.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.Gw.id}"
  }
  tags {
    Name = "${var.region_name}_${var.environment} Public Route Table"
    ResourceGroup = "${var.region_name}_${var.environment}"
  }
}

resource "aws_route_table" "PrivateRouteTable" {
  vpc_id     = "${aws_vpc.VPC.id}"
  tags {
    Name = "${var.region_name}_${var.environment} Private Route Table"
    ResourceGroup = "${var.region_name}_${var.environment}"
  }
}

resource "aws_route_table_association" "PublicA" {
  subnet_id      = "${aws_subnet.PublicA.id}"
  route_table_id = "${aws_route_table.PublicRouteTable.id}"
}

resource "aws_route_table_association" "PrivateA" {
  subnet_id      = "${aws_subnet.PrivateA.id}"
  route_table_id = "${aws_route_table.PrivateRouteTable.id}"
}
