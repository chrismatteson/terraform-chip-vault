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
  }
}

output "scenario_1_user_info" {
  value = data.null_data_source.s1_users[*].outputs
}

