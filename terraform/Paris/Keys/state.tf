terraform {
  backend "s3" {
    bucket = "naecl.co.uk.terraform"
    key    = "state/Keys.Paris/terraform.tfstate"
    region = "eu-west-2"
  }
}
