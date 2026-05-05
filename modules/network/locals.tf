locals {
  subnets_merged = { for i,j in var.subnets: i => merge(var.subnets[i], aws_subnet.main[i], aws_route_table.main[i]) }
  # subnets_with_igw = { for i,j in local.subnets_merged: i.id => j.id if j.igw }
  # subnets_with_ngw = { for i,j in local.subnets_merged: i.id => j.id if j.ngw }
}

