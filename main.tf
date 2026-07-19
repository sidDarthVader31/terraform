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

resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  # Bootstrap script to install Tomcat automatically
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install tomcat9 tomcat9-admin -y
              EOF

  tags = {
    Name = "HelloWorld"
  }
}

