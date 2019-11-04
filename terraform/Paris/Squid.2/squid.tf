variable "serverName" {
  type    = "string"
  default = "squid"
}

resource "aws_instance" "squid" {
  ami                    = "${var.centos-7-ami}"
  instance_type          = "t2.nano"
  key_name               = "aws-key"
  subnet_id              = "${aws_subnet.PublicA.id}"
  vpc_security_group_ids = [ "${aws_security_group.public_squid.id}" ]
  iam_instance_profile   = "STANDARD_profile"
  user_data              = <<EOF
#!/bin/bash -x
curl http://aws.naecl.co.uk/public/build/bootstrap/install.sh | bash
EOF
  tags {
    Name = "${var.serverName}"
    Role = "squid"
    Environment = "${var.region_name}_${var.environment}"
    Region_DNS = "${var.region_name}.${var.dnsDomain}"
    Config_Repo = "https://github.com/NAECL/config-public.git"
}

resource "aws_route53_record" "squid-dns" {
  zone_id = "${var.dnsZone}"
  name = "${var.serverName}.${var.region_name}.${var.dnsDomain}"
  type = "A"
  ttl = "30"
  records = ["${aws_instance.squid.public_ip}"]
}
