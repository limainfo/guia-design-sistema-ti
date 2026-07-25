resource "helm_release" "gitlab_runner" {
  count = var.gitlab_runner_token == "" ? 0 : 1

  name       = "gitlab-runner"
  namespace  = kubernetes_namespace_v1.gitlab_runner.metadata[0].name
  repository = "https://charts.gitlab.io"
  chart      = "gitlab-runner"
  version    = var.gitlab_runner_chart_version

  wait    = true
  timeout = 600

  values = [
    yamlencode({
      gitlabUrl   = var.gitlab_url
      runnerToken = var.gitlab_runner_token
      concurrent  = 2

      rbac = {
        create = true
      }

      serviceAccount = {
        create = true
        name   = "gitlab-runner"
      }

      runners = {
        tags        = "kubernetes,kind,java,angular"
        runUntagged = true
        config      = <<-TOML
          [[runners]]
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
