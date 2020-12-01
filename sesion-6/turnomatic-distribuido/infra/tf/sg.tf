module "turnomatic_server_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "turnomatic-server-sg"
  description = "Security group for turnomatic-server with application ports open with everything"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 7017
      to_port     = 7017
      protocol    = "tcp"
      description = "Turnomatic-service ports"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

module "turnomatic_server_sg_ssh" {
  source = "terraform-aws-modules/security-group/aws//modules/ssh"

  name        = "turnomatic-server-sg-ssh"
  description = "Security group for web-server with HTTP ports open with everything"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = [
    "0.0.0.0/0"
  ]
}
