# output "subnets_from_subnet_module" {
#   value = aws_subnet.main
# }
#
# output "route_table_ids_from_subnet_module" {
#   value = aws_route_table.main
# }

output "igw_subnets" {
  value = [ for i,j in var.subnets: aws_subnet.main[i].id if var.subnets[i].igw ]
}

