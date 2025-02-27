# Configuración del proveedor AWS
provider "aws" {
  region = var.aws_region # Define la región de AWS donde se crearán los recursos, obtenida de la variable 'aws_region'.
}

# Grupo de seguridad que permite acceso SSH desde cualquier IP
resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh" # Nombre del grupo de seguridad.
  ingress {
    from_port   = 22            # Puerto de inicio para la regla de entrada (SSH).
    to_port     = 22            # Puerto de fin para la regla de entrada (SSH).
    protocol    = "tcp"         # Protocolo de la regla de entrada (TCP).
    cidr_blocks = ["0.0.0.0/0"] # Permite el tráfico desde cualquier dirección IP (no recomendado para producción).
  }
}

# Recurso que define la instancia EC2
resource "aws_instance" "awsvm1" {
  instance_type = "t2.micro"              # Tipo de instancia EC2 (t2.micro, elegible para la capa gratuita).
  ami           = "ami-05b10e08d247fb927" # AMI (Amazon Machine Image) para la instancia. Asegúrate de que esta AMI sea válida en la región especificada. Amazon Linux 2023 AMI.

  iam_instance_profile = "LabInstanceProfile" # Perfil de instancia IAM asignado a la instancia EC2, usado en AWS Academy Learner Lab.

  tags = {
    Name = "awsvm1" # Etiqueta 'Name' para identificar la instancia EC2 en la consola de AWS.
  }
}