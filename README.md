# IaC on DigitalOcean with Terraform and Ansible

## Overview

The goal of this project is to introduce you to the basics of Infrastructure as Code (IaC) using Terraform. You will create a DigitalOcean Droplet and configure it using Terraform and Ansible.

## Requirements

- A DigitalOcean account  
- Terraform installed on your local machine  
- Ansible installed on your local machine  
- SSH key pair  

## Steps

### 1. Install Terraform

**Download Terraform:**  
```bash
curl -O https://releases.hashicorp.com/terraform/1.10.5/terraform_1.10.5_darwin_amd64.zip
```

**Unzip the downloaded file:**  
```bash
unzip terraform_1.10.5_darwin_amd64.zip
```

**Move the Terraform binary to a directory in your PATH:**  
```bash
sudo mv terraform /usr/local/bin/
```

**Verify the installation:**  
```bash
terraform -version
```

### 2. Create a Terraform Configuration

**Create a project directory:**  
```bash
mkdir terraform-digitalocean
cd terraform-digitalocean
```

**Create a `main.tf` file:**  
```bash
nano main.tf
```

**Add the following content to `main.tf`:**  
```hcl
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = "your_digitalocean_api_token"
}

resource "digitalocean_droplet" "web" {
  image  = "ubuntu-20-04-x64"
  name   = "my-droplet"
  region = "nyc3"
  size   = "s-1vcpu-1gb"
  ssh_keys = [
    "your_ssh_key_fingerprint"
  ]
}

output "droplet_ip" {
  value = digitalocean_droplet.web.ipv4_address
}
```

### 3. Initialize and Apply Terraform

**Initialize Terraform:**  
```bash
terraform init
```

**Apply the Terraform configuration:**  
```bash
terraform apply
```

**Confirm the actions by typing `yes`.**

### 4. Verify the Droplet Creation

**SSH into the Droplet:**  
```bash
ssh -i ~/.ssh/id_rsa root@<droplet_ip>
```

### 5. Configure the Droplet with Ansible

**Create an Ansible project directory:**  
```bash
mkdir ansible-project
cd ansible-project
```

**Create `setup.yml` file:**  
```bash
nano setup.yml
```

**Add the following content to `setup.yml`:**  
```yaml
- hosts: webserver
  become: true
  roles:
    - base
    - nginx
    - app
    - ssh
```

### 6. Define Role Tasks

**Create the directory structure for roles:**  
```bash
mkdir -p roles/base/tasks
mkdir -p roles/nginx/tasks
mkdir -p roles/app/tasks
mkdir -p roles/ssh/tasks
```

#### Role: Base

**File: `roles/base/tasks/main.yml`**  
```yaml
- name: Update and upgrade the server
  apt:
    update_cache: yes
    upgrade: dist

- name: Install basic utilities
  apt:
    name:
      - curl
      - vim
      - git
    state: present

- name: Install fail2ban
  apt:
    name: fail2ban
    state: present
```

#### Role: Nginx

**File: `roles/nginx/tasks/main.yml`**  
```yaml
- name: Install nginx
  apt:
    name: nginx
    state: present

- name: Start and enable nginx service
  systemd:
    name: nginx
    state: started
    enabled: yes
```

#### Role: App

**File: `roles/app/tasks/main.yml`**  
```yaml
- name: Upload the static HTML website tarball
  copy:
    src: files/website.tar.gz
    dest: /var/www/html/website.tar.gz

- name: Extract the website tarball
  unarchive:
    src: /var/www/html/website.tar.gz
    dest: /var/www/html/
    remote_src: yes

- name: Ensure the website files have the correct permissions
  file:
    path: /var/www/html/
    state: directory
    owner: www-data
    group: www-data
    mode: '0755'
    recurse: yes
```

#### Role: SSH

**File: `roles/ssh/tasks/main.yml`**  
```yaml
- name: Add the public key to authorized_keys
  authorized_key:
    user: root
    state: present
    key: "your_public_key_here"
```

### 7. Create a Static HTML Website

**Create a new directory for your website:**  
```bash
mkdir -p my_website
cd my_website
```

**Create an `index.html` file:**  
```bash
nano index.html
```

**Add some basic HTML content:**  
```html
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to My Website</title>
</head>
<body>
    <h1>Hello, world!</h1>
    <p>Welcome to my website!</p>
</body>
</html>
```

### 8. Create a Tarball of the Website

**Navigate back to the parent directory:**  
```bash
cd ..
```

**Create a tarball of the website directory:**  
```bash
tar -czvf website.tar.gz my_website/
```

**Move the tarball to the files directory within your Ansible project directory:**  
```bash
mv website.tar.gz ansible-project/files/
```

### 9. Run Your Ansible Playbook

**Run the Ansible playbook:**  
```bash
ansible-playbook -i inventory.ini setup.yml
```

https://roadmap.sh/projects/iac-digitalocean
