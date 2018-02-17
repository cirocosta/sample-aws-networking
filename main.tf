variable "profile" {
  description = "Profile with permissions to provision the AWS resources."
  default     = "beld"
}

variable "region" {
  description = "Region to provision the resources into."
  default     = "sa-east-1"
}

provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

# Pick the latest ubuntu artful (17.10) ami released by the
# Canonical team.
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-artful-17.10-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

module "networking" {
  source = "./networking"
  cidr   = "10.0.0.0/16"

  "az-subnet-mapping" = [
    {
      name = "subnet1"
      az   = "sa-east-1a"
      cidr = "10.0.0.0/24"
    },
    {
      name = "subnet2"
      az   = "sa-east-1c"
      cidr = "10.0.1.0/24"
    },
  ]
}

resource "aws_instance" "inst1" {
  instance_type = "t2.micro"
  ami           = "${data.aws_ami.ubuntu.id}"
  key_name      = "${aws_key_pair.main.id}"
  subnet_id     = "${module.networking.az-subnet-id-mapping["subnet1"]}"
}

resource "aws_instance" "inst2" {
  instance_type = "t2.micro"
  ami           = "${data.aws_ami.ubuntu.id}"
  key_name      = "${aws_key_pair.main.id}"
  subnet_id     = "${module.networking.az-subnet-id-mapping["subnet2"]}"
}
