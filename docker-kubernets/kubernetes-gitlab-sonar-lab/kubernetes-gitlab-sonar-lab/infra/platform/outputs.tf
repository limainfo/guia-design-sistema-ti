output "sonarqube_service" {
  description = "Endereço interno usado pelos jobs do GitLab Runner."
  value       = "http://sonarqube.sonarqube.svc.cluster.local:9000"
}

output "runner_installed" {
  description = "Indica se o token do runner foi informado."
  value       = var.gitlab_runner_token != ""
}

output "next_steps" {
  value = <<-EOT
    1. Execute: make sonar
    2. Acesse http://localhost:9000 e gere um token.
    3. Cadastre SONAR_TOKEN no GitLab.
    4. Cadastre REGISTRY_DEPLOY_USER e REGISTRY_DEPLOY_PASSWORD.
  EOT
}
