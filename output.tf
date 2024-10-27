output "ec2_public_ip" {
  value = aws_instance.ec2.public_ip
}

output "ec2_eip" {
  value = aws_eip.static_eip.public_ip
}