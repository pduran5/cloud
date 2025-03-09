# AWS
variable "aws_region" {
  default = "us-east-1"
}

variable "private_key_path" {
  description = "Ruta local a la clave privada (.pem)"
  type        = string
}