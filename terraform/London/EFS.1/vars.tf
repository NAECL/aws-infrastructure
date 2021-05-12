variable "environment" {
  type    = string
  default = "efs"
}

locals {
    vpc_CIDR      = "${var.regionSubnet}.1.0/24"

    publicA_CIDR  = "${var.regionSubnet}.1.0/27"
    publicA_AZ    = "${var.region_zonea}"

    publicB_CIDR  = "${var.regionSubnet}.1.32/27"
    publicB_AZ    = "${var.region_zoneb}"

    privateA_CIDR = "${var.regionSubnet}.1.64/27"
    privateA_AZ   = "${var.region_zonea}"

    privateB_CIDR = "${var.regionSubnet}.1.96/27"
    privateB_AZ   = "${var.region_zoneb}"
}
