
#!/usr/bin/env bash
set -Eeuo pipefail

KIND_VERSION="${KIND_VERSION:-v0.32.0}"
INSTALL_PATH="${INSTALL_PATH:-/usr/local/bin/kind}"

case "$(uname -m)" in
  x86_64|amd64) KIND_ARCH="amd64" ;;
  aarch64|arm64) KIND_ARCH="arm64" ;;
  *)
    printf '[ERRO] Arquitetura não suportada automaticamente: %s\n' "$(uname -m)" >&2
    exit 1
    ;;
esac

for cmd in curl sha256sum od sudo; do
  command -v "$cmd" >/dev/null 2>&1 || {
    printf '[ERRO] Comando obrigatório não encontrado: %s\n' "$cmd" >&2
    exit 1
  }
done

asset="kind-linux-${KIND_ARCH}"
base_url="https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERSION}"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

printf 'Baixando Kind %s para linux/%s...\n' "$KIND_VERSION" "$KIND_ARCH"
curl --fail --location --show-error --silent --retry 3 --retry-delay 2 \
  --proto '=https' --tlsv1.2 \
  --output "$tmp_dir/$asset" "$base_url/$asset"
curl --fail --location --show-error --silent --retry 3 --retry-delay 2 \
  --proto '=https' --tlsv1.2 \
  --output "$tmp_dir/$asset.sha256sum" "$base_url/$asset.sha256sum"

printf 'Validando SHA-256 publicado na release oficial...\n'
(
  cd "$tmp_dir"
  sha256sum --check "$asset.sha256sum"
)

magic_bytes="$(od -An -t x1 -N4 "$tmp_dir/$asset" | tr -d ' \n')"
if [[ "$magic_bytes" != "7f454c46" ]]; then
  printf '[ERRO] O conteúdo baixado não é um executável ELF.\n' >&2
  printf 'Início do arquivo recebido:\n' >&2
  head -c 200 "$tmp_dir/$asset" >&2 || true
  printf '\n' >&2
  exit 1
fi

chmod 0755 "$tmp_dir/$asset"
printf 'Validando o binário antes da instalação...\n'
"$tmp_dir/$asset" version

printf 'Instalando em %s...\n' "$INSTALL_PATH"
sudo install -o root -g root -m 0755 "$tmp_dir/$asset" "$INSTALL_PATH"
hash -r

printf '\nInstalação concluída:\n'
"$INSTALL_PATH" version
printf 'Caminho resolvido: %s\n' "$(command -v kind)"
