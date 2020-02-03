provider "aws" {
  profile = "training"
  region  = "us-east-1"
}

provider "aws" {
  alias   = "us-west-1"
  profile = "training"
  region  = "us-west-1"
}

provider "aws" {
  alias   = "us-west-2"
  profile = "training"
  region  = "us-west-2"
}

provider "aws" {
  alias   = "eu-central-1"
  profile = "training"
  region  = "eu-central-1"
}

provider "aws" {
  alias   = "eu-west-1"
  profile = "training"
  region  = "eu-west-1"
}

provider "aws" {
  alias   = "ap-southeast-1"
  profile = "training"
  region  = "ap-southeast-1"
}

resource "aws_iam_user" "s1_user" {
  count         = length(var.scenario_1_users)
  name          = element(var.scenario_1_users, count.index)
  path          = "/"
  force_destroy = true
}

resource "aws_iam_user" "s2_user" {
  count         = length(var.scenario_2_users)
  name          = element(var.scenario_2_users, count.index)
  path          = "/"
  force_destroy = true
}

resource "aws_iam_user" "s3_user" {
  count         = length(var.scenario_3_users)
  name          = element(var.scenario_3_users, count.index)
  path          = "/"
  force_destroy = true
}

resource "aws_iam_user" "s4_user" {
  count         = length(var.scenario_4_users)
  name          = element(var.scenario_4_users, count.index)
  path          = "/"
  force_destroy = true
}

resource "aws_iam_user" "s5_user" {
  count         = length(var.scenario_5_users)
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

# Scenario1
resource "random_id" "s1_project_tag" {
  count       = length(var.scenario_1_users)
  byte_length = 4
}

module "scenario_1_west" {
  source           = "./modules/scenario1"
  project_tag      = random_id.s1_project_tag[*].hex
  scenario_1_users = var.scenario_1_users
  ssh_key_name     = var.ssh_key_name
  providers = {
    aws = aws.us-west-1
  }
}

module "scenario_1_west_dr" {
  source           = "./modules/scenario1"
  project_tag      = random_id.s1_project_tag[*].hex
  scenario_1_users = var.scenario_1_users
  ssh_key_name     = var.ssh_key_name
  providers = {
    aws = aws.us-west-2
  }
}


module "scenario_1_eu" {
  source           = "./modules/scenario1"
  project_tag      = random_id.s1_project_tag[*].hex
  scenario_1_users = var.scenario_1_users
  ssh_key_name     = var.ssh_key_name
  providers = {
    aws = aws.eu-central-1
  }
}


module "scenario_1_eu_dr" {
  source           = "./modules/scenario1"
  project_tag      = random_id.s1_project_tag[*].hex
  scenario_1_users = var.scenario_1_users
  ssh_key_name     = var.ssh_key_name
  providers = {
    aws = aws.eu-west-1
  }
}


module "scenario_1_ap" {
  source           = "./modules/scenario1"
  project_tag      = random_id.s1_project_tag[*].hex
  scenario_1_users = var.scenario_1_users
  ssh_key_name     = var.ssh_key_name
  providers = {
    aws = aws.ap-southeast-1
  }
}
