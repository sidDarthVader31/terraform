variable "instance_type" {
 description = "Type of EC2 instance to provision"
 default     = "t3.nano"
}


variable "ami_filter"  {
  description = "name filter and owner for ami"
  type = object({
    name = string
    owner = string
  })

  default = {
    name = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" 
    owner      = "099720109477" # Official Canonical Ubuntu Owner ID
  }
}

variable "environment" {
  type = object({
    name = string
    network_prefix = string
  })
  default = {
    name = "dev"
    network_prefix = "10.0"
  }
  description = "deployment environment"
}


variable "min_size" {
  default = 1
  description = "minimum no of instances in asg"
}

variable "max_size" {
  default = 2
  description = "maxmimum no of instances in asg"
  
}

