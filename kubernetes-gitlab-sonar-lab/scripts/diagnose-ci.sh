
#!/usr/bin/env bash
set -Eeuo pipefail

: "${KUBECONFIG:?Defina KUBECONFIG antes de executar este script}"
root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

printf '=== Diagnóstico local do Runner ===\n'
"$root_dir/scripts/check-runner.sh"

printf '\n=== Tag exigida pelo pipeline ===\n'
awk '
  /^default:/ {in_default=1; next}
  in_default && /^  tags:/ {in_tags=1; next}
  in_tags && /^    - / {sub(/^    - /, ""); print; exit}
' "$root_dir/.gitlab-ci.yml"

cat <<'EOF'

=== Conferências obrigatórias na interface do GitLab ===
1. Settings > CI/CD > Runners: o Project Runner deve estar Online.
2. A tag deve ser exatamente: kubernetes
3. A opção Protected deve estar desmarcada para executar branches feature/MRs.
4. O runner não deve estar pausado.
5. Instance runners podem ser desabilitados; este lab usa o Project Runner local.

Importante: make local-deploy não processa jobs do GitLab. Ele apenas constrói e
implanta imagens localmente. Um job Pending só é liberado quando um Runner online
com tags e regras compatíveis solicita o job ao GitLab.
EOF
