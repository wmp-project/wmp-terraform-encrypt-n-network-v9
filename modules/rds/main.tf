terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
  }
}
resource "aws_db_parameter_group" "main" {
  name   = "wmp-${var.env}"
  family = "postgres16"
}

resource "aws_db_subnet_group" "main" {
  name       = "wmp-${var.env}"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "wmp-${var.env}"
  }
}

resource "aws_security_group" "main" {

  name   = "wmp-rds-${var.env}"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wmp-rds-${var.env}"
  }

}

resource "aws_db_instance" "main" {
  identifier             = "wmp-${var.env}"
  allocated_storage      = var.allocated_storage
  db_name                = "default_dummy"
  engine                 = "postgres"
  engine_version         = "16.13"
  instance_class         = "db.t3.micro"
  username               = data.aws_ssm_parameter.rds_username.value
  password               = data.aws_ssm_parameter.rds_password.value
  parameter_group_name   = aws_db_parameter_group.main.name
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.main.id]
}

resource "null_resource" "schema_load" {
  provisioner "local-exec" {
    command = <<EOF
curl -o global-bundle.pem https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem
PGPASSWORD='${data.aws_ssm_parameter.rds_password.value}' /usr/pgsql-16/bin/psql  'host=${aws_db_instance.main.address} port=5432 dbname=default_dummy user=${data.aws_ssm_parameter.rds_username.value} sslmode=verify-full sslrootcert=./global-bundle.pem' <${path.module}/setup.sql
EOF
  }
}


