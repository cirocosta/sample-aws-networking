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

output "az-subnet-id-mapping" {
  value = "${module.networking.az-subnet-id-mapping}"
}
