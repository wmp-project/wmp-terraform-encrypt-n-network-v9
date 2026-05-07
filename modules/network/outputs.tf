output "vpc_id" {
  value = aws_vpc.main
}

# output "db_subnet_ids" {
#   value = [ for i,j in local.subnets_merged: j.id if j.group == "db" ]
# }
#
# output "app_subnet_ids" {
#   value = [ for i,j in local.subnets_merged: j.id if j.group == "app" ]
# }
#
