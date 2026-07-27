
# Correções incorporadas após testes reais

## Revisão 2 — 26/07/2026

- corrigida a versão inexistente `2026.5.0` do chart SonarQube para `2026.4.0`;
- corrigido o output Terraform derivado de valor sensível;
- separado `install_gitlab_runner` do token sensível para uso seguro em `count`;
- `make platform` agora falha cedo quando o token `glrt-` não foi exportado;
- adicionados `make runner-check` e `make ci-check`;
- documentado que tags e Protected são configurados no GitLab com tokens `glrt-`;
- removida a orientação principal de instalar/register Runner diretamente no WSL;
- novo instalador Kind com SHA-256, validação ELF e teste de versão;
- `make check` agora executa `kind version`, detectando HTML instalado como binário;
- corrigida a tag local para ser calculada uma única vez com `:=`;
- adicionada verificação de existência das imagens antes de `kind load`;
- esclarecido que `make local-deploy` não executa jobs da pipeline.


## Revisão final — 2026-07-26

- `make destroy` passou a usar Terraform, Kind e fallback Docker por label/nome;
- adicionado `make recover` para reinício de nós Kind parados e kubeconfig obsoleto;
- corrigido `GreetingController` para resposta HTTP 400 na validação;
- removido uso frágil de `gitlab-runner verify` do diagnóstico;
- adicionado tratamento de release Helm órfã do Runner;
- documentação esclarece port-forward do Sonar e execução apenas após merge em main;
- criado `docs/CLEAN-START.md` para repetição sem states e Git antigos.
