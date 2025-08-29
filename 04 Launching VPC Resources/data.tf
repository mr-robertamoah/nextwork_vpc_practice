# get availability zones
data "aws_availability_zones" "available" {}

# get linux AMI
data "aws_ami" "latest" {
  most_recent = true

  owners = ["099720109477"] # Amazon

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}