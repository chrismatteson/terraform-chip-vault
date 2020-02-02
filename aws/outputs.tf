output "public_ip" {
  value = aws_instance.web.public_ip
}

output "password" {
  value = aws_iam_user_login_profile.user.*.encrypted_password
}
