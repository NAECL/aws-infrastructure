terraform {
  backend "s3" {
    bucket = "terraform-public.naecl.co.uk",
    key    = "state/Keys.Paris/terraform.tfstate"
    region = "eu-west-2"
  }
}
