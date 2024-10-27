provider "aws" {
  region  = "us-east-1"
}

data "terraform_remote_state" "main" {
  backend = "s3"
  config = {
    bucket = "acs730-lab4-jcaranay"
    key    = "${var.env}/networking/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "public_subnet" {
  backend = "s3"
  config = {
    bucket = "acs730-lab4-jcaranay"
    key    = "${var.env}/networking/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  default_tags = merge(var.default_tags, { "ENV" : upper(var.env) })
  name_prefix  = upper("${var.namespace}-${var.env}")
}


resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.mykp.key_name
  subnet_id                   = data.terraform_remote_state.public_subnet.outputs.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true
  user_data                   = file(var.user_data_location)
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-EC2"
    }
  )
}

resource "aws_key_pair" "mykp" {
  key_name   = var.key_pair_name
  public_key = file(var.key_pair_location)
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-KP"
    }
  )
}


# Security Group
resource "aws_security_group" "sg" {
  name        = "allow_http_ssh"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.main.outputs.vpc_id

  ingress {
    description = "HTTP from everywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from everywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-SG"
    }
  )
}


resource "aws_eip" "static_eip" {
  instance = aws_instance.ec2.id
  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-EIP"
    }
  )
}


