resource "aws_eks_cluster" "main" {
  name = var.env

  role_arn = aws_iam_role.cluster.arn
  version  = "1.35"

  vpc_config {
    subnet_ids              = var.subnets
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

resource "aws_eks_addon" "eks-pod-identity" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "eks-pod-identity-agent"
}

resource "aws_vpc_security_group_ingress_rule" "add-https-to-bastion" {
  security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  cidr_ipv4         = "172.31.0.0/16"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_iam_role" "cluster" {
  name = "eks-cluster-${var.env}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role" "node" {
  name = "eks-node-group-example"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "main-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "main-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "main-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

resource "aws_launch_template" "main" {
  name = "${aws_eks_cluster.main.name}-lt"
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      encrypted  = true
      kms_key_id = var.kms_key_id
    }
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.env}-ng"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnets
  instance_types  = ["t3.small"]
  capacity_type   = "ON_DEMAND"
  launch_template {
    version = "$Latest"
    name    = "${aws_eks_cluster.main.name}-lt"
  }


  scaling_config {
    desired_size = 5
    max_size     = 10
    min_size     = 5
  }

  depends_on = [
    aws_iam_role_policy_attachment.main-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.main-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.main-AmazonEC2ContainerRegistryReadOnly,
    aws_launch_template.main
  ]

  lifecycle {
    ignore_changes = [
      launch_template
    ]
  }
}

