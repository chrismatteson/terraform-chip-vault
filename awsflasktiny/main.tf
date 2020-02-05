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
  count         = length(var.scenario_1_users)
  ami           = data.aws_ami.latest-image.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet1[count.index].id
  key_name      = var.ssh_key_name
  iam_instance_profile = aws_iam_instance_profile.instance_profile[count.index].id

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
  "username": "${aws_db_instance.database[count.index].username}",
  "password": "${aws_db_instance.database[count.index].password}",
  "hostname": "${aws_db_instance.database[count.index].address}"
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
      "ProjectTag" = var.project_tag[count.index]
    },
  )
}

resource "aws_iam_role" "instance_role" {
  count              = length(var.scenario_1_users)
  name_prefix        = "${var.project_tag[count.index]}-instance-role"
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
  count       = length(var.scenario_1_users)
  name_prefix = "${var.project_tag[count.index]}-instance_profile"
  role        = aws_iam_role.instance_role[count.index].name
}

resource "aws_iam_role_policy_attachment" "SystemsManager" {
  count      = length(var.scenario_1_users)
  role       = aws_iam_role.instance_role[count.index].id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_db_subnet_group" "db_subnet" {
  count      = length(var.scenario_1_users)
  subnet_ids = [aws_subnet.subnet1[count.index].id, aws_subnet.subnet2[count.index].id]

  tags = merge(
    var.tags,
    {
      "ProjectTag" = var.project_tag[count.index]
    },
  )
}

resource "aws_db_instance" "database" {
  count                  = length(var.scenario_1_users)
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
