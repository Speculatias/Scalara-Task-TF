# Load TF AWS provider and set region
provider "aws" {
  region = "eu-central-1"
}

# Import public key for ssh access
resource "aws_key_pair" "public_key" {
  key_name   = "public_key_pr"  # Key name in AWS
  public_key = file("~/.ssh/id_rsa.pub")  # Local path to public key
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Create public subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Connect routing table with subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create security group
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id

  # Allow ssh connections
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["88.130.144.126/32"]
  }

  # Allow http connections
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["88.130.144.126/32"]
  }

  # Allow outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 instance
resource "aws_instance" "web" {
  ami           = "ami-0e54671bdf3c8ed8d" # Amazon Linux 2023 / ec2-user
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name      = aws_key_pair.public_key.key_name  # Link public key

  # Install docker and docker compose via script on resource
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    service docker start
    usermod -aG docker ec2-user
    chkconfig docker on

    # Install Docker Compose
    curl -L "https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

    # Install GIT
    yum install -y git

    # Clone example project
    cd /home/ec2-user && git clone https://github.com/Speculatias/Scalara-Task-Web-Example.git
    cd /home/ec2-user/Scalara-Task-Web-Example && docker-compose up -d --force-recreate --build
  EOF

  tags = {
    Name = "web-server"
  }
}

output "instance_public_ip" {
  value = aws_instance.web.public_ip
}