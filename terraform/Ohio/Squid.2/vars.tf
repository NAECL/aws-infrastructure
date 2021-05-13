variable "environment" {
  type    = string
  default = "squid"
}

locals {
    vpc_CIDR      = "${var.regionSubnet}.2.0/24"

    publicA_CIDR  = "${var.regionSubnet}.2.0/27"
    publicA_AZ    = "${var.region_zonea}"

    publicB_CIDR  = "${var.regionSubnet}.2.32/27"
    publicB_AZ    = "${var.region_zoneb}"

    privateA_CIDR = "${var.regionSubnet}.2.64/27"
    privateA_AZ   = "${var.region_zonea}"

    privateB_CIDR = "${var.regionSubnet}.2.96/27"
    privateB_AZ   = "${var.region_zoneb}"
}
