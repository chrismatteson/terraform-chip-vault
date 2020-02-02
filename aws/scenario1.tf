resource "random_id" "s1_project_tag" {
  count = length(var.scenario_1_users)
  byte_length = 4
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

resource "aws_vpc" "vpc" {
  count  = length(var.scenario_1_users)
  cidr_block       = "10.0.0.0/16"

  tags = merge(
    var.tags,
    {
      "ProjectTag" = random_id.s1_project_tag[count.index].hex
    },
  )
}

resource "aws_internet_gateway" "gw" {
  count = length(var.scenario_1_users)
  vpc_id = aws_vpc.vpc[count.index].id
}

resource "aws_default_route_table" "table" {
  count = length(var.scenario_1_users)
  default_route_table_id = aws_vpc.vpc[count.index].default_route_table_id
}

resource "aws_route" "public_internet_gateway" {
  count = length(var.scenario_1_users)

  route_table_id         = aws_default_route_table.table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw[count.index].id
}

resource "aws_subnet" "subnet" {
  count  = length(var.scenario_1_users)
  vpc_id     = aws_vpc.vpc[count.index].id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      "ProjectTag" = random_id.s1_project_tag[count.index].hex
    },
  )
}

resource "aws_default_security_group" "vpc_default" {
  count  = length(var.scenario_1_users)
  vpc_id = aws_vpc.vpc[count.index].id

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
  count = length(var.scenario_1_users)
  ami           = data.aws_ami.latest-image.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet[count.index].id
  key_name      = var.ssh_key_name

  user_data = <<EOF
#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y python3-flask
sudo git clone https://github.com/chrismatteson/terraform-chip-vault
cd terraform-chip-vault/flaskapp
python3 app.py
EOF

  tags = merge(
    var.tags,
    {
      "ProjectTag" = random_id.s1_project_tag[count.index].hex
    },
  )
}

resource "aws_iam_role" "instance_role" {
  count = length(var.scenario_1_users)
  name_prefix        = "${random_id.s1_project_tag[count.index].id}-instance-role"
  assume_role_policy = data.aws_iam_policy_document.instance_role.json
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "instance_profile" {
  count = length(var.scenario_1_users)
  name_prefix = "${random_id.s1_project_tag[count.index].id}-instance_profile"
  role        = aws_iam_role.instance_role[count.index].name
}

resource "aws_iam_role_policy_attachment" "SystemsManager" {
  count = length(var.scenario_1_users)
  role       = aws_iam_role.instance_role[count.index].id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_db_instance" "default" {
  count = length(var.scenario_1_users)
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}
