terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.6.0, < 3.0.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 2.19.2, < 3.0.0"
    }
  }
}

resource "digitalocean_ssh_key" "home" {
  for_each   = var.ssh_keys
  name       = basename(each.value)
  public_key = file(each.value)
}

resource "digitalocean_droplet" "bastion" {
  name               = "bastion"
  image              = "ubuntu-20-04-x64"
  region             = "nyc1"
  size               = "s-1vcpu-1gb"
  ssh_keys           = [for k in digitalocean_ssh_key.home : k.fingerprint]
  monitoring         = false
  backups            = false
  private_networking = false
  ipv6               = false
  resize_disk        = false
}

resource "null_resource" "configure-bastion" {
  triggers = {
    id   = digitalocean_droplet.bastion.id
    time = timestamp()
  }

  connection {
    host = digitalocean_droplet.bastion.ipv4_address
  }

  provisioner "remote-exec" {
    inline = []
  }
}

data "cloudflare_zones" "kaipov-com" {
  filter {
    name = "kaipov.com"
  }
}

resource "cloudflare_record" "bastion-kaipov-com" {
  zone_id = data.cloudflare_zones.kaipov-com.zones[0].id
  type    = "A"
  name    = "bastion"
  value   = digitalocean_droplet.bastion.ipv4_address
  # have to disable CloudFlare protection on it to resolve proper IP
  proxied = false
}
