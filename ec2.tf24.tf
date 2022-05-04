#### Shared resources
# VPC
resource "aws_vpc" "apsouth1-ec2-vpc1" {
  cidr_block = "10.0.0.0/16"
}

# Subnet
resource "aws_subnet" "apsouth1-ec2-subnet1" {
  vpc_id                  = aws_vpc.apsouth1-ec2-vpc1.id 
  availability_zone       = "ap-south-1a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "apsouth1-ec2-subnet2" {
  vpc_id                  = aws_vpc.apsouth1-ec2-vpc1.id 
  availability_zone       = "ap-south-1b"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
}

#######################################################

#### SSH is open to everyone(0.0.0.0)
# Key Pair
resource "aws_key_pair" "apsouth1-ec2-keypair" {
  key_name   = "apsouth1-ec2-keypair"
  public_key = file("./ec2-sshpublickey.pub")
}

# Internet_Gateway
resource "aws_internet_gateway" "apsouth1-ec2-internetgateway1" {
  vpc_id = aws_vpc.apsouth1-ec2-vpc1.id
}

# Route_Table
resource "aws_route" "apsouth1-ec2-route1" {
  route_table_id         = aws_vpc.apsouth1-ec2-vpc1.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.apsouth1-ec2-internetgateway1.id
}

# Security_Group
resource "aws_security_group" "apsouth1-ec2-securitygroup1" {
  name        = "apsouth1-ec2-ssh"
  description = "Allow SSH in and outbound internet access"
  vpc_id      = aws_vpc.apsouth1-ec2-vpc1.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security_Group to allow http and https
resource "aws_security_group" "apsouth1-ec2-securitygroup2" {
  name        = "apsouth1-ec2-httphttps"
  description = "Allow HTTP and HTTPs"
  vpc_id      = aws_vpc.apsouth1-ec2-vpc1.id

  # HTTP access from anywhere
  ingress {
    from_port   = 80 
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPs access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "apsouth1-ec2" {
  ami = "ami-0620d12a9cf777c87"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.apsouth1-ec2-keypair.key_name

 connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./ec2-sshprivatekey")
  }

  vpc_security_group_ids = ["${aws_security_group.apsouth1-ec2-securitygroup1.id}","${aws_security_group.apsouth1-ec2-securitygroup2.id}"]
  subnet_id = aws_subnet.apsouth1-ec2-subnet1.id
  monitoring = "false"  
  tags = { 
    name = "apsouth1-ec2"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo service nginx start",
    ]
  }
}

######################################################


### RDP connection is open to everyone(0.0.0.0)
# Key Pair
resource "aws_key_pair" "apsouth1-ec2-keypair" {
  key_name   = "apsouth1-ec2-keypair"
  public_key = file("./ec2-sshpublickey.pub")
}

# Internet_Gateway
resource "aws_internet_gateway" "apsouth1-ec2-internetgateway1" {
  vpc_id = aws_vpc.apsouth1-ec2-vpc1.id
}

# Route_Table
resource "aws_route" "apsouth1-ec2-route1" {
  route_table_id         = aws_vpc.apsouth1-ec2-vpc1.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.apsouth1-ec2-internetgateway1.id
}

# Security_Group
resource "aws_security_group" "apsouth1-ec2-securitygroup-rdpopentoall" {
  name        = "apsouth1-ec2-rdpopentoall"
  description = "Allow RDP in and outbound internet access"
  vpc_id      = aws_vpc.apsouth1-ec2-vpc1.id

  # SSH access from anywhere
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "apsouth1-ec2-rdpopentoall" {
  ami = "ami-09ed03e97033b6d21"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.apsouth1-ec2-securitygroup-rdpopentoall.id}"]
  subnet_id = aws_subnet.apsouth1-ec2-subnet1.id
  monitoring = "false"  
  tags = { 
    name = "apsouth1-ec2-rdpopentoall"
  }
}














































