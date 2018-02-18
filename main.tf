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

# Create a security group that will allow us to both
# SSH into the instance as well as access prometheus
# publicly (note.: you'd not do this in prod - otherwise
# you'd have prometheus publicly exposed).
resource "aws_security_group" "allow-ssh-and-egress" {
  name = "main"

  description = "Allows SSH traffic into instances as well as all eggress."
  vpc_id      = "${module.networking.vpc-id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_ssh-all"
  }
}

resource "aws_instance" "inst1" {
  instance_type = "t2.micro"
  ami           = "${data.aws_ami.ubuntu.id}"
  key_name      = "${aws_key_pair.main.id}"
  subnet_id     = "${module.networking.az-subnet-id-mapping["subnet1"]}"

  vpc_security_group_ids = [
    "${aws_security_group.allow-ssh-and-egress.id}",
  ]
}

resource "aws_instance" "inst2" {
  instance_type = "t2.micro"
  ami           = "${data.aws_ami.ubuntu.id}"
  key_name      = "${aws_key_pair.main.id}"
  subnet_id     = "${module.networking.az-subnet-id-mapping["subnet2"]}"

  vpc_security_group_ids = [
    "${aws_security_group.allow-ssh-and-egress.id}",
  ]
}
