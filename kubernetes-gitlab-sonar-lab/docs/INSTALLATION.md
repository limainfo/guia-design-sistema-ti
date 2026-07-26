# Instalação e preparação do ambiente WSL2

Este laboratório foi organizado para Ubuntu 24.04 no WSL2. Execute todos os
comandos abaixo dentro do Ubuntu. Evite misturar binários Windows de `kubectl`,
`kind`, Terraform ou Helm com o Docker acessado pelo WSL.

## 1. Pacotes básicos

```bash
sudo apt update
sudo apt install -y ca-certificates curl wget gnupg lsb-release unzip git make
```

## 2. Docker

Há duas opções válidas:

- Docker Desktop no Windows com integração habilitada para a distribuição WSL;
- Docker Engine instalado diretamente no Ubuntu.

Para Docker Engine, configure o repositório oficial:

```bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF_DOCKER
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF_DOCKER

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin
```

Permita uso sem `sudo`:

```bash
sudo usermod -aG docker "$USER"
newgrp docker
```

Valide:

```bash
docker info
docker run --rm hello-world
```

## 3. Terraform

Instale pelo repositório oficial da HashiCorp:

```bash
wget -O- https://apt.releases.hashicorp.com/gpg \
  | gpg --dearmor \
  | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(. /etc/os-release && echo "$VERSION_CODENAME") main" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null

sudo apt update
sudo apt install -y terraform
terraform version
```

O laboratório requer Terraform 1.11 ou superior.

## 4. kubectl 1.35.5

O cliente deve estar no máximo uma versão minor distante do cluster. O lab usa
Kubernetes 1.35.5, portanto instala o cliente correspondente:

```bash
KUBECTL_VERSION=v1.35.5
ARCH=amd64

curl -fLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl"
curl -fLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl kubectl.sha256
kubectl version --client
```

Para ARM64, altere `ARCH=arm64`.

## 5. Helm 4

Use o instalador oficial do Helm 4:

```bash
curl -fsSL -o /tmp/get_helm.sh \
  https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 /tmp/get_helm.sh
/tmp/get_helm.sh
rm -f /tmp/get_helm.sh
helm version
```

## 6. Kind 0.32.0

O pacote contém um instalador mais defensivo que o comando simples de download:

```bash
make install-kind
kind version
```

Ele baixa o executável e o arquivo SHA-256 da release oficial, valida ambos,
confirma os bytes ELF e somente então substitui `/usr/local/bin/kind`. Isso evita
a instalação acidental de uma página HTML, que produz erro próximo de `<`.

## 7. Validação final

```bash
make check
```

O comando verifica a existência e execução dos binários, acesso ao Docker,
cgroup, memória aproximada e possíveis conflitos nas portas 8080, 8081 e 9000.

## 8. Recursos do WSL2

Reserve pelo menos 12 GiB de RAM para WSL/Docker. O SonarQube pode usar até
4 GiB e os jobs Maven/Angular criam pods adicionais. Exemplo de `%UserProfile%\.wslconfig`:

```ini
[wsl2]
memory=16GB
processors=8
swap=6GB
```

Após alterar o arquivo, execute no PowerShell:

```powershell
wsl --shutdown
```

## 9. Conectividade necessária

O laboratório precisa de saída HTTPS para:

- GitLab.com e GitLab Container Registry;
- GitHub releases;
- Docker Hub;
- repositórios Maven e NPM;
- repositórios Helm do GitLab e SonarSource.

Em rede corporativa com proxy, configure `HTTP_PROXY`, `HTTPS_PROXY` e
`NO_PROXY` também no Docker e no WSL antes de criar o cluster.
