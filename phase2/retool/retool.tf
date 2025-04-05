provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "retool" {
  name       = "retool"
  namespace  = "retool"
  repository = "https://charts.retool.com"
  chart      = "retool"
  values     = [file("values.yaml")]

  set {
    name  = "ingress.enabled"
    value = "false"
  }
}

