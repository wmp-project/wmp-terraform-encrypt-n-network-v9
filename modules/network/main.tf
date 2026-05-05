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

resource "aws_route_table" "main" {
  for_each = var.subnets
  vpc_id   = aws_vpc.main.id

  tags = {
    Name = each.key
  }
}

resource "aws_route_table_association" "main" {
  for_each       = var.subnets
  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.main[each.key].id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.env
  }
}

resource "aws_route" "igw-route" {
  for_each               = local.subnets_with_igw
  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_eip" "ngw" {
  for_each = local.subnets_with_ngw
  domain   = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  for_each      = local.subnets_with_ngw
  allocation_id = aws_eip.ngw[each.key].id
  subnet_id     = each.key
}

resource "aws_route" "ngw-route" {
  for_each               = local.subnets_with_ngw
  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw[each.key].id
}


resource "aws_vpc_peering_connection" "main" {
  peer_vpc_id = var.default_vpc_id
  vpc_id      = aws_vpc.main.id
  auto_accept = true

  tags = {
    Name = "default-to-${var.env}"
  }
}

resource "aws_route" "default-rt-add-peering" {
  route_table_id            = var.default_vpc_rt_id
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

resource "aws_route" "here-vpc-rt-add-peering" {
  for_each                  = aws_route_table.main
  route_table_id            = aws_route_table.main[each.key].id
  destination_cidr_block    = var.default_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}
