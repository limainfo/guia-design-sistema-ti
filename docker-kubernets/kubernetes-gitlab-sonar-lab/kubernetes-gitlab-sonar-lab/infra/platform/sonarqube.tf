resource "random_password" "sonar_monitoring" {
  length  = 24
  special = false
}

resource "helm_release" "sonarqube" {
  name       = "sonarqube"
  namespace  = kubernetes_namespace_v1.sonarqube.metadata[0].name
  repository = "https://SonarSource.github.io/helm-chart-sonarqube"
  chart      = "sonarqube"
  version    = var.sonarqube_chart_version

  wait    = true
  timeout = 1200

  values = [
    yamlencode({
      fullnameOverride = "sonarqube"

      community = {
        enabled = true
      }

      monitoringPasscode = random_password.sonar_monitoring.result

      jdbcOverwrite = {
        enabled               = true
        jdbcUrl               = "jdbc:postgresql://postgres.sonarqube.svc.cluster.local:5432/sonar"
        jdbcUsername          = "sonar"
        jdbcSecretName        = kubernetes_secret_v1.postgres.metadata[0].name
        jdbcSecretPasswordKey = "POSTGRES_PASSWORD"
      }

      persistence = {
        enabled      = true
        storageClass = "standard"
        size         = "5Gi"
      }

      resources = {
        requests = {
          cpu    = "400m"
          memory = "2Gi"
        }
        limits = {
          cpu    = "1500m"
          memory = "4Gi"
        }
      }

      tests = {
        enabled = false
      }
    })
  ]

  depends_on = [kubernetes_stateful_set_v1.postgres]
}
