module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name = "turnomatic-nlb"

  load_balancer_type = "network"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  target_groups = [
    {
      name_prefix      = "app-tg"
      backend_protocol = "TCP"
      backend_port     = 7017
      target_type      = "instance"
      health_check = {
        path = "/healthz"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    }
  ]

  tags = {
    Application = "Turnomatic"
  }


}