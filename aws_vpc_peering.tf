resource aws_vpc_peering_connection foo {
  peer_vpc_id   = module.vpc.vpc_id
  vpc_id        = module.secondary_vpc.vpc_id
}