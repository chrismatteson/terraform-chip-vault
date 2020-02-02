provider "aws" {
  profile = "training"
  region  = "us-east-1"
}

resource "aws_iam_user" "s1_user" {
  count = length(var.scenario_1_users)
  name          = element(var.scenario_1_users, count.index)
  path          = "/"
  force_destroy = true
}

resource "aws_iam_user" "s2_user" {
  count = length(var.scenario_2_users)
  name          = element(var.scenario_2_users, count.index)
  path          = "/"
  force_destroy = true
}

resource "aws_iam_user" "s3_user" {
  count = length(var.scenario_3_users)
  name          = element(var.scenario_3_users, count.index)
  path          = "/"
  force_destroy = true
}

resource "aws_iam_user" "s4_user" {
  count = length(var.scenario_4_users)
  name          = element(var.scenario_4_users, count.index)
  path          = "/"
  force_destroy = true
}

resource "aws_iam_user" "s5_user" {
  count = length(var.scenario_5_users)
  name          = element(var.scenario_5_users, count.index)
  path          = "/"
  force_destroy = true
}

resource "aws_iam_user_login_profile" "s1_user" {
  count   = length(var.scenario_1_users)
  user    = aws_iam_user.s1_user[count.index].name
  pgp_key = "keybase:chrismatteson"
}

resource "aws_iam_user_login_profile" "s2_user" {
  count   = length(var.scenario_2_users)
  user    = aws_iam_user.s2_user[count.index].name
  pgp_key = "keybase:chrismatteson"
}

resource "aws_iam_user_login_profile" "s3_user" {
  count   = length(var.scenario_3_users)
  user    = aws_iam_user.s3_user[count.index].name
  pgp_key = "keybase:chrismatteson"
}

resource "aws_iam_user_login_profile" "s4_user" {
  count   = length(var.scenario_4_users)
  user    = aws_iam_user.s4_user[count.index].name
  pgp_key = "keybase:chrismatteson"
}

resource "aws_iam_user_login_profile" "s5_user" {
  count   = length(var.scenario_5_users)
  user    = aws_iam_user.s5_user[count.index].name
  pgp_key = "keybase:chrismatteson"
}

# Fix this later if it's important
#data "external" "decrypt" {
#  count = length(var.scenario_1_users)
#  program = ["echo", aws_iam_user_login_profile.s1_user[count.index].encrypted_password, "| base64 --decode | keybase pgp decrypt"]
#}
