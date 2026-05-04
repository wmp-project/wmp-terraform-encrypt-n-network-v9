dns_domain = "raghudevopsb88.online."
env        = "dev"
vpc_id     = "vpc-00c17ee82b9c30e4a"
subnets    = ["subnet-05fc554f21ead9d55", "subnet-0e99e91ba5863b57b"]
kms_key_id = "arn:aws:kms:us-east-1:739561048503:key/6a83bdae-47d1-4774-9fae-dafe28349ade"

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

network = {
  dev = {
    vpc_cidr = "10.1.0.0/24"
    subnets = {
      s1 = {
        cidr = "10.1.0.0/25"
        az   = "us-east-1a"
      }
      s2 = {
        cidr = "10.1.128.0/25"
        az   = "us-east-1b"
      }
    }
  }
}

