variable "environment" {
  type    = string
  default = "jenkins"
}

locals {
    vpc_CIDR      = "${var.regionSubnet}.4.0/24"

    publicA_CIDR  = "${var.regionSubnet}.4.0/27"
    publicA_AZ    = "${var.region_zonea}"

    publicB_CIDR  = "${var.regionSubnet}.4.32/27"
    publicB_AZ    = "${var.region_zoneb}"

    privateA_CIDR = "${var.regionSubnet}.4.64/27"
    privateA_AZ   = "${var.region_zonea}"

    privateB_CIDR = "${var.regionSubnet}.4.96/27"
    privateB_AZ   = "${var.region_zoneb}"
}
