required_plugins {
  proxmox = {
    version = "1.0.6"
    source  = "github.com/hashicorp/proxmox"
  }
}

source "proxmox" "ubuntu-server-focal" {
  proxmox_url          = "${env("PROXMOX_API_URL")}"
  username             = "${env("PROXMOX_API_TOKEN_ID")}"
  token                = "${env("PROXMOX_API_TOKEN_SECRET")}"
  # ...
}
