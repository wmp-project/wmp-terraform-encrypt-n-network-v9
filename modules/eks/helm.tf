resource "null_resource" "kube-config" {

  depends_on = [aws_eks_node_group.main]

  triggers = {
    alltime = timestamp()
  }

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${var.env}"
  }

}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "traefik" {

  depends_on = [null_resource.kube-config]

  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"

  set = [
    {
      name  = "ports.web.http.redirections.entryPoint.to"
      value = "websecure"
    },
    {
      name  = "ports.web.http.redirections.entryPoint.scheme"
      value = "https"
    },
    {
      name  = "ports.web.http.redirections.entryPoint.permanent"
      value = "true"
    },
    # ACM certificate ARN
    {
      name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"
      value = "arn:aws:acm:us-east-1:739561048503:certificate/357141e3-f378-4020-a8f5-b9d69a94316f"
    },

    # Enable TLS on 443
    {
      name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-ports"
      value = "443"
    },

    # Forward decrypted traffic to Traefik over HTTP
    {
      name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-backend-protocol"
      value = "http"
    },
  ]

}

resource "helm_release" "argocd" {

  depends_on = [null_resource.kube-config, helm_release.traefik]

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  set = [
    {
      name  = "server.ingress.enabled"
      value = "true"
    },
    {
      name  = "server.ingress.ingressClassName"
      value = "traefik"
    },
    {
      name  = "configs.params.server\\.insecure"
      value = "true"
    },
    {
      name  = "global.domain"
      value = "argocd-${var.env}.raghudevopsb88.online"
    },
  ]
}

resource "helm_release" "prometheus-stack" {

  depends_on = [null_resource.kube-config, helm_release.traefik]

  name       = "kubestack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  set = [
    {
      name  = "prometheus.ingress.enabled"
      value = "true"
    },
    {
      name  = "prometheus.ingress.ingressClassName"
      value = "traefik"
    }
  ]
  set_list = [
    {
      name  = "prometheus.ingress.hosts"
      value = ["prometheus-${var.env}.raghudevopsb88.online"]
    }
  ]
}

resource "helm_release" "file-beat" {

  depends_on = [null_resource.kube-config]

  name       = "filebeat"
  repository = "https://helm.elastic.co"
  chart      = "filebeat"

  values = [
    file("${path.module}/filebeat.yml")
  ]
}




resource "helm_release" "external-dns" {
  depends_on       = [null_resource.kube-config, helm_release.traefik]
  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns"
  chart            = "external-dns"
  create_namespace = true
}
