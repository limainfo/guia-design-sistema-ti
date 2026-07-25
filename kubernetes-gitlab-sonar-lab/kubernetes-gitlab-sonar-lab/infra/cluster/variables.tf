variable "cluster_name" {
  description = "Nome do cluster Kind."
  type        = string
  default     = "microplatform-dev"
}

variable "kubeconfig_path" {
  description = "Caminho no qual o kubeconfig será gravado."
  type        = string
  default     = "../../.kube/kind-config"
}

variable "node_image" {
  description = "Imagem dos nós Kind/Kubernetes fixada por digest."
  type        = string
  default     = "kindest/node:v1.35.5@sha256:ce977ae6d65918d0b58a5f8b5e940429c2ce42fa3a5619ec2bbc60b949c0ac95"
}
