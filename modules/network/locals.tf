locals {
  subnets_merged = { for i,j in var.subnets: i => merge(var.subnets[i], aws_subnet.main[i])}
}

