resource "aws_security_group" "efs_sg" {
  name   = "${var.region_name}_${var.environment}.efs_sg"
  vpc_id = "${aws_vpc.VPC.id}"
  description = "Allow RPC Inbound Traffic"

  ingress {
      from_port = 2049
      to_port = 2049
      protocol = "tcp"
      cidr_blocks = ["${local.publicA_CIDR}", "${local.privateA_CIDR}", "${local.publicB_CIDR}", "${local.privateB_CIDR}"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}
