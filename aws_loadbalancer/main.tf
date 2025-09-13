data "aws_availability_zones" "available" {}

resource "aws_vpc" "rishi_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "devops-vpc"
    Environment = "dev"
  }
}

resource "aws_subnet" "rishi_public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.rishi_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
}

resource "aws_subnet" "rishi_private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.rishi_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
}

resource "aws_internet_gateway" "rishi_igw" {
  vpc_id = aws_vpc.rishi_vpc.id

  tags = {
    Name = "devops-igw"
  }
}

resource "aws_route_table" "rishi_public" {
  vpc_id = aws_vpc.rishi_vpc.id
}

resource "aws_route" "rishi_public_internet" {
  route_table_id         = aws_route_table.rishi_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.rishi_igw.id
}

resource "aws_route_table_association" "rishi_public_assoc" {
  count          = length(aws_subnet.rishi_public)
  subnet_id      = aws_subnet.rishi_public[count.index].id
  route_table_id = aws_route_table.rishi_public.id
}

resource "aws_eip" "rishi_nat" {
  domain = "vpc"

  tags = {
    Name = "devops-eip"
  }
}

resource "aws_nat_gateway" "rishi_nat_gw" {
  allocation_id = aws_eip.rishi_nat.id
  subnet_id     = aws_subnet.rishi_public[0].id

  tags = {
    Name = "devops-nat-gw"
  }
}

resource "aws_route_table" "rishi_private" {
  vpc_id = aws_vpc.rishi_vpc.id
}

resource "aws_route" "rishi_private_nat" {
  route_table_id         = aws_route_table.rishi_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.rishi_nat_gw.id
}

resource "aws_route_table_association" "rishi_private_assoc" {
  count          = length(aws_subnet.rishi_private)
  subnet_id      = aws_subnet.rishi_private[count.index].id
  route_table_id = aws_route_table.rishi_private.id
}

resource "aws_security_group" "rishi_alb_sg" {
  vpc_id = aws_vpc.rishi_vpc.id

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

  tags = {
    Name = "devops-alb-sg"
  }
}

resource "aws_security_group" "rishi_web_sg" {
  vpc_id = aws_vpc.rishi_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.rishi_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-web-sg"
  }
}

resource "aws_instance" "rishi_web" {
  count                  = 2
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.rishi_private[count.index].id
  vpc_security_group_ids = [aws_security_group.rishi_web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "Hello from DevOps EC2 $(hostname)" > /var/www/html/index.html
              EOF

  tags = {
    Name        = "devops-web-${count.index}"
    Environment = "dev"
  }
}

resource "aws_lb" "rishi_alb" {
  name               = "devops-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.rishi_alb_sg.id]
  subnets            = aws_subnet.rishi_public[*].id

  tags = {
    Name    = "devops-alb"
    Project = "LB-Demo"
  }
}

resource "aws_lb_target_group" "rishi_tg" {
  name     = "devops-targets"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.rishi_vpc.id
}

resource "aws_lb_target_group_attachment" "rishi_tg_attachment" {
  count            = length(aws_instance.rishi_web)
  target_group_arn = aws_lb_target_group.rishi_tg.arn
  target_id        = aws_instance.rishi_web[count.index].id
  port             = 80
}

resource "aws_lb_listener" "rishi_listener" {
  load_balancer_arn = aws_lb.rishi_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rishi_tg.arn
  }
}

output "rishi_load_balancer_dns" {
  value = aws_lb.rishi_alb.dns_name
}