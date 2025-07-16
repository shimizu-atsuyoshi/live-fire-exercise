module "bastion" {
  source                      = "./modules/instance/ec2"
  name                        = "live-fire-exercise-bastion"
  vpc_id                      = module.vpc.id
  subnet_id                   = module.public_subnets.ids[0]
  associate_public_ip_address = true
  public_key                  = "~/.ssh/live-fire-exercise-bastion.pub"
  ingress = {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = []
  }
}
