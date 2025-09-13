resource "aws_vpc" "aatif_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "aatif_subnet1" {
  vpc_id                  = aws_vpc.aatif_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "aatif_subnet1"
  }
}

resource "aws_subnet" "aatif_subnet2" {
  vpc_id                  = aws_vpc.aatif_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "aatif_subnet2"
  }

}

resource "aws_internet_gateway" "aatif_internetgateway_igw" {
  vpc_id = aws_vpc.aatif_vpc.id

  tags = {
    name = "aatif_internetgateway_igw"

  }

}

resource "aws_route_table" "aatif_routetable" {
  vpc_id = aws_vpc.aatif_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aatif_internetgateway_igw.id
  }

  tags = {
    name = "aatif_routetable"
  }
}

resource "aws_route_table_association" "aatif_routetableassociation1" {
  subnet_id      = aws_subnet.aatif_subnet1.id
  route_table_id = aws_route_table.aatif_routetable.id
}

resource "aws_route_table_association" "aatif_routetableassociation2" {
  subnet_id      = aws_subnet.aatif_subnet2.id
  route_table_id = aws_route_table.aatif_routetable.id
}

resource "aws_security_group" "aatif_securitygroup" {
  name        = "aatif_securitygroup"
  description = "allow ssh and http"
  vpc_id      = aws_vpc.aatif_vpc.id

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

}

resource "aws_instance" "your_instance" {
  ami           = "ami-0df7a207adb9748c7"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.aatif_subnet1.id
  security_groups = [aws_security_group.aatif_securitygroup.id]
}

resource "aws_instance" "aatif-ec2" {
  ami           = "ami-0df7a207adb9748c7"
  instance_type = "t2.micro"

  # Reference the already existing key pair in AWS
  key_name      = "aatif-aws-key"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install httpd -y
              systemctl start httpd
              systemctl enable httpd
              echo "Hello from Aatif's EC2!" > /var/www/html/index.html
              EOF

  tags = {
    Name = "aatif-ec2"
  }
}




resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.aatif_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lb" "aatif_alb" {
  name               = "aatif-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = [
    aws_subnet.aatif_subnet1.id,
    aws_subnet.aatif_subnet2.id
  ]

  enable_deletion_protection = false

  tags = {
    Name = "aatif-alb"
  }
}



resource "aws_lb_target_group" "aatif_tg" {
  name     = "aatif-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.aatif_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}



resource "aws_lb_listener" "aatif_listener" {
  load_balancer_arn = aws_lb.aatif_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aatif_tg.arn
  }
}


