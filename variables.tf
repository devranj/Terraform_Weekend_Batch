variable "cidr_block_P01" {

    description = "cidr block for the P01 VPC"
    default = "10.0.0.0/16"
  
}

variable "cidr_block_public_subnet_01" {

    description = "cidr range for the public subnet"
    default = "10.0.0.0/24"
  
}

variable "availability_zone_P01" {

    description = "availablity zone for the public subnet"
    default = "ap-south-1a"
  
}

variable "cidr_block_public_subnet_02" {

    description = "cidr range for the public subnet 02"
    default = "10.0.1.0/24"
  
}

variable "availability_zone_P02" {

    description = "availability zone for the public subnet 02"
    default = "ap-south-1b"
  
}