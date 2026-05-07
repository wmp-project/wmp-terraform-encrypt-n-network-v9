# locals {
#   subnets_merged      = { for i, j in var.subnets : i => merge(var.subnets[i], aws_subnet.main[i]) }
#   route_tables_merged = { for i, j in var.subnets : i => merge(var.subnets[i], aws_route_table.main[i]) }
#   subnets_with_igw    = { for i, j in local.subnets_merged : local.subnets_merged[i].id => local.route_tables_merged[i].id if local.subnets_merged[i].igw }
#   subnets_with_ngw    = { for i, j in local.subnets_merged : local.subnets_merged[i].id => local.route_tables_merged[i].id if local.subnets_merged[i].ngw }
# }
#
