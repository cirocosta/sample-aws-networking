
    DESCRIPTION

        This repository holds an example of using Terraform to set up
        basic AWS networking for a multi-az environment in a single 
        region.

        It consists of:
            -   single VPC
            -   multiple subnets via single configuration

        `main.tf` summarizes the usage of the custom `networking` module:



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


    MORE

        https://ops.tips/blog/a-pratical-look-at-basic-aws-networking
  
