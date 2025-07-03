provider "aws" {
  region = "us-west-2"
}

# Fetch the default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch subnet IDs in that default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


variable "ami" {
  description = "value"
}

variable "instance_type" {
  description = "value"
  type        = map(string)

  default = {
    "dev"   = "t2.micro"
    "stage" = "t2.medium"
    "prod"  = "t2.xlarge"
  }
}

module "ec2_instance" {
  source        = "./ec2-module"
  ami           = var.ami
  instance_type = lookup(var.instance_type, terraform.workspace, "t2.micro")
  subnet_id     = data.aws_subnets.default.ids[0]
}