# Descripción
Lab inicial de Terraform para crear 2 MVs sencillas con acceso SSH: 1 en Azure y 1 en AWS 

# Preparación
- Instalar Terraform
- Credenciales de acceso para los diferentes cloud:
  - AWS: Crear archivo `%userprofile%/.aws/credentials` con la contenido obtenido desde el AWS Academy Learner Lab > AWS Details > AWS CLI > Show
  - Azure: Logarse en Terminal con `az login` y crear clave con `ssh-keygen -t rsa -b 2048`

# Ejecución
- `terraform fmt` : Reformat your configuration in the standard style
- `terraform validate` : Check whether the configuration is valid
- `terraform init` : Prepare your working directory for other commands
- `terraform plan` : Show changes required by the current configuration
- `terraform apply` : Create or update infrastructure
- `terraform destroy` : Destroy previously-created infrastructure