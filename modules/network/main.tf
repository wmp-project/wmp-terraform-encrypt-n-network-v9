resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.env
  }
}

resource "aws_subnet" "public" {
  count             = length(var.subnets["public_subnets"])
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnets["public_subnets"][count.index]
  availability_zone = var.az[count.index]

  tags = {
    Name = "public-subnet-${count.index+1}"
  }
}

resource "aws_subnet" "app" {
  count             = length(var.subnets["app_subnets"])
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnets["app_subnets"][count.index]
  availability_zone = var.az[count.index]

  tags = {
    Name = "app-subnet-${count.index+1}"
  }
}

resource "aws_subnet" "db" {
  count             = length(var.subnets["db_subnets"])
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnets["db_subnets"][count.index]
  availability_zone = var.az[count.index]

  tags = {
    Name = "db-subnet-${count.index+1}"
  }
}


resource "aws_route_table" "public" {
  count = length(var.subnets["public_subnets"])
  vpc_id   = aws_vpc.main.id

  tags = {
    Name = "public-${count.index+1}"
  }
}

resource "aws_route_table" "db" {
  count = length(var.subnets["db_subnets"])
  vpc_id   = aws_vpc.main.id

  tags = {
    Name = "db-${count.index+1}"
  }
}

resource "aws_route_table" "app" {
  count = length(var.subnets["app_subnets"])
  vpc_id   = aws_vpc.main.id

  tags = {
    Name = "app-${count.index+1}"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.subnets["public_subnets"])
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

resource "aws_route_table_association" "app" {
  count = length(var.subnets["app_subnets"])
  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.app[count.index].id
}
resource "aws_route_table_association" "db" {
  count = length(var.subnets["db_subnets"])
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db[count.index].id
}



resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.env
  }
}

resource "aws_route" "public" {
  count = length(var.subnets["public_subnets"])
  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}



