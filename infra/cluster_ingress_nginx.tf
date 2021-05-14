# Ingress Nginx
resource "helm_release" "ingress_nginx" {
  name = var.environment

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  version    = "3.15.2"

  create_namespace = true

  wait = true

  depends_on = [
    module.gke.endpoint,
  ]

  values = [<<EOF
controller:
  service:
    externalTrafficPolicy: Local
    loadBalancerIP: ${google_compute_address.ingress.address}
  config:
    proxy-body-size: "32m"
EOF
  ]
}
