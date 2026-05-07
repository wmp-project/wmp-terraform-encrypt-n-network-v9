module "network" {
  for_each = var.network
  source   = "modules/network"

  env               = var.env
  default_vpc_id    = var.default_vpc_id
  default_vpc_rt_id = var.default_vpc_rt_id
  default_vpc_cidr  = var.default_vpc_cidr

  vpc_cidr = each.value["vpc_cidr"]
  subnets  = each.value["subnets"]
  az       = each.value["az"]


}
#
# module "databases" {
#   for_each = var.databases
#   source   = "./modules/rds"
#
#   env        = var.env
#   kms_key_id = var.kms_key_id
#
#   allocated_storage = each.value["allocated_storage"]
#
#   subnet_ids = module.network["dev"].db_subnet_ids
#   vpc_id     = module.network["dev"].vpc_id["id"]
# }
#
#
# module "eks" {
#   source = "./modules/eks"
#
#   env                     = var.env
#   kms_key_id              = var.kms_key_id
#   cluster_sg_ingress_cidr = var.cluster_sg_ingress_cidr
#
#   subnets = module.network["dev"].app_subnet_ids
#   vpc_id  = module.network["dev"].vpc_id["id"]
# }
#
