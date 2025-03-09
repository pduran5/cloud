# Configuración del proveedor AWS
provider "aws" {
  region = var.aws_region # Define la región de AWS donde se crearán los recursos, obtenida de la variable 'aws_region'.
}

# Grupo de seguridad que permite SSH y HTTP
resource "aws_security_group" "allow_web" {
  name = "allow_web" # Nombre del grupo de seguridad.

  ingress {
    from_port   = 22            # Puerto de inicio para la regla de entrada (SSH).
    to_port     = 22            # Puerto de fin para la regla de entrada (SSH).
    protocol    = "tcp"         # Protocolo de la regla de entrada (TCP).
    cidr_blocks = ["0.0.0.0/0"] # Permite el tráfico desde cualquier dirección IP (no recomendado para producción).
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Recurso que define la instancia EC2
resource "aws_instance" "awsweb1" {
  instance_type          = "t2.micro"
  ami                    = "ami-05b10e08d247fb927"
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  iam_instance_profile   = "LabInstanceProfile"

  tags = {
    Name = "awsweb1"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ \\\"$(aws ec2 describe-instances --instance-ids ${self.id} --query 'Reservations[0].Instances[0].State.Name' --output text)\\\" != \\\"running\\\" ]; do sleep 10; done",
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("/home/pit/labsuser.pem")
      host        = self.public_ip
    }
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "[web]" > inventory.ini
      echo "${self.public_ip} ansible_user=ec2-user" >> inventory.ini
      ansible-playbook -i inventory.ini --private-key /home/pit/labsuser.pem playbook.yml --ssh-common-args '-o StrictHostKeyChecking=accept-new' > ansible.log 2>&1
      if [ $? -ne 0 ]; then
        echo "Error running Ansible playbook. Check ansible.log"
        exit 1
      fi
    EOT
  }
}
