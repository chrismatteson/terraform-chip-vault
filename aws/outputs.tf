data "null_data_source" "s1_users" {
  count = length(var.scenario_1_users)
  inputs = {
    project_tag    = random_id.s1_project_tag[count.index].hex
    iam_user       = aws_iam_user.s1_user[count.index].name
    password       = aws_iam_user_login_profile.s1_user[count.index].encrypted_password
    iam_access_key = aws_iam_access_key.s1_user[count.index].id
    iam_secret_key = aws_iam_access_key.s1_user[count.index].secret
    us-west-1      = module.scenario_1_west.public_ip[count.index].public_ip
    eu-central-1   = module.scenario_1_eu.public_ip[count.index].public_ip
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
    iam_access_key = aws_iam_access_key.s2_user[count.index].id
    iam_secret_key = aws_iam_access_key.s2_user[count.index].secret
    us-east-2      = module.scenario_2_east.public_ip[count.index].public_ip
    eu-central-1   = module.scenario_2_eu.public_ip[count.index].public_ip
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
    iam_access_key = aws_iam_access_key.s3_user[count.index].id
    iam_secret_key = aws_iam_access_key.s3_user[count.index].secret
    us-east-1      = module.scenario_3_east.public_ip[count.index].public_ip
    eu-central-1   = module.scenario_3_eu.public_ip[count.index].public_ip
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
    iam_access_key = aws_iam_access_key.s4_user[count.index].id
    iam_secret_key = aws_iam_access_key.s4_user[count.index].secret
    ca-central-1   = module.scenario_4_ca_central.public_ip[count.index].public_ip
    eu-central-1   = module.scenario_4_eu.public_ip[count.index].public_ip
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
    iam_access_key = aws_iam_access_key.s5_user[count.index].id
    iam_secret_key = aws_iam_access_key.s5_user[count.index].secret
    us-east-1      = module.scenario_5_us_east.public_ip[count.index].public_ip
    eu-central-1   = module.scenario_5_eu.public_ip[count.index].public_ip
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

