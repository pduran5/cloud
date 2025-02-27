provider "azurerm" {
  features {}
}

# Define el grupo de recursos donde se desplegarán todos los recursos.
resource "azurerm_resource_group" "rg" {
  name     = "azurevm1_rg"
  location = var.azurerm_region # La región se define en variables (variables.tf).
}

# Define la red virtual (VNet) para la máquina virtual.
resource "azurerm_virtual_network" "vnet" {
  name                = "azurevm1_vnet"
  address_space       = ["10.0.0.0/16"] # Rango de direcciones IP para la VNet.
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Define la subred dentro de la VNet.
resource "azurerm_subnet" "subnet" {
  name                 = "azurevm1_subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"] # Rango de direcciones IP para la subred.
}

# Define la IP pública.
resource "azurerm_public_ip" "publicip" {
  name                = "azurevm1-publicip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic" # Cambia a "Static" si necesitas una IP fija.
}

# Define la interfaz de red (NIC) para la máquina virtual.
resource "azurerm_network_interface" "nic" {
  name                = "azurevm1_nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "azurevm1_ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"                     # Asigna una IP privada dinámica.
    public_ip_address_id          = azurerm_public_ip.publicip.id # Asocia la IP pública.
  }
}

# Define el grupo de seguridad de red (NSG) para controlar el tráfico de red.
resource "azurerm_network_security_group" "nsg" {
  name                = "azurevm1_nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Define una regla de NSG para permitir el tráfico SSH entrante (puerto 22).
resource "azurerm_network_security_rule" "ssh_rule" {
  name                        = "AllowSSH"
  priority                    = 100       # Prioridad de la regla. Números más bajos tienen mayor prioridad.
  direction                   = "Inbound" # Tráfico entrante.
  access                      = "Allow"   # Permitir el tráfico.
  protocol                    = "Tcp"     # Protocolo TCP.
  source_port_range           = "*"       # Cualquier puerto de origen.
  destination_port_range      = "22"      # Puerto de destino 22 (SSH).
  source_address_prefix       = "*"       # Cualquier dirección IP de origen (Cambiar a tu IP para mayor seguridad).
  destination_address_prefix  = "*"       # Cualquier dirección IP de destino.
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Asocia el NSG a la subred para aplicar las reglas de seguridad.
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Define la máquina virtual Linux.
resource "azurerm_linux_virtual_machine" "azurevm1" {
  name                = "azurevm1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s" # Tamaño de la máquina virtual (Gratuita 1GB RAM 1vCPU).
  admin_username      = "azureuser"    # Nombre de usuario administrador.
  network_interface_ids = [
    azurerm_network_interface.nic.id, # Asocia la NIC a la máquina virtual.
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.ssh_public_key) # Clave pública SSH para acceso.
  }

  os_disk {
    name                 = "azurevm1_disk1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" # Tipo de almacenamiento del disco.
    disk_size_gb         = 30             # Tamaño del disco del sistema operativo.
  }

  source_image_reference {         # az vm image list --publisher Canonical --offer ubuntu-24_04-lts --all --output table
    publisher = "Canonical"        # Editor de la imagen.
    offer     = "ubuntu-24_04-lts" # Oferta de la imagen.
    sku       = "server"           # SKU de la imagen.
    version   = "latest"           # Versión de la imagen (última disponible).
  }
}