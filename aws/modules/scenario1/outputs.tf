data "null_data_source" "public_ip" {
  count = length(var.scenario_1_users)
  inputs = {
    project_tag = var.project_tag[count.index]
    public_ip   = aws_instance.web[count.index].public_ip
  }
# This is a hack that ensures the latest IP gets in the output
  depends_on = [aws_instance.web[0]]
}

output "public_ip" {
  value = data.null_data_source.public_ip[*].outputs
}

