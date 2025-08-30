resource "aws_vpc" "loadBalancer_VPC" {

    cidr_block      = var.CIDR_range
    
    tags = {

      Name          = "LoadBancer_VPC"
    
    }
}

resource "aws_subnet" "public_subnet_1" {

    vpc_id              = aws_vpc.loadBalancer_VPC.id
    availability_zone   = var.availability_zone_public_subnet_1
    cidr_block          = var.CIDR_Range_public_subnet_1

    tags = {
      
      Name = "Public_Subnet_1"
        
    }
}

resource "aws_subnet" "public_subnet_2" {

    vpc_id              = aws_vpc.loadBalancer_VPC.id
    availability_zone   = var.availability_zone_public_subnet_2
    cidr_block          = var.CIDR_Range_public_subnet_2

    tags = {

        Name            = "Public_Subnet_2"
    
    }
}

resource "aws_route_table" "Public_Route_Table" {

    vpc_id = aws_vpc.loadBalancer_VPC.id

    tags = {

      Name = "Public_Route_Table"
    
    }
}


resource "aws_internet_gateway" "IG" {

    vpc_id = aws_vpc.loadBalancer_VPC.id

    tags = {

      Name = "Loadbalancer_IG"
    
    }
}

resource "aws_route_table_association" "public_subnet_attach_1" {

    subnet_id = aws_subnet.public_subnet_1.id
    route_table_id = aws_route_table.Public_Route_Table.id

}

resource "aws_route_table_association" "public_subnet_attach_2" {

    subnet_id = aws_subnet.public_subnet_2.id
    route_table_id = aws_route_table.Public_Route_Table.id
}

resource "aws_route" "public_route" {

    route_table_id = aws_route_table.Public_Route_Table.id
    gateway_id = aws_internet_gateway.IG.id
    destination_cidr_block = "0.0.0.0/0"

}

resource "aws_security_group" "Loadbalancer_SG" {

    vpc_id = aws_vpc.loadBalancer_VPC.id

    tags = {

      Name = "Loadbalaner_SG"
    
    }
}

resource "aws_security_group_rule" "Inbound_HTTP" {

    security_group_id = aws_security_group.Loadbalancer_SG.id
    type = "ingress"
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
}

resource "aws_security_group_rule" "Inbound_SSH" {

    security_group_id = aws_security_group.Loadbalancer_SG.id
    type = "ingress"
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]

}

resource "aws_security_group_rule" "Outbound" {

    security_group_id = aws_security_group.Loadbalancer_SG.id
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  
}

resource "aws_key_pair" "Loadbalancer_key" {

    key_name = "Key"
    public_key = file("~/.ssh/id_rsa.pub")
  
}

resource "aws_instance" "webserver" {

    ami = var.ami_image
    instance_type = var.instance_type_image
    subnet_id = aws_subnet.public_subnet_1.id
    associate_public_ip_address = true
    key_name = aws_key_pair.Loadbalancer_key.key_name
    security_groups = [aws_security_group.Loadbalancer_SG.id]
    count = 2

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host = self.public_ip
    }   

    provisioner "remote-exec" {

        inline = [ 
            
            "sudo apt-get update -y",
            "sudo apt install apache2 -y",
            "sudo systemctl enable apache2",
            "sudo systemctl start apache2",
            "echo 'complete'"
         ]  
      
    }
    
    tags = {
      
      Name = "instance-${count.index}"
    
    }
}


resource "aws_lb" "Application_LB" {

    name = "ALB"
    internal = false
    ip_address_type = "ipv4"
    load_balancer_type = "application"
    security_groups = [aws_security_group.Loadbalancer_SG.id]
    subnets = [aws_subnet.public_subnet_1.id,aws_subnet.public_subnet_2.id]

    tags = {
      Name = "webserver_ALB"
    }
}

resource "aws_lb_target_group" "ALB_TG" {

    health_check {
      interval = 10
      path = "/"
      protocol = "HTTP"
      timeout = 5
      healthy_threshold = 5
      unhealthy_threshold = 2
    }

    name = "ALBTG"
    port = 80
    protocol = "HTTP"
    target_type = "instance"
    vpc_id = aws_vpc.loadBalancer_VPC.id
  
}

resource "aws_lb_listener" "ALB_listener" {

    load_balancer_arn = aws_lb.Application_LB.arn
    port = 80
    protocol = "HTTP"

    default_action {

      target_group_arn  = aws_lb_target_group.ALB_TG.arn
      type              = "forward"
    
    }
}

resource "aws_lb_target_group_attachment" "Instance_attach" {

    count               = length(aws_instance.webserver)
    target_group_arn    = aws_lb_target_group.ALB_TG.arn
    target_id           = aws_instance.webserver[count.index].id
  
}