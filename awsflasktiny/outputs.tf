output "project_tag" {
  value = var.project_tag
}

output "us_instance_public_ip" {
  value = "http://${aws_instance.us-web.public_ip}:8000"
}

output "us_instance_vpc_id" {
  value = aws_vpc.us-vpc.id
}

output "us_instance_availability_zone" {
  value = aws_instance.us-web.availability_zone
}

output "eu_instance_public_ip" {
  value = "http://${aws_instance.eu-web.public_ip}:8000"
}

output "eu_instance_vpc_id" {
  value = aws_vpc.eu-vpc.id
}

output "eu_instance_availability_zone" {
  value = aws_instance.eu-web.availability_zone
}
