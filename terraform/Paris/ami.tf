# Find a regional AMI with this command or variants thereof
# Examples:
# aws ec2 describe-images --region ${region} | grep -B5 "aws-marketplace/CentOS Linux 7 x86_64 HVM"
# aws ec2 describe-images --region ${region} | grep aws-marketplace/ubuntu/images/hvm-ssd/ubuntu
#
variable "ami" {
  default = "ami-0cb72d2e599cffbf9"
}

variable "cent7ami" {
  default = "ami-0cb72d2e599cffbf9"
}

