#!/usr/bin/env bash
set -Eeuo pipefail

required=(docker terraform kubectl helm kind git)
failed=0

for command_name in "${required[@]}"; do
  if command -v "$command_name" >/dev/null 2>&1; then
    printf '[OK]   %-12s %s
' "$command_name" "$(command -v "$command_name")"
  else
    printf '[ERRO] %-12s não encontrado
' "$command_name"
    failed=1
  fi
done

if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then
    printf '[OK]   Docker Engine acessível
'
  else
    printf '[ERRO] Docker existe, mas o daemon não está acessível
'
    failed=1
  fi
fi

if (( failed != 0 )); then
  cat <<'EOF'

Instale os itens ausentes antes de continuar. O README contém os comandos e as
versões recomendadas para Ubuntu/WSL2.
EOF
  exit 1
fi

printf '
Pré-requisitos básicos atendidos.
'
