
#!/usr/bin/env bash
set -Eeuo pipefail

failed=0
warnings=0

ok()    { printf '[OK]    %-14s %s\n' "$1" "$2"; }
warn()  { printf '[AVISO] %-14s %s\n' "$1" "$2"; warnings=$((warnings + 1)); }
error() { printf '[ERRO]  %-14s %s\n' "$1" "$2"; failed=1; }

check_command() {
  local name="$1"
  if command -v "$name" >/dev/null 2>&1; then
    ok "$name" "$(command -v "$name")"
  else
    error "$name" 'não encontrado'
  fi
}

for cmd in docker terraform kubectl helm kind git curl; do
  check_command "$cmd"
done

if command -v kind >/dev/null 2>&1; then
  if kind_output="$(kind version 2>&1)" && [[ "$kind_output" == kind\ v* ]]; then
    ok 'kind version' "$kind_output"
  else
    error 'kind version' 'binário inválido ou corrompido; execute make install-kind'
    printf '%s\n' "$kind_output" | head -n 3 >&2 || true
  fi
fi

if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then
    ok 'Docker Engine' 'daemon acessível'
    cgroup_version="$(docker info --format '{{.CgroupVersion}}' 2>/dev/null || true)"
    if [[ -n "$cgroup_version" ]]; then
      if [[ "$cgroup_version" == '2' ]]; then
        ok 'cgroup' 'v2'
      else
        warn 'cgroup' "versão $cgroup_version; Kubernetes recente funciona melhor com cgroup v2"
      fi
    fi
  else
    error 'Docker Engine' 'CLI instalada, mas o daemon não está acessível'
  fi
fi

if command -v terraform >/dev/null 2>&1; then
  ok 'Terraform' "$(terraform version | head -n 1)"
fi
if command -v kubectl >/dev/null 2>&1; then
  ok 'kubectl' "$(kubectl version --client 2>/dev/null | head -n 1)"
fi
if command -v helm >/dev/null 2>&1; then
  ok 'Helm' "$(helm version --short 2>/dev/null | head -n 1)"
fi
if command -v git >/dev/null 2>&1; then
  ok 'Git' "$(git --version)"
fi

memory_kib="$(awk '/MemTotal/ {print $2}' /proc/meminfo 2>/dev/null || echo 0)"
if [[ "$memory_kib" =~ ^[0-9]+$ ]] && (( memory_kib > 0 )); then
  memory_gib=$((memory_kib / 1024 / 1024))
  if (( memory_gib >= 12 )); then
    ok 'Memória' "aproximadamente ${memory_gib} GiB"
  else
    warn 'Memória' "aproximadamente ${memory_gib} GiB; reserve ao menos 12 GiB para o lab"
  fi
fi

for port in 8080 8081 9000; do
  if command -v ss >/dev/null 2>&1 && ss -ltnH "sport = :$port" 2>/dev/null | grep -q .; then
    warn "porta $port" 'já está em uso; pode ser o próprio laboratório ou outro processo'
  fi
done

if (( failed != 0 )); then
  cat <<'EOF'

Há pré-requisitos inválidos. Consulte docs/INSTALLATION.md.
Se o Kind imprimir HTML ou erro de sintaxe, execute: make install-kind
EOF
  exit 1
fi

printf '\nPré-requisitos essenciais atendidos.'
if (( warnings > 0 )); then
  printf ' Foram emitidos %d aviso(s).\n' "$warnings"
else
  printf '\n'
fi
