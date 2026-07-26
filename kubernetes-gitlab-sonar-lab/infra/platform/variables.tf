
variable "kubeconfig_path" {
  description = "Kubeconfig do cluster Kind já existente."
  type        = string
  default     = "../../.kube/kind-config"
}

variable "gitlab_url" {
  description = "URL da instância GitLab."
  type        = string
  default     = "https://gitlab.com/"
}

variable "install_gitlab_runner" {
  description = "Instala o GitLab Runner no Kubernetes."
  type        = bool
  default     = false
}

variable "gitlab_runner_token" {
  description = "Token de autenticação do Project Runner (prefixo glrt-)."
  type        = string
  sensitive   = true
  default     = ""

  validation {
    condition     = var.gitlab_runner_token == "" || startswith(var.gitlab_runner_token, "glrt-")
    error_message = "gitlab_runner_token deve estar vazio ou iniciar com glrt-."
  }
}

variable "gitlab_runner_chart_version" {
  description = "Versão do chart oficial do GitLab Runner."
  type        = string
  default     = "0.91.0"
}

variable "sonarqube_chart_version" {
  description = "Versão do chart oficial do SonarQube."
  type        = string
  default     = "2026.4.0"
}
