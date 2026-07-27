resource "helm_release" "gitlab_runner" {
  count = var.install_gitlab_runner ? 1 : 0

  name       = "gitlab-runner"
  namespace  = kubernetes_namespace_v1.gitlab_runner.metadata[0].name
  repository = "https://charts.gitlab.io"
  chart      = "gitlab-runner"
  version    = var.gitlab_runner_chart_version

  wait    = true
  timeout = 600

  lifecycle {
    precondition {
      condition = nonsensitive(
        var.gitlab_runner_token != "" && startswith(var.gitlab_runner_token, "glrt-")
      )
      error_message = "Para instalar o Runner, informe um token válido com prefixo glrt-."
    }
  }

  values = [
    yamlencode({
      gitlabUrl     = var.gitlab_url
      runnerToken   = var.gitlab_runner_token
      concurrent    = 2
      checkInterval = 3

      rbac = {
        create = true
      }

      serviceAccount = {
        create = true
        name   = "gitlab-runner"
      }

      runners = {
        # Com tokens glrt-, tags, acesso a branches protegidas e run-untagged
        # são atributos do Runner criado na interface do GitLab.
        config = <<-TOML
          [[runners]]
            request_concurrency = 2
            [runners.kubernetes]
              namespace = "gitlab-runner"
              image = "alpine:3.22"
              privileged = true
              service_account = "gitlab-runner"
              poll_timeout = 600
              cpu_request = "100m"
              memory_request = "128Mi"
              helper_cpu_request = "50m"
              helper_memory_request = "128Mi"
              [runners.kubernetes.pod_labels]
                "lab.openai.dev/component" = "gitlab-job"
        TOML
      }
    })
  ]

  depends_on = [kubernetes_role_binding_v1.gitlab_runner_deployer]
}
