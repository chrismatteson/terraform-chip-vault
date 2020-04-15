output "project_tag" {
  value = var.project_tag
}

output "public_ip" {
  value = aws_instance.web.public_ip
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet1" {
  value = aws_subnet.subnet1.id
}

output "subnet2" {
  value = aws_subnet.subnet2.id
}
