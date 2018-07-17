variable "resourcename" {
  default = "resourcegroup"
}

variable "location" {
  default = "japaneast"
}

variable "vmname" {
  default = "vmname"
}

variable "vmsize" {
  default = "Standard_D2s_v3"
}

variable "adminusername" {
  default = "admin"
}

variable "adminpassword" {
  default = "P@ssw0rdOfAdmin"
}

# Create a resource  group if it doesn’t exist

resource "azurerm_resource_group" "resourcegroup" {
  name     = "${var.resourcename}"
  location = "${var.location}"
}

# Create virtual network
resource "azurerm_virtual_network" "virtualnetwork" {
  name                = "Vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "Subnet1"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.virtualnetwork.name}"
  address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "publicip" {
  name                         = "PublicIP"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  public_ip_address_allocation = "dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "networksecuritygroup" {
  name                = "NetworkSecurityGroup"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "networkinterface" {
  name                      = "NIC"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  network_security_group_id = "${azurerm_network_security_group.networksecuritygroup.id}"

  ip_configuration {
    name                          = "NicConfiguration"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.publicip.id}"
  }
}

# Generate random text for a unique storage account name
resource "random_id" "randomid" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${azurerm_resource_group.resourcegroup.name}"
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "storageaccount" {
  name                     = "diag${random_id.randomid.hex}"
  resource_group_name      = "${azurerm_resource_group.resourcegroup.name}"
  location                 = "${var.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create virtual machine
resource "azurerm_virtual_machine" "virtualmachine" {
  name                  = "${var.vmname}"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  network_interface_ids = ["${azurerm_network_interface.networkinterface.id}"]
  vm_size               = "${var.vmsize}"

  storage_os_disk {
    name              = "OsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.vmname}"
    admin_username = "${var.adminusername}"
    admin_password = "${var.adminpassword}"
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true

    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "AutoLogon"
      content      = "<AutoLogon><Password><Value>${var.adminpassword}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.adminusername}</Username></AutoLogon>"
    }

    # Unattend config is to configure remoting for Ansible.
    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "FirstLogonCommands"
      content      = "${file("${path.module}/files/FirstLogonCommands.xml")}"
    }
  }
}
