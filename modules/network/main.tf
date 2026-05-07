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