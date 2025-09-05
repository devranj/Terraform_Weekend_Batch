resource "aws_vpc" "P01_VPC" {

    cidr_block = var.cidr_block_P01
  
}

resource "aws_subnet" "public_subnet_01" {

    vpc_id = aws_vpc.P01_VPC.id
    cidr_block = var.cidr_block_public_subnet_01
    availability_zone = var.availability_zone_P01
    map_public_ip_on_launch = true

    tags = {
      
      Name = "public_subnet_01" 
    
    }
}

resource "aws_subnet" "public_subnet_02" {

    vpc_id = aws_vpc.P01_VPC.id
    cidr_block = var.cidr_block_public_subnet_02
    availability_zone = var.availability_zone_P02   
    map_public_ip_on_launch = true

    tags = {
      
      Name = "public_subnet_02" 

    }
}

resource "aws_internet_gateway" "IG" {

    vpc_id = aws_vpc.P01_VPC.id

    tags = {

      Name = "P01_IG"
    
    }
}

resource "aws_route_table" "public_route_table" {

    vpc_id = aws_vpc.P01_VPC.id

    tags = {

      Name = "public_route_table"
    
    }
}

resource "aws_route" "route_1" {

    gateway_id = aws_internet_gateway.IG.id
    route_table_id = aws_route_table.public_route_table.id
    destination_cidr_block = "0.0.0.0/0"
  
}

resource "aws_route_table_association" "public_subnet_attach_01" {

    route_table_id = aws_route_table.public_route_table.id
    subnet_id = aws_subnet.public_subnet_01.id
  
}

resource "aws_route_table_association" "public_subnet_attach_02" {

    route_table_id = aws_route_table.public_route_table.id
    subnet_id = aws_subnet.public_subnet_02.id
  
}

resource "aws_security_group" "P01_SG" {

  name = "P01_SG"
  vpc_id = aws_vpc.P01_VPC.id
  description = "P01 vpc security group"

  tags = {
    Name = "P01_SG"
  }
}

resource "aws_security_group_rule" "inbound" {

  security_group_id = aws_security_group.P01_SG.id
  type = "ingress"
  from_port = "22"
  to_port = "22"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

}

resource "aws_security_group_rule" "outbound" {

  security_group_id = aws_security_group.P01_SG.id
  type = "egress"
  from_port = "0"
  to_port = "0"
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]

}


resource "aws_s3_bucket" "bucketP01" {

  bucket = "P01bucket"

  tags = {
    Name = "bucketP01"
  } 
}

resource "aws_instance" "webserver" {

  ami = ""
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.P01_SG.id]
  subnet_id = aws_subnet.public_subnet_01.id
  user_data = base64encode(file("userdata.sh"))

}

resource "aws_instance" "webserver2" {

  ami = "ami-03a8bb8234272744b"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.P01_SG.id]
  subnet_id = aws_subnet.public_subnet_01.id
  user_data = base64encode(file("userdata2.sh"))

}


resource "aws_lb" "loadbalancerP01" {

  name = "myalb"
  internal = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.P01_SG.id]
  subnets = [aws_subnet.public_subnet_01.id,aws_subnet.public_subnet_02.id]

  tags = {
    Name  ="web" 
    
     }
}

resource "aws_lb_target_group" "tg" {

  name = "myTG"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.P01_VPC.id

  health_check {
    path = "/"
    port = "traffic-port"
  } 
}

resource "aws_lb_target_group_attachment" "attach1" {

  target_group_arn = aws_lb_target_group.tg.arn
  target_id = aws_instance.webserver.id
  port = 80
  
}

resource "aws_lb_target_group_attachment" "attach2" {

  target_group_arn = aws_lb_target_group.tg.arn
  target_id = aws_instance.webserver2.id
  port = 80
  
}

resource "aws_lb_listener" "listener" {

  load_balancer_arn = aws_lb.loadbalancerP01.arn
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}

