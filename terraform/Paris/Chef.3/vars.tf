variable "environment" {
  type    = "string"
  default = "chef"
}

locals {
    "vpc_CIDR"      = "${var.regionSubnet}.3.0/24"

    "publicA_CIDR"  = "${var.regionSubnet}.3.0/27"
    "publicA_AZ"    = "${var.region_zonea}"

    "publicB_CIDR"  = "${var.regionSubnet}.3.32/27"
    "publicB_AZ"    = "${var.region_zoneb}"

    "privateA_CIDR" = "${var.regionSubnet}.3.64/27"
    "privateA_AZ"   = "${var.region_zonea}"

    "privateB_CIDR" = "${var.regionSubnet}.3.96/27"
    "privateB_AZ"   = "${var.region_zoneb}"
}
