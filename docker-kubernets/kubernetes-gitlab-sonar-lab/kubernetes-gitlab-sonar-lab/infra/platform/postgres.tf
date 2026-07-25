resource "random_password" "postgres" {
  length  = 24
  special = false
}

resource "kubernetes_secret_v1" "postgres" {
  metadata {
    name      = "sonarqube-postgres"
    namespace = kubernetes_namespace_v1.sonarqube.metadata[0].name
  }

  data = {
    POSTGRES_DB       = "sonar"
    POSTGRES_USER     = "sonar"
    POSTGRES_PASSWORD = random_password.postgres.result
  }

  type = "Opaque"
}

resource "kubernetes_service_v1" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace_v1.sonarqube.metadata[0].name
  }

  spec {
    selector = {
      app = "sonarqube-postgres"
    }

    port {
      name        = "postgres"
      port        = 5432
      target_port = 5432
    }

    cluster_ip = "None"
  }
}

resource "kubernetes_stateful_set_v1" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace_v1.sonarqube.metadata[0].name
  }

  spec {
    service_name = kubernetes_service_v1.postgres.metadata[0].name
    replicas     = 1

    selector {
      match_labels = {
        app = "sonarqube-postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "sonarqube-postgres"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = "postgres:17-alpine"

          port {
            name           = "postgres"
            container_port = 5432
          }

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.postgres.metadata[0].name
            }
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "768Mi"
            }
          }

          readiness_probe {
            exec {
              command = ["sh", "-c", "pg_isready -U $POSTGRES_USER -d $POSTGRES_DB"]
            }
            initial_delay_seconds = 10
            period_seconds        = 5
          }

          volume_mount {
            name       = "data"
            mount_path = "/var/lib/postgresql/data"
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "data"
      }

      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = "standard"

        resources {
          requests = {
            storage = "3Gi"
          }
        }
      }
    }
  }
}
