provider "aws" {
  profile = "training"
  region  = "us-east-1"
}

resource "random_id" "project_tag" {
  byte_length = 4
}

resource "tls_private_key" "decrypt" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "aws_iam_user" "user" {
  count         = length(var.users)
  name          = element(var.users, count.index)
  path          = "/"
  force_destroy = true
}

resource "aws_iam_user_login_profile" "user" {
  count   = length(var.users)
  user    = aws_iam_user.user[count.index].name
  pgp_key = "keybase:chrismatteson"
}

# Setup customer application
# Lookup most recent AMI
data "aws_ami" "latest-image" {
  most_recent = true
  owners      = var.ami_filter_owners

  filter {
    name   = "name"
    values = var.ami_filter_name
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "${random_id.project_tag.hex}-vpc"

  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Name = "overridden-name-public"
  }


  vpc_tags = {
    Name = "${random_id.project_tag.hex}-vpc"
  }
}

resource "aws_default_security_group" "vpc_default" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "web" {
  ami           = "${data.aws_ami.latest-image.id}"
  instance_type = "t2.micro"
  subnet_id     = module.vpc.public_subnets[0]
  key_name      = var.ssh_key_name

  user_data = <<EOF
sudo apt-get update -y
sudo apt-get install -y python3-flask
git clone https://github.com/chrismatteson/terraform-chip-vault
cd terraform-chip-vault/flaskapp
python3 app.py
EOF

  tags = {
    Name = "HelloWorld"
  }
}

