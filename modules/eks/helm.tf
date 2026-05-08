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

resource "helm_release" "argocd" {

  depends_on = [null_resource.kube-config]

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  set = [
    {
      name  = "server.service.type"
      value = "LoadBalancer"
    }
  ]
}

resource "helm_release" "kube-stack" {

  depends_on = [null_resource.kube-config]

  name       = "kubestack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  set = [
    {
      name  = "prometheus.service.type"
      value = "LoadBalancer"
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

