# main.tf

# Call the provider.tf file
module "provider" {
  source = "./provider.tf"
}

# Create 10 containers
resource "proxmox_lxc_container" "container" {
  count = 10
  # Specify the container configuration here
  # ...

  # Network interface
  network {
    name = "eth0"
    bridge = "vmbr0"
    ip = "dhcp"
    firewall = true
  }

  # Security group
  security_groups = ["sg-123456"]
}

# Create 3 VMs
resource "proxmox_vm_qemu" "vm" {
  count = 3
  # Specify the VM configuration here
  # ...

  # Network interface
  network {
    id = "net0"
    model = "virtio"
    bridge = "vmbr0"
    firewall = true
  }

  # Security group
  security_groups = ["sg-123456"]
}