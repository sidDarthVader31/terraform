data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["099720109477"] # Official Canonical Ubuntu Owner ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
data "aws_vpc" default {
  default = true
}

resource "aws_instance" "blog" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  # Bootstrap script to install Tomcat automatically
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install tomcat9 tomcat9-admin -y
              EOF

  vpc_security_group_ids = [aws_security_group.blog.id]
  tags = {
    Name = "learning terraform"
  }
}


resource "aws_security_group" "blog" {
  name          = "blog"
  description   = "allow http and https in. Allow everything out"
  vpc_id = data.aws_vpc.default.id
}



resource "aws_security_group_rule" "blog_http_in" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog.id
}


resource "aws_security_group_rule" "blog_https_in" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog.id
}

resource "aws_security_group_rule" "blog_everything_out" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = -1 
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog.id
}
