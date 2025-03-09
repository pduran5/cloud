# Outputs para AWS
output "aws_public_ip" {
  value       = aws_instance.awsweb1.public_ip
  description = "IP pública de la instancia AWS"
}

output "aws_private_ip" {
  value       = aws_instance.awsweb1.private_ip
  description = "IP privada de la instancia AWS"
}