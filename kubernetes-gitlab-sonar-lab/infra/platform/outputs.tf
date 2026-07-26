
output "sonarqube_service" {
  description = "Endereço interno usado pelos jobs do GitLab Runner."
  value       = "http://sonarqube.sonarqube.svc.cluster.local:9000"
}

output "runner_installed" {
  description = "Indica se a instalação do GitLab Runner foi solicitada."
  value       = var.install_gitlab_runner
}

output "runner_namespace" {
  description = "Namespace reservado ao GitLab Runner e aos pods de jobs."
  value       = kubernetes_namespace_v1.gitlab_runner.metadata[0].name
}

output "next_steps" {
  value = <<-EOT
    1. Execute: make runner-check
    2. Execute: make sonar
    3. Gere SONAR_TOKEN e cadastre-o no GitLab.
    4. Cadastre REGISTRY_DEPLOY_USER e REGISTRY_DEPLOY_PASSWORD.
    5. Somente depois faça o primeiro git push.
  EOT
}
