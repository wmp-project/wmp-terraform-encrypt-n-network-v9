output "vpc_id" {
  value = aws_vpc.main
}

output "subnet_ids" {
  value = { for i,j in local.subnets_merged: j.group => [for k,v in j: v.id] }
}

