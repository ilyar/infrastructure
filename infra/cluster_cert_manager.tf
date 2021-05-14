# Cert Manager
locals {
  cert_manager = "cert-manager"

  cert_manager_cluster_issuer = "ClusterIssuer"
  cert_manager_config = {
    kind = "ClusterIssuer"
    server = {
      prod = {
        name = "letsencrypt"
        url  = "https://acme-v02.api.letsencrypt.org/directory"
      }
      staging = {
        name = "letsencrypt-staging"
        url  = "https://acme-staging-v02.api.letsencrypt.org/directory"
      }
    }
  }
  cert_manager_annotation         = join("/", ["cert-manager.io", lower(join("-", regexall("[A-Z][^A-Z]*", local.cert_manager_cluster_issuer)))])
  cert_manager_annotation_prod    = join(": ", [local.cert_manager_annotation, local.cert_manager_config.server.prod.name])
  cert_manager_annotation_staging = join(": ", [local.cert_manager_annotation, local.cert_manager_config.server.staging.name])
}

resource "helm_release" "cert_manager" {
  name       = local.cert_manager
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = local.cert_manager

  depends_on = [
    helm_release.ingress_nginx,
  ]

  create_namespace = true

  wait = true

  values = [<<YAML
installCRDs: true
global:
  leaderElection:
    namespace: "${local.cert_manager}"
YAML
  ]
}

data "template_file" "cert_manager_cluster_issuer" {
  template = file("${path.module}/cluster_cert_manager_cluster_issuer.tpl")
  vars = {
    kind   = local.cert_manager_config.kind
    name   = local.cert_manager_config.server.prod.name
    server = local.cert_manager_config.server.prod.url
  }
}

resource "k8s_manifest" "cert_manager_issuer" {
  depends_on = [
    helm_release.cert_manager,
  ]
  content = data.template_file.cert_manager_cluster_issuer.rendered
}

data "template_file" "cert_manager_cluster_issuer_staging" {
  template = file("${path.module}/cluster_cert_manager_cluster_issuer.tpl")
  vars = {
    kind   = local.cert_manager_config.kind
    name   = local.cert_manager_config.server.staging.name
    server = local.cert_manager_config.server.staging.url
  }
}

resource "k8s_manifest" "cert_manager_cluster_issuer_staging" {
  depends_on = [
    helm_release.cert_manager,
  ]
  content = data.template_file.cert_manager_cluster_issuer_staging.rendered
}
