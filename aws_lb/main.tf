provider "aws" {

    region = "us-east-1"

}

/* VPC Declaration with CIDR Range */

resource "aws_vpc" "ALB" {

    cidr_block = "192.168.0.0/16"

    tags = {
     
      Name = "Application_Load_Balancer"

    }

}

/* Public Subnet 1 */

resource "aws_subnet" "public_1" {

    vpc_id                      = aws_vpc.ALB.id
    cidr_block                  = "192.168.1.0/24"
    availability_zone           = "us-east-1a"
    map_public_ip_on_launch     = true

    tags = {
      Name                      = "Public_Subnet_1"
    }
}

/* Public Subnet 2 */

resource "aws_subnet" "public_2" {

    vpc_id                      = aws_vpc.ALB.id
    cidr_block                  = "192.168.2.0/24"
    availability_zone           = "us-east-1b"

    map_public_ip_on_launch     = true

    tags = {
     
     Name                       = "Public_Subnet_2"

    }
}

/* Internet Gateway */

resource "aws_internet_gateway" "IG" {

    vpc_id = aws_vpc.ALB.id

}

/* Route Table */

resource "aws_route_table" "Public_Route_Table" {
 
  vpc_id = aws_vpc.ALB.id

  tags = {
   
    Name = "Public_Route_Table"

  }
}

/* Routes for public route_table */

resource "aws_route" "route" {

    route_table_id          = aws_route_table.Public_Route_Table.id
    gateway_id              = aws_internet_gateway.IG.id
    destination_cidr_block  = "0.0.0.0/0"

}

/* Route Table Association with the Public Subnet 1 */

resource "aws_route_table_association" "public_subnet_association_1" {
 
  route_table_id    = aws_route_table.Public_Route_Table.id
  subnet_id         = aws_subnet.public_1.id

}

/* Route Table association with the Public subnet 2 */

resource "aws_route_table_association" "public_subnet_association_2" {

    route_table_id      = aws_route_table.Public_Route_Table.id
    subnet_id           = aws_subnet.public_2.id
 
}

/* Security Group  */

resource "aws_security_group" "SG" {

    name = "SG_Web"
    vpc_id = aws_vpc.ALB.id

    tags = {
       
        Name = "Security Group"

    }
 
}

/* Security Group Rule for ssh */

resource "aws_security_group_rule" "Inbound_1" {

    type                = "ingress"
    from_port           = 22
    to_port             = 22
    protocol            = "tcp"
    cidr_blocks         = ["0.0.0.0/0"]
    security_group_id   = aws_security_group.SG.id

    description         = "SSH Inbound Rule"

}

/* Security Group Rule for http */

resource "aws_security_group_rule" "Inbound_2" {

    type                = "ingress"
    to_port             = 80
    from_port           = 80
    protocol            = "tcp"
    cidr_blocks         = ["0.0.0.0/0"]
    security_group_id   = aws_security_group.SG.id

    description         = "http Inbound Rule"

}

/* Security Group Rule for Outbound */

resource "aws_security_group_rule" "Outbound" {

    type                = "egress"
    to_port             = 0
    from_port           = 0
    protocol            = "-1"
    cidr_blocks         = ["0.0.0.0/0"]
    security_group_id   = aws_security_group.SG.id
   
    description         = "Outbound Rule for the SG"

}

/* S3 Bucket */

resource "aws_s3_bucket" "alb-test-bucket-example" {

    bucket = "alb-test-bucket-example"

}

/* Instance Launching Webserver 1 */

resource "aws_instance" "webserver_1" {

  ami                       = "ami-05f991c49d264708f"
  instance_type             = "t2.micro"
  vpc_security_group_ids    = [aws_security_group.SG.id]
  subnet_id                 = aws_subnet.public_1.id
  user_data_base64          = base64encode(file("userdata_1.sh"))

  tags = {
    Name = "webserver_1"
  }
}

/* Instance Launching Webserver 2 */

resource "aws_instance" "webserver_2" {

    ami                         = "ami-05f991c49d264708f"
    instance_type               = "t2.micro"
    vpc_security_group_ids      = [aws_security_group.SG.id]
    subnet_id                   = aws_subnet.public_2.id
    user_data_base64            = base64encode(file("userdata_2.sh"))

    tags = {
      Name                      = "webserver_2"
    }
}

/Creating an application Load balancer/

resource "aws_lb" "myalb" {

    name                        = "myalb"
    internal                    = false
    load_balancer_type          = "application"

    security_groups             = [aws_security_group.SG.id]
    subnets                     = [aws_subnet.public_1.id, aws_subnet.public_2.id]

    tags = {
      Name                      = "Web"
    }
}

/* Creating a Application Load Balancer Target Group*/

resource "aws_lb_target_group" "alb_tg" {

    name                        = "myTG"
    port                        = 80
    protocol                    = "HTTP"
    vpc_id                      = aws_vpc.ALB.id

    health_check {
      path                      = "/"
      port                      = "traffic-port"
    }
}

resource "aws_lb_target_group_attachment" "attach_1" {

    target_group_arn        = aws_lb_target_group.alb_tg.arn
    target_id               = aws_instance.webserver_1.id
    port                    = 80
 
}

resource "aws_lb_target_group_attachment" "attach_2" {

  target_group_arn          = aws_lb_target_group.alb_tg.arn
  target_id                 = aws_instance.webserver_2.id
  port                      = 80

}

resource "aws_lb_listener" "listener" {

    load_balancer_arn       = aws_lb.myalb.arn
    port                    = 80
    protocol                = "HTTP"

    default_action {
      target_group_arn      = aws_lb_target_group.alb_tg.arn
      type                  = "forward"
    }
}

output "loadbalancerdns" {

    value                   = aws_lb.myalb.dns_name
 
}