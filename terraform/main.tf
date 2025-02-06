terraform {
  required_providers {
    digitalocean = {
        source = "digitalocean/digitalocean"
        version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
    token = var.digitalocean_token
}

resource "digitalocean_droplet" "web" {
    image = "ubuntu-20-04-x64"
    name = "my-droplet"
    region = "nyc3"
    size = "s-1vcpu-1gb"
    ssh_keys = [
        "8d:3b:4a:31:f1:51:a6:fb:57:d5:e3:c9:32:ec:ed:93"
    ]
  
}

output "droplet_ip" {
    value = digitalocean_droplet.web.ipv4_address
}
