output "cluster_name" {
  value       = kind_cluster.lab.name
  description = "Nome do cluster criado."
}

output "kubeconfig_path" {
  value       = kind_cluster.lab.kubeconfig_path
  description = "Arquivo kubeconfig do laboratório."
}

output "endpoint" {
  value       = kind_cluster.lab.endpoint
  description = "Endpoint da API Kubernetes."
}
