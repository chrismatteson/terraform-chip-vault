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
  alias   = "us-east-1"
  profile = "training"
  region  = "us-east-1"
}

provider "aws" {
  alias   = "us-east-2"
  profile = "training"
  region  = "us-east-2"
}

provider "aws" {
  alias   = "ca-central-1"
  profile = "training"
  region  = "ca-central-1"
}

provider "aws" {
  alias   = "sa-east-1"
  profile = "training"
  region  = "sa-east-1"
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
  name          = element(var.scenario_1_users, count.index).username
  path          = "/"
  force_destroy = true
}

resource "aws_iam_user" "s2_user" {
  count         = length(var.scenario_2_users)
  name          = element(var.scenario_2_users, count.index).username
  path          = "/"
  force_destroy = true
}

resource "aws_iam_user" "s3_user" {
  count         = length(var.scenario_3_users)
  name          = element(var.scenario_3_users, count.index).username
  path          = "/"
  force_destroy = true
}

resource "aws_iam_user" "s4_user" {
  count         = length(var.scenario_4_users)
  name          = element(var.scenario_4_users, count.index).username
  path          = "/"
  force_destroy = true
}

resource "aws_iam_user" "s5_user" {
  count         = length(var.scenario_5_users)
  name          = element(var.scenario_5_users, count.index).username
  path          = "/"
  force_destroy = true
}

resource "aws_iam_user_login_profile" "s1_user" {
  count   = length(var.scenario_1_users)
  user    = aws_iam_user.s1_user[count.index].name
  pgp_key = element(var.scenario_1_users, count.index).pgpkey
}

resource "aws_iam_user_login_profile" "s2_user" {
  count   = length(var.scenario_2_users)
  user    = aws_iam_user.s2_user[count.index].name
  pgp_key = element(var.scenario_2_users, count.index).pgpkey
}

resource "aws_iam_user_login_profile" "s3_user" {
  count   = length(var.scenario_3_users)
  user    = aws_iam_user.s3_user[count.index].name
  pgp_key = element(var.scenario_3_users, count.index).pgpkey
}

resource "aws_iam_user_login_profile" "s4_user" {
  count   = length(var.scenario_4_users)
  user    = aws_iam_user.s4_user[count.index].name
  pgp_key = element(var.scenario_4_users, count.index).pgpkey
}

resource "aws_iam_user_login_profile" "s5_user" {
  count   = length(var.scenario_5_users)
  user    = aws_iam_user.s5_user[count.index].name
  pgp_key = element(var.scenario_5_users, count.index).pgpkey
}

resource "aws_iam_access_key" "s1_user" {
  count   = length(var.scenario_1_users)
  user    = aws_iam_user.s1_user[count.index].name
}

resource "aws_iam_access_key" "s2_user" {
  count   = length(var.scenario_2_users)
  user    = aws_iam_user.s2_user[count.index].name
}

resource "aws_iam_access_key" "s3_user" {
  count   = length(var.scenario_3_users)
  user    = aws_iam_user.s3_user[count.index].name
}

resource "aws_iam_access_key" "s4_user" {
  count   = length(var.scenario_4_users)
  user    = aws_iam_user.s4_user[count.index].name
}

resource "aws_iam_access_key" "s5_user" {
  count   = length(var.scenario_5_users)
  user    = aws_iam_user.s5_user[count.index].name
}

# Scenario 1
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

module "scenario_1_eu" {
  source           = "./modules/scenario1"
  project_tag      = random_id.s1_project_tag[*].hex
  scenario_1_users = var.scenario_1_users
  ssh_key_name     = var.ssh_key_name
  providers = {
    aws = aws.eu-central-1
  }
}

resource "aws_directory_service_directory" "s1-ad" {
  provider = aws.us-west-1
  count    = length(var.scenario_1_users)
  name     = "corp.${random_id.s1_project_tag[count.index].hex}.com"
  password = "SuperSecretPassw0rd"
  edition  = "Standard"
  type     = "MicrosoftAD"

  vpc_settings {
    vpc_id     = module.scenario_1_west.vpc_id[count.index]
    subnet_ids = [module.scenario_1_west.subnet1[count.index], module.scenario_1_west.subnet2[count.index]]
  }

  tags = merge(
    var.tags,
    {
      "ProjectTag" = random_id.s1_project_tag[count.index].hex
    },
  )
}

# Scenario 2
resource "random_id" "s2_project_tag" {
  count       = length(var.scenario_2_users)
  byte_length = 4
}

module "scenario_2_east" {
  source           = "./modules/scenario2"
  project_tag      = random_id.s2_project_tag[*].hex
  scenario_1_users = var.scenario_2_users
  ssh_key_name     = var.ssh_key_name
  providers = {
    aws = aws.us-east-2
  }
}

module "scenario_2_eu" {
  source           = "./modules/scenario2"
  project_tag      = random_id.s2_project_tag[*].hex
  scenario_1_users = var.scenario_2_users
  ssh_key_name     = var.ssh_key_name
  providers = {
    aws = aws.eu-central-1
  }
}

resource "aws_directory_service_directory" "s2-ad" {
  provider = aws.us-east-2
  count    = length(var.scenario_2_users)
  name     = "corp.${random_id.s2_project_tag[count.index].hex}.com"
  password = "SuperSecretPassw0rd"
  edition  = "Standard"
  type     = "MicrosoftAD"

  vpc_settings {
    vpc_id     = module.scenario_2_east.vpc_id[count.index]
    subnet_ids = [module.scenario_2_east.subnet1[count.index], module.scenario_2_east.subnet2[count.index]]
  }

  tags = merge(
    var.tags,
    {
      "ProjectTag" = random_id.s2_project_tag[count.index].hex
    },
  )
}

# Scenario 3
resource "random_id" "s3_project_tag" {
  count       = length(var.scenario_3_users)
  byte_length = 4
}

module "scenario_3_east" {
  source           = "./modules/scenario3"
  project_tag      = random_id.s3_project_tag[*].hex
  scenario_1_users = var.scenario_3_users
  ssh_key_name     = var.ssh_key_name
  providers = {
    aws = aws.us-east-1
  }
}

module "scenario_3_eu" {
  source           = "./modules/scenario3"
  project_tag      = random_id.s3_project_tag[*].hex
  scenario_1_users = var.scenario_3_users
  ssh_key_name     = var.ssh_key_name
  providers = {
    aws = aws.eu-central-1
  }
}

resource "aws_directory_service_directory" "s3-ad" {
  provider = aws.us-east-1
  count    = length(var.scenario_3_users)
  name     = "corp.${random_id.s3_project_tag[count.index].hex}.com"
  password = "SuperSecretPassw0rd"
  edition  = "Standard"
  type     = "MicrosoftAD"

  vpc_settings {
    vpc_id     = module.scenario_3_east.vpc_id[count.index]
    subnet_ids = [module.scenario_3_east.subnet1[count.index], module.scenario_3_east.subnet2[count.index]]
  }

  tags = merge(
    var.tags,
    {
      "ProjectTag" = random_id.s1_project_tag[count.index].hex
    },
  )
}

# Scenario 4
resource "random_id" "s4_project_tag" {
  count       = length(var.scenario_4_users)
  byte_length = 4
}

module "scenario_4_ca_central" {
  source           = "./modules/scenario4"
  project_tag      = random_id.s4_project_tag[*].hex
  scenario_1_users = var.scenario_4_users
  ssh_key_name     = var.ssh_key_name
  providers = {
    aws = aws.ca-central-1
  }
}

module "scenario_4_eu" {
  source           = "./modules/scenario4"
  project_tag      = random_id.s4_project_tag[*].hex
  scenario_1_users = var.scenario_4_users
  ssh_key_name     = var.ssh_key_name
  providers = {
    aws = aws.eu-central-1
  }
}

resource "aws_directory_service_directory" "s4-ad" {
  provider = aws.ca-central-1
  count    = length(var.scenario_4_users)
  name     = "corp.${random_id.s4_project_tag[count.index].hex}.com"
  password = "SuperSecretPassw0rd"
  edition  = "Standard"
  type     = "MicrosoftAD"

  vpc_settings {
    vpc_id     = module.scenario_4_ca_central.vpc_id[count.index]
    subnet_ids = [module.scenario_4_ca_central.subnet1[count.index], module.scenario_4_ca_central.subnet2[count.index]]
  }

  tags = merge(
    var.tags,
    {
      "ProjectTag" = random_id.s4_project_tag[count.index].hex
    },
  )
}

# Scenario 5
resource "random_id" "s5_project_tag" {
  count       = length(var.scenario_5_users)
  byte_length = 4
}

module "scenario_5_us_east" {
  source           = "./modules/scenario5"
  project_tag      = random_id.s5_project_tag[*].hex
  scenario_1_users = var.scenario_5_users
  ssh_key_name     = var.ssh_key_name
  providers = {
    aws = aws.us-east-1
  }
}

module "scenario_5_eu" {
  source           = "./modules/scenario5"
  project_tag      = random_id.s5_project_tag[*].hex
  scenario_1_users = var.scenario_5_users
  ssh_key_name     = var.ssh_key_name
  providers = {
    aws = aws.eu-central-1
  }
}

resource "aws_directory_service_directory" "s5-ad" {
  provider = aws.us-east-1
  count    = length(var.scenario_5_users)
  name     = "corp.${random_id.s5_project_tag[count.index].hex}.com"
  password = "SuperSecretPassw0rd"
  edition  = "Standard"
  type     = "MicrosoftAD"

  vpc_settings {
    vpc_id     = module.scenario_5_us_east.vpc_id[count.index]
    subnet_ids = [module.scenario_5_us_east.subnet1[count.index], module.scenario_5_us_east.subnet2[count.index]]
  }

  tags = merge(
    var.tags,
    {
      "ProjectTag" = random_id.s5_project_tag[count.index].hex
    },
  )
}
