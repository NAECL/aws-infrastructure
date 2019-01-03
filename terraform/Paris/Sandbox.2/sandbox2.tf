resource "aws_instance" "sandbox2" {
  ami                    = "${var.centos-6-ami}"
  instance_type          = "t2.small"
  key_name               = "aws-key"
  subnet_id              = "${aws_subnet.PublicA.id}"
  vpc_security_group_ids = [ "${aws_security_group.public_syslog.id}" ]
  iam_instance_profile   = "STANDARD_profile"
  user_data              = <<EOF
#!/bin/bash -x
curl http://aws.naecl.co.uk/public/build/bootstrap/install.sh | bash
EOF
  tags {
    Name = "sandbox2-${var.environment}"
    Role = "base"
    Environment = "${var.environment}"
  }
}

resource "aws_route53_record" "sandbox2-dns" {
   zone_id = "${var.dnsZone}"
   name = "sandbox2-${var.environment}.${var.dnsDomain}"
   type = "A"
   ttl = "30"
   records = ["${aws_instance.sandbox2.public_ip}"]
}
