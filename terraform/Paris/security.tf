resource "aws_security_group" "public_ssh" {
  name   = "${var.region_name}_${var.environment}.public_ssh"
  vpc_id = "${aws_vpc.VPC.id}"
  description = "Allow SSH Inbound Traffic"

  # All Servers can be nagios monitored
  ingress {
      from_port = 5666
      to_port = 5666
      protocol = "tcp"
      cidr_blocks = ["${var.nagiosIp}", "${var.homeIp}"]
  }

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["${var.homeIp}"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "public_web" {
  name   = "${var.region_name}_${var.environment}.public_web"
  vpc_id = "${aws_vpc.VPC.id}"
  description = "Allow SSH, HTTP, and HTTPS Inbound Traffic"

  # All Servers can be nagios monitored
  ingress {
      from_port = 5666
      to_port = 5666
      protocol = "tcp"
      cidr_blocks = ["${var.nagiosIp}", "${var.homeIp}"]
  }

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["${var.homeIp}"]
  }

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "public_squid" {
  name   = "${var.region_name}_${var.environment}.public_squid"
  vpc_id = "${aws_vpc.VPC.id}"
  description = "Allow SSH, HTTP, and HTTPS Inbound Traffic"

  # All Servers can be nagios monitored
  ingress {
      from_port = 5666
      to_port = 5666
      protocol = "tcp"
      cidr_blocks = ["${var.nagiosIp}", "${var.homeIp}"]
  }

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["${var.homeIp}"]
  }

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}
