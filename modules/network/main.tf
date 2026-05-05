resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.env
  }
}

resource "aws_subnet" "main" {
  for_each          = var.subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value["cidr"]
  availability_zone = each.value["az"]

  tags = {
    Name = each.key
  }
}
#
# resource "aws_vpc_peering_connection" "main" {
#   peer_vpc_id = var.default_vpc_id
#   vpc_id      = aws_vpc.main.id
#   auto_accept = true
#
#   tags = {
#     Name = "default-to-${var.env}"
#   }
# }
#
# resource "aws_route" "default-rt-add-peering" {
#   route_table_id            = var.default_vpc_rt_id
#   destination_cidr_block    = var.vpc_cidr
#   vpc_peering_connection_id = aws_vpc_peering_connection.main.id
# }
#
# resource "aws_route" "here-vpc-rt-add-peering" {
#   route_table_id            = aws_vpc.main.default_route_table_id
#   destination_cidr_block    = var.default_vpc_cidr
#   vpc_peering_connection_id = aws_vpc_peering_connection.main.id
# }
