# Define default VPC
resource "aws_default_vpc" "default" {}

resource "aws_security_group" "bastion-sg" {
  name   = "bastion-security-group"
  vpc_id = "${aws_default_vpc.default.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["87.146.137.100/32"]
  }

  egress {
    protocol    = -1
    from_port   = 0 
    to_port     = 0 
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = "ami-0747bdcabd34c712a"
  key_name                    = "${aws_key_pair.bastion_key.key_name}"
  instance_type               = "t2.micro"
  security_groups             = [ "${aws_security_group.bastion-sg.name}" ]
  associate_public_ip_address = true

  tags = {
    Name = "aruna003-bastion"
  }
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "aruna003_key_name"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCzAoy0d56QyM7anF58fq1afmkQqGF9o9T6yF3b0FbNSDyquF8fIlRk2VEX0PgSBf9qggpJDA3WTBmV18qKAuCrmfILBKs8ydmZEgEt/62r3RbwK3eSnKhwgk/6Jg1BnEHZDKMq8H9H7XXUhrWYqOgnVY7WhCAsUcHNEhMEn3eQ4SW1VhOLmABaH0jeCMtEdx8pmiRhi9RVnIfte9pETaaoLQ70lrJU8eQdeT1FyM17epul0yqq46cE1Cd6C9+l6IJXdwj+KsWCvfmlzcCNcV7tgTmM+ix77yaXrT3fOj+6x8jLiBHad+IygGqWxwePzJ7fghpR5qEjeMbVeX7CbJnRPC9v71KxeGqi6KaBXswUs2dFVpItJqgofLZ5UeovZOMIp5ee8OV7JZQnnUvbaAEuK0beqkD/6ngxUpIpDMYMB+cjAzDri7mKREg9JMsdODk5ltiJOkqGFh7V8MbtlbIgrS4j6owjaqHqllmpRj/SdRwj4Z5Cwecsd6jQVAjvQEnCwzNUSz3kEw9FOQCrPQ2bI+f7k3nIntl5bLzMZ/WnbP59ZvEc38mKkBkPlI2AQ/hCoABzS3S6JsfzdV3eFYHqtVhWdSHecTfFS50m30m59HxW9JQuTp2fwyENUAWj9clCifa8LxpYVNaJ9Q6ETqNLPc1fs05ymB3d9ja9rMsxVQ== arunanerellamail@gmail.com"
}

output "bastion_public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}