resource "kubernetes_namespace_v1" "dev" {
  metadata {
    name = "dev"
    labels = {
      "lab.openai.dev/purpose" = "application"
    }
  }
}

resource "kubernetes_namespace_v1" "sonarqube" {
  metadata {
    name = "sonarqube"
    labels = {
      "lab.openai.dev/purpose" = "quality"
    }
  }
}

resource "kubernetes_namespace_v1" "gitlab_runner" {
  metadata {
    name = "gitlab-runner"
    labels = {
      "lab.openai.dev/purpose" = "ci"
    }
  }
}
