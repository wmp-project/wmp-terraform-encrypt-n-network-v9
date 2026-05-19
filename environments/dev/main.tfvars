dns_domain = "devmonkey.online."
env        = "dev"
vpc_id     = "vpc-00c17ee82b9c30e4a"
subnets    = ["subnet-05fc554f21ead9d55", "subnet-0e99e91ba5863b57b"]
kms_key_id = "arn:aws:kms:us-east-1:424808095083:key/6e318160-0c19-4e3c-b7b3-896710b524db"

databases = {
  postgresql = {
    allocated_storage = 10
  }
}

apps = {

  frontend = {
    instance_type = "t3.small"
    ports = {
      frontend = 80
    }
    lb = {
      port        = 80
      lb_internal = false
    }
    asg = {
      min_size = 2
      max_size = 10
    }
  }

  auth-service = {
    instance_type = "t3.small"
    ports = {
      auth-service = 8081
    }
    lb = {
      port        = 8081
      lb_internal = true
    }
    asg = {
      min_size = 2
      max_size = 10
    }
  }

  portfolio-service = {
    instance_type = "t3.small"
    ports = {
      portfolio-service = 8080
    }
    lb = {
      port        = 8080
      lb_internal = true
    }
    asg = {
      min_size = 2
      max_size = 10
    }
  }

  analytics-service = {
    instance_type = "t3.small"
    ports = {
      analytics-service = 8000
    }
    lb = {
      port        = 8000
      lb_internal = true
    }
    asg = {
      min_size = 2
      max_size = 10
    }
  }

}
## OLD
# network = {
#   dev = {
#     vpc_cidr = "10.1.0.0/24"
#     subnets = {
#       public-subnet1 = {
#         cidr  = "10.1.0.0/27"
#         az    = "us-east-1a"
#         igw   = true
#         ngw   = false
#       }
#       public-subnet2 = {
#         cidr  = "10.1.0.32/27"
#         az    = "us-east-1b"
#         igw   = true
#         ngw   = false
#       }
#       db-subnet1 = {
#         cidr  = "10.1.0.64/27"
#         az    = "us-east-1a"
#         igw   = false
#         ngw   = false
#       }
#       db-subnet2 = {
#         cidr  = "10.1.0.96/27"
#         az    = "us-east-1b"
#         igw   = false
#         ngw   = false
#       }
#       app-subnet1 = {
#         cidr  = "10.1.0.128/26"
#         az    = "us-east-1a"
#         igw   = false
#         ngw   = true
#       }
#       app-subnet2 = {
#         cidr  = "10.1.0.192/26"
#         az    = "us-east-1b"
#         igw   = false
#         ngw   = true
#       }
#     }
#   }
# }


network = {
  dev = {
    vpc_cidr = "10.1.0.0/24"
    subnets = {
      public_subnets = ["10.1.0.0/27", "10.1.0.32/27"]
      db_subnets     = ["10.1.0.64/27", "10.1.0.96/27"]
      app_subnets    = ["10.1.0.128/26", "10.1.0.192/26"]
    }
    az = ["us-east-1a", "us-east-1b"]
  }
}

default_vpc_id    = "vpc-0f1c6be04e9ff300c"
default_vpc_rt_id = "rtb-05b22eac334a7d035"
default_vpc_cidr  = "172.31.0.0/16"

cluster_sg_ingress_cidr = ["172.31.0.0/16", "10.1.0.0/24"]