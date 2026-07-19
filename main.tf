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


resource "aws_instance" "blog" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  # Bootstrap script to install Tomcat automatically
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install tomcat9 tomcat9-admin -y
              EOF

  vpc_security_group_ids = [module.blog_sg.id]
  subnet_id = module.blog_vpc.public_subnets[0]
  tags = {
    Name = "learning terraform"
  }
}


module "blog_vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "dev"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
#
# resource "aws_security_group_rule" "blog_http_in" {
#   type = "ingress"
#   from_port = 80
#   to_port = 80
#   protocol = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]
#
#   security_group_id = aws_security_group.blog.id
# }
#
#
# resource "aws_security_group_rule" "blog_https_in" {
#   type = "ingress"
#   from_port = 80
#   to_port = 80
#   protocol = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]
#
#   security_group_id = aws_security_group.blog.id
# }
#
# resource "aws_security_group_rule" "blog_everything_out" {
#   type = "egress"
#   from_port = 0
#   to_port = 0
#   protocol = -1 
#   cidr_blocks = ["0.0.0.0/0"]
#
#   security_group_id = aws_security_group.blog.id
# }

module "blog_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "blog"
  description = "Example security group"
  vpc_id      = module.blog_vpc.vpc_id

  ingress_rules = {
    https = {
      from_port   = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "10.0.0.0/16"
      description = "HTTPS from internal"
    }
    self-all = {
      ip_protocol                  = "-1"
      referenced_security_group_id = "self"
      description                  = "All traffic from members of this SG"
    }
  }

  egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  tags = {
    Environment = "dev"
  }
}

