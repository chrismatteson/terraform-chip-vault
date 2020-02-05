data "null_data_source" "s1_users" {
  count = length(var.scenario_1_users)
  inputs = {
    project_tag    = random_id.s1_project_tag[count.index].hex
    iam_user       = aws_iam_user.s1_user[count.index].name
    password       = aws_iam_user_login_profile.s1_user[count.index].encrypted_password
    us-west-1      = module.scenario_1_west.public_ip[count.index].public_ip
    us-west-2      = module.scenario_1_west_dr.public_ip[count.index].public_ip
    eu-central-1   = module.scenario_1_eu.public_ip[count.index].public_ip
    eu-west-1      = module.scenario_1_eu_dr.public_ip[count.index].public_ip
    ap-southeast-1 = module.scenario_1_ap.public_ip[count.index].public_ip
    AD-admin-pass  = aws_directory_service_directory.s1-ad[count.index].password
  }
# This is a hack that ensures the latest IP gets in the output
  depends_on = [aws_iam_user.s1_user[0]]
}

data "null_data_source" "s2_users" {
  count = length(var.scenario_2_users)
  inputs = {
    project_tag    = random_id.s2_project_tag[count.index].hex
    iam_user       = aws_iam_user.s2_user[count.index].name
    password       = aws_iam_user_login_profile.s2_user[count.index].encrypted_password
    us-east-2      = module.scenario_2_east.public_ip[count.index].public_ip
    us-west-2      = module.scenario_2_west_dr.public_ip[count.index].public_ip
    eu-central-1   = module.scenario_2_eu.public_ip[count.index].public_ip
    eu-west-1      = module.scenario_2_eu_dr.public_ip[count.index].public_ip
    ap-southeast-1 = module.scenario_2_ap.public_ip[count.index].public_ip
    AD-admin-pass  = aws_directory_service_directory.s1-ad[count.index].password
  }
# This is a hack that ensures the latest IP gets in the output
  depends_on = [aws_iam_user.s2_user[0]]
}

data "null_data_source" "s3_users" {
  count = length(var.scenario_3_users)
  inputs = {
    project_tag    = random_id.s3_project_tag[count.index].hex
    iam_user       = aws_iam_user.s3_user[count.index].name
    password       = aws_iam_user_login_profile.s3_user[count.index].encrypted_password
    us-east-1      = module.scenario_3_east.public_ip[count.index].public_ip
    us-west-2      = module.scenario_3_west_dr.public_ip[count.index].public_ip
    eu-central-1   = module.scenario_3_eu.public_ip[count.index].public_ip
    eu-west-1      = module.scenario_3_eu_dr.public_ip[count.index].public_ip
    ap-southeast-1 = module.scenario_3_ap.public_ip[count.index].public_ip
    AD-admin-pass  = aws_directory_service_directory.s1-ad[count.index].password
  }
# This is a hack that ensures the latest IP gets in the output
  depends_on = [aws_iam_user.s3_user[0]]
}

data "null_data_source" "s4_users" {
  count = length(var.scenario_4_users)
  inputs = {
    project_tag    = random_id.s4_project_tag[count.index].hex
    iam_user       = aws_iam_user.s4_user[count.index].name
    password       = aws_iam_user_login_profile.s4_user[count.index].encrypted_password
    ca-central-1   = module.scenario_4_ca_central.public_ip[count.index].public_ip
    us-west-2      = module.scenario_4_west_dr.public_ip[count.index].public_ip
    eu-central-1   = module.scenario_4_eu.public_ip[count.index].public_ip
    eu-west-1      = module.scenario_4_eu_dr.public_ip[count.index].public_ip
    ap-southeast-1 = module.scenario_4_ap.public_ip[count.index].public_ip
    AD-admin-pass  = aws_directory_service_directory.s1-ad[count.index].password
  }
# This is a hack that ensures the latest IP gets in the output
  depends_on = [aws_iam_user.s4_user[0]]
}

data "null_data_source" "s5_users" {
  count = length(var.scenario_5_users)
  inputs = {
    project_tag    = random_id.s5_project_tag[count.index].hex
    iam_user       = aws_iam_user.s5_user[count.index].name
    password       = aws_iam_user_login_profile.s5_user[count.index].encrypted_password
    sa-east-1      = module.scenario_5_sa_east.public_ip[count.index].public_ip
    us-west-2      = module.scenario_5_west_dr.public_ip[count.index].public_ip
    eu-central-1   = module.scenario_5_eu.public_ip[count.index].public_ip
    eu-west-1      = module.scenario_5_eu_dr.public_ip[count.index].public_ip
    ap-southeast-1 = module.scenario_5_ap.public_ip[count.index].public_ip
    AD-admin-pass  = aws_directory_service_directory.s1-ad[count.index].password
  }
# This is a hack that ensures the latest IP gets in the output
  depends_on = [aws_iam_user.s5_user[0]]
}

output "scenario_1_user_info" {
  value = data.null_data_source.s1_users[*].outputs
}

output "scenario_2_user_info" {
  value = data.null_data_source.s2_users[*].outputs
}

output "scenario_3_user_info" {
  value = data.null_data_source.s3_users[*].outputs
}

output "scenario_4_user_info" {
  value = data.null_data_source.s4_users[*].outputs
}

output "scenario_5_user_info" {
  value = data.null_data_source.s5_users[*].outputs
}

