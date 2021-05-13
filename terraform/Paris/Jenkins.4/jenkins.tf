resource "aws_instance" "jenkins" {
  ami                    = "${var.centos-7-ami}"
  instance_type          = "t2.small"
  key_name               = "aws-key"
  subnet_id              = "${aws_subnet.PublicA.id}"
  vpc_security_group_ids = [ "${aws_security_group.public_web.id}" ]
  iam_instance_profile   = "STANDARD_profile"
  user_data              = <<EOF
#!/bin/bash -x
curl http://aws.naecl.co.uk/public/build/bootstrap/install.sh | bash
EOF
  tags = {
    Name = "jenkins"
    Role = "jenkins"
    Installer = "chef"
    Environment = "${var.environment}"
    Region_DNS = "${var.region_name}.${var.dnsDomain}"
  }
}

resource "aws_route53_record" "jenkins-dns" {
   zone_id = "${var.dnsZone}"
   name = "jenkins.${var.region_name}.${var.dnsDomain}"
   type = "A"
   ttl = "30"
   records = ["${aws_instance.client.public_ip}"]
}
