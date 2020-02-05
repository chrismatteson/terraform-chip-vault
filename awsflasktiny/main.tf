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


data "aws_availability_zones" "available" {
  state = "available"
}


resource "aws_instance" "web" {
  ami           = data.aws_ami.latest-image.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet1[count.index].id
  key_name      = var.ssh_key_name
  iam_instance_profile = aws_iam_instance_profile.instance_profile.id

  user_data = <<EOF
#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y python3-flask
sudo apt-get install -y python3-pandas
sudo apt-get install -y python3-pymysql
sudo apt-get install -y python3-boto3

sudo useradd flask
sudo mkdir -p /opt/flask
sudo chown -R flask:flask /opt/flask
sudo git clone https://github.com/chrismatteson/terraform-chip-vault
cp -r terraform-chip-vault/flaskapp/* /opt/flask/

mysqldbcreds=$(cat <<MYSQLDBCREDS
{
  "username": "${aws_db_instance.database.username}",
  "password": "${aws_db_instance.database.password}",
  "hostname": "${aws_db_instance.database.address}"
}
MYSQLDBCREDS
)

echo -e "$mysqldbcreds" > /opt/flask/mysqldbcreds.json

systemd=$(cat <<SYSTEMD
[Unit]
Description=Flask App for CHIP Vault Certification
After=network.target

[Service]
User=flask
WorkingDirectory=/opt/flask
ExecStart=/usr/bin/python3 app.py
Restart=always

[Install]
WantedBy=multi-user.target
SYSTEMD
)

echo -e "$systemd" > /etc/systemd/system/flask.service

sudo systemctl daemon-reload
sudo systemctl enable flask.service
sudo systemctl restart flask.service
EOF

  tags = merge(
    var.tags,
    {
      "ProjectTag" = var.project_tag
    },
  )
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = "${var.project_tag}-instance-role"
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
  name_prefix = "${var.project_tag}-instance_profile"
  role        = aws_iam_role.instance_role.name
}

resource "aws_iam_role_policy_attachment" "SystemsManager" {
  role       = aws_iam_role.instance_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_db_subnet_group" "db_subnet" {
  subnet_ids = [aws_subnet.subnet1[count.index].id, aws_subnet.subnet2[count.index].id]

  tags = merge(
    var.tags,
    {
      "ProjectTag" = var.project_tag
    },
  )
}

resource "aws_db_instance" "database" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = "mydb"
  username               = "foo"
  password               = "foobarbaz"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.db_subnet[count.index].id
  vpc_security_group_ids = [aws_vpc.vpc[count.index].default_security_group_id]
}
