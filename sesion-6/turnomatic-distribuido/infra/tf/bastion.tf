resource "aws_instance" "bastion" {
  ami           = data.aws_ami.this.image_id
  instance_type = var.instance_size
  vpc_security_group_ids = [
    module.turnomatic_server_sg.this_security_group_id,
    module.turnomatic_server_sg_ssh.this_security_group_id
  ]
  subnet_id = module.vpc.public_subnets[0]
  tags = {
    Name = "Turnomatic Bastion"
  }
}

output "bastion_ip" {
  value = aws_instance.bastion
}