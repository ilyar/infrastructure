# GitLab Runner Helm Chart https://docs.gitlab.com/runner/install/kubernetes.html
resource "kubernetes_namespace" "gitlab_runner" {
  metadata {
    name = "gitlab-runner"
  }
}

# TODO create gcs bucket stage-gitlab-cache and add permission Storage Object Admin for module.infra.google_service_account
# INFO https://gitlab.com/gitlab-org/gitlab-runner/-/issues/5018
# SAMPLE sample/stage/gcs.yaml
# https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runnerscachegcs-section
resource "helm_release" "gitlab_runner" {
  name = "${module.infra.environment}-gitlab-runner"

  repository = "https://charts.gitlab.io"
  chart      = "gitlab-runner"
  namespace  = kubernetes_namespace.gitlab_runner.metadata.0.name
  version    = "0.23.0"

  values = [<<YAML
fullnameOverride: "${module.infra.environment}-gitlab-runner"
gitlabUrl: "https://gitlab.com"
rbac:
  create: true
runnerRegistrationToken: "${var.ci_token}"
unregisterRunners: true
runners:
  config: |
    [[runners]]
      environment= ["DOCKER_TLS_CERTDIR=", "DOCKER_DRIVER=overlay2", "DOCKER_HOST=tcp://localhost:2375"]
      [runners.cache]
        Type = "gcs"
        Path = "runner"
        Shared = true
        [runners.cache.gcs]
          BucketName = "stage-gitlab-cache"
          AccessID = "${module.infra.service_account}"
          PrivateKey = "${module.infra.service_account_private_key}"
      [runners.kubernetes]
        privileged = true
YAML
  ]
}
