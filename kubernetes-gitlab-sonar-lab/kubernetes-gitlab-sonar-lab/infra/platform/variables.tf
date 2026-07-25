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

variable "gitlab_runner_token" {
  description = "Token de autenticação do Project Runner (prefixo glrt-). Deixe vazio para não instalar o runner."
  type        = string
  sensitive   = true
  default     = ""
}

variable "gitlab_runner_chart_version" {
  description = "Versão do chart oficial do GitLab Runner."
  type        = string
  default     = "0.91.0"
}

variable "sonarqube_chart_version" {
  description = "Versão do chart oficial do SonarQube."
  type        = string
  default     = "2026.5.0"
}
