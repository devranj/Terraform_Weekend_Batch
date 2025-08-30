provider "aws" {

    region = "us-west-2"
  
}


module "vpc_Peering_01" {

    source                      = "./module"
    cidr_block                  = "10.0.0.0/16"
    vpc_name                    = "VPC_1"
    
    Public_Subnet_Name          = "PUblic_Subnet_01"
    public_Subet_CIDR_range     = "10.0.0.0/24"

    public_route_table_name     = "public_route_table_vpc_1"

}

module "vpc_Peering_02" {

    source                      = "./module"
    cidr_block                  = "192.168.0.0/16"
    vpc_name                    = "VPC_2"
  
    Public_Subnet_Name          = "Pulic_Subnet_01"
    public_Subet_CIDR_range     = "192.168.0.0/24"
  
    public_route_table_name     = "public_route_table_vpc_2"

}

resource "aws_vpc_peering_connection" "VPC_Peering" {

    vpc_id                      = module.vpc_Peering_01.vpc_id
    peer_vpc_id                 = module.vpc_Peering_02.vpc_id
    auto_accept                 = true
}

provider "aws" {

    alias                       = "accepter"
    region                      = "us-west-2"
  
}

resource "aws_vpc_peering_connection_accepter" "accepter" {

    provider                    = aws.accepter
    vpc_peering_connection_id   = aws_vpc_peering_connection.VPC_Peering.id
}

resource "aws_route" "route_to_vpc_2" {

    route_table_id              = module.vpc_Peering_01.route_table_id
    destination_cidr_block      = module.vpc_Peering_02.CIDR_block
    vpc_peering_connection_id   = aws_vpc_peering_connection.VPC_Peering.id

}

resource "aws_route" "route_to_vpc_1" {

    route_table_id              = module.vpc_Peering_02.route_table_id
    destination_cidr_block      = module.vpc_Peering_01.CIDR_block
    vpc_peering_connection_id   = aws_vpc_peering_connection.VPC_Peering.id
  
}

resource "aws_instance" "vpc1" {

    subnet_id                   = module.vpc_Peering_01.subnet_id
    ami                         = "ami-05f991c49d264708f"
    instance_type               = "t2.micro"
    associate_public_ip_address = true
    key_name                    = module.vpc_Peering_01.key

    tags = {

      Name                      = "vpc_01_Instance"
    
    }
}

resource "aws_instance" "vpc2" {

    subnet_id                   = module.vpc_Peering_02.subnet_id
    availability_zone           = "us-west-2c"
    ami                         = "ami-05f991c49d264708f"
    instance_type               = "t2.small"
    associate_public_ip_address = true
    key_name                    = module.vpc_Peering_02.key

    tags = {

      Name                      = "vpc_02_instance"
    
    }
}