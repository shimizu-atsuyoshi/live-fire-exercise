module "bastion" {
  source                      = "./modules/instance/ec2"
  name                        = "live-fire-exercise-bastion"
  vpc_id                      = module.vpc.id
  subnet_id                   = module.private_subnets.ids[0]
  associate_public_ip_address = true
  ingress = {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = []
  }
}
