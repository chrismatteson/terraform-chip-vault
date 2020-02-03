data "null_data_source" "s1_users" {
  count = length(var.scenario_1_users)
  inputs = {
    project_tag = random_id.s1_project_tag[count.index].hex
    iam_user    = aws_iam_user.s1_user[count.index].name
    password    = aws_iam_user_login_profile.s1_user[count.index].encrypted_password
    public_ip   = aws_instance.web[count.index].public_ip
  }
# This is a hack that ensures the latest IP gets in the output
  depends_on = [aws_instance.web[0]]
}

output "scenario_1_user_info" {
  value = data.null_data_source.s1_users[*].outputs
}

