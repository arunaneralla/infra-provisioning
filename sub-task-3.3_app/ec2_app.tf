resource "aws_security_group" "app-sg" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  ingress {
      description = "http"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["${var.myip}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "aruna003-app-sg"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "webserver" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro" 
  key_name  = "${var.key_pair_key_name}"
  security_groups=[aws_security_group.app-sg.name]
  user_data       = "${file("install_app.sh")}"
  tags = {
    Name = "aruna003_app_instance"
  }
}

output "DNS" {
  value = aws_instance.webserver.public_dns
}