provider "aws" {

  region = "us-west-2"
  
}


resource "aws_vpc" "python_vpc" {

  cidr_block = "10.0.0.0/16"

  tags = {

    Name = "python_VPC"
  
  }
}


resource "aws_subnet" "public_Subnet" {

  vpc_id = aws_vpc.python_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-west-2a"

  tags = {

    Name = "public_subnet"
  
  }
}

resource "aws_internet_gateway" "IG" {

  vpc_id = aws_vpc.python_vpc.id
  
  tags = {

    Name = "Python_IG"
  
  }
}

resource "aws_route_table" "public_Route_Table" {

  vpc_id = aws_vpc.python_vpc.id

  tags = {

    Name = "public_Route_Table"
  
  }
}


resource "aws_route_table_association" "attach1" {

  route_table_id = aws_route_table.public_Route_Table.id
  subnet_id = aws_subnet.public_Subnet.id

}

resource "aws_route" "route_1" {

  route_table_id = aws_route_table.public_Route_Table.id
  gateway_id = aws_internet_gateway.IG.id
  destination_cidr_block = "0.0.0.0/0"
  
}


resource "aws_key_pair" "Key" {

  key_name = "python_key"
  public_key = file("~/.ssh/id_rsa.pub")

}

resource "aws_security_group" "python_SG" {

  vpc_id = aws_vpc.python_vpc.id

  tags = {

    Name = "python_SG"
  
  }
}

resource "aws_security_group_rule" "inbound_1" {

  security_group_id = aws_security_group.python_SG.id
  type = "ingress"
  from_port = "22"
  to_port = "22"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "inbound_2" {

  security_group_id = aws_security_group.python_SG.id
  type = "ingress"
  from_port = "80"
  to_port = "80"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 
}

resource "aws_security_group_rule" "outbound" {

  security_group_id = aws_security_group.python_SG.id
  type = "egress"
  from_port = "0"
  to_port = "0"
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]

}

resource "aws_instance" "webserver_python_1" {

  ami = "ami-05f991c49d264708f"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.python_SG.id]
  subnet_id = aws_subnet.public_Subnet.id
  associate_public_ip_address = true

  key_name = aws_key_pair.Key.key_name

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host = self.public_ip
  }

  provisioner "file" {

    source = "app.py"
    destination = "/home/ubuntu/app.py"  
  
  }

  provisioner "file" {

    source = "index.html"
    destination = "/home/ubuntu/index.html"
    
  }

  provisioner "remote-exec" {

    inline = [ 

        "echo 'Hello This is DNA simulation'",
        "sudo apt-get -y update",
        "sudo apt install -y apache2",
        "sudo systemctl enable apache2",
        "sudo systemctl start apache2",
        "sudo apt install -y python3-flask",
        "sudo rm -rf /var/www/html/index.html",
        "sudo cp /home/ubuntu/index.html /var/www/html",
        "cd /home/ubuntu",
        "python3 app.py &"
        
     ]

  }

  tags = {

    Name = "Webserver_python_1"
  }
}

output "Public_IP_Address" {

  description = "To check the html file use the below IP address"
  value = aws_instance.webserver_python_1.public_ip
}