
locals { 
  timestamp = regex_replace(timestamp(), "[- TZ:]", "") 
}

source "amazon-ebs" "cluster_loadtest" {
  ami_name      = "sre-turnomatic-ami-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "eu-west-3"
  source_ami_filter {
    filters = {
      name = "pinchito-service-2020-11-20"
    }
    owners=["866541347996"]
  }
  ssh_username = "ubuntu"
  # This are the tags that you can use to find
  # this AMI.
  tags = {
    Version = "{{ uuid }}"
    Name = "turnomatic-ami"
  }
}

build {
  sources = ["source.amazon-ebs.cluster_loadtest"]
  provisioner "file"{
      source = "../../server-cluster.js"
    destination = "~/server-cluster.js"
  }
  provisioner "file" {
    source ="../../package.json"
    destination = "~/package.json"

  }
  provisioner "file" {
      source = "./turnomatic.service"
      destination = "~/turnomatic.service"
  }
  provisioner "file" {
      source = "authorized_keys.ssh"
      destination = "~/authorized_keys"
  }
  provisioner "shell" {
      inline = [
          "sudo mkdir -p /opt/server-cluster",
          "sudo chmod 664 /opt/server-cluster",
          "sudo cp ~/turnomatic.service /lib/systemd/system/turnomatic.service",
          "sudo cp ~/server-cluster.js /opt/server-cluster/server-cluster.js",
          "sudo cp ~/package.json /opt/server-cluster/package.json",
          "sudo chown -R ubuntu:ubuntu /opt/server-cluster",
          "sudo chmod -R 775 /opt/server-cluster/",
          "cd /opt/server-cluster/ && npm install",
          "sudo systemctl daemon-reload",
          "sudo systemctl enable turnomatic.service",
          "sudo systemctl start turnomatic.service",
          "sleep 1",
          "curl http://localhost:7017/ready",
          "cat ~/authorized_keys >> ~/.ssh/authorized_keys",
          "sudo npm install --global autocannon",
      ]
  }
  post-processor "manifest" {
      output = "manifest.json"
      strip_path = true
  }
}