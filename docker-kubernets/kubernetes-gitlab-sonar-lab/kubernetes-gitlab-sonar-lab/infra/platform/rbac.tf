resource "kubernetes_role_v1" "gitlab_deployer" {
  metadata {
    name      = "gitlab-deployer"
    namespace = kubernetes_namespace_v1.dev.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "endpoints", "pods", "pods/log", "secrets", "services", "serviceaccounts", "persistentvolumeclaims"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "deployments/scale", "replicasets", "statefulsets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses", "networkpolicies"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_role_binding_v1" "gitlab_runner_deployer" {
  metadata {
    name      = "gitlab-runner-deployer"
    namespace = kubernetes_namespace_v1.dev.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.gitlab_deployer.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "gitlab-runner"
    namespace = kubernetes_namespace_v1.gitlab_runner.metadata[0].name
  }
}
