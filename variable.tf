variable "region" {

    description = "region to deplay the vpc"
    default = "ap-south-1"
  
}

variable "CIDR_range" {

    description = "CIDR range for the VPC"
    default = "10.0.0.0/16"
  
}

variable "availability_zone_public_subnet_1" {

    description = "AZ for the public subnet 1"
    default = "ap-south-1a"
  
}

variable "CIDR_Range_public_subnet_1" {

    description = "CIDR range for the public subnet 1"
    default = "10.0.0.0/24"
  
}

variable "availability_zone_public_subnet_2" {

    description = "AZ for the public subnet 2"
    default = "ap-south-1b"
  
}

variable "CIDR_Range_public_subnet_2" {

    description = "CIDR range for the public subnet 2"
    default = "10.0.1.0/24"
  
}

variable "ami_image" {

    description = "ami image details"
    default = "ami-02d26659fd82cf299" 
}

variable "instance_type_image" {

    description = "resources for the image"
    default = "t2.micro"

}