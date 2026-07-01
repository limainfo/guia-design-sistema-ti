# Secure Development

Material de revisão em português, organizado para consulta no GitHub e estudo para prova. O conteúdo consolida os e-books e slides das Aulas 1, 2 e 3, mantendo fidelidade ao material-base e incorporando notas atuais de referência quando relevante.

## Como usar este repositório

Leia primeiro os capítulos 1 a 3 para formar a base de desenvolvimento seguro, OWASP, SAST e SCA. Depois avance pelos capítulos 4 a 7, que aprofundam riscos de APIs do OWASP API Security Top 10 2023. Por fim, estude os capítulos 8 a 13, que tratam de segurança mobile com OWASP MASVS.

## Sumário

| Capítulo | Tema | Arquivo |
|---:|---|---|
| 1 | Introdução ao Desenvolvimento Seguro | [docs/01-introducao-desenvolvimento-seguro.md](docs/01-introducao-desenvolvimento-seguro.md) |
| 2 | Projeto OWASP | [docs/02-projeto-owasp.md](docs/02-projeto-owasp.md) |
| 3 | Tornando o Código Fonte Mais Seguro | [docs/03-codigo-fonte-seguro-sast-sca.md](docs/03-codigo-fonte-seguro-sast-sca.md) |
| 4 | Ameaças em APIs e BOLA | [docs/04-ameacas-em-apis-bola.md](docs/04-ameacas-em-apis-bola.md) |
| 5 | Autenticação em APIs | [docs/05-autenticacao-em-apis.md](docs/05-autenticacao-em-apis.md) |
| 6 | Tampering e Consumo Irrestrito | [docs/06-tampering-e-consumo-irrestrito.md](docs/06-tampering-e-consumo-irrestrito.md) |
| 7 | Governança e Segurança para APIs | [docs/07-governanca-seguranca-apis.md](docs/07-governanca-seguranca-apis.md) |
| 8 | Desenvolvimento Seguro para Aplicativos Mobile | [docs/08-masvs-storage-crypto.md](docs/08-masvs-storage-crypto.md) |
| 9 | Autenticação Segura para Aplicativos | [docs/09-autenticacao-segura-aplicativos.md](docs/09-autenticacao-segura-aplicativos.md) |
| 10 | Protegendo Rede e Plataforma | [docs/10-rede-plataforma-mobile.md](docs/10-rede-plataforma-mobile.md) |
| 11 | Protegendo Código e Versões do App | [docs/11-codigo-versoes-aplicativo.md](docs/11-codigo-versoes-aplicativo.md) |
| 12 | Técnicas contra Engenharia Reversa | [docs/12-engenharia-reversa-resiliencia.md](docs/12-engenharia-reversa-resiliencia.md) |
| 13 | Controles sobre Privacidade | [docs/13-controles-privacidade.md](docs/13-controles-privacidade.md) |

## Extras de revisão

- [Glossário](extras/glossario.md)
- [Questões de revisão](extras/questoes-revisao.md)
- [Checklist prático DevSecOps](extras/checklist-devsecops.md)
- [Todos os diagramas Mermaid](extras/diagramas-mermaid.md)
- [Documento consolidado](secure-development-completo.md)

## Atualizações importantes

O material original trabalha com OWASP API Security Top 10 2023 para APIs, que continua sendo a referência estável utilizada nos capítulos de API. Para aplicações web gerais, a página oficial do OWASP Top 10 informa versão mais recente 2025; por isso, este material separa claramente **OWASP Top 10 Web** de **OWASP API Security Top 10 2023**.

Para mobile, o material usa OWASP MASVS. A página oficial do MASVS organiza os controles em oito grupos: STORAGE, CRYPTO, AUTH, NETWORK, PLATFORM, CODE, RESILIENCE e PRIVACY.

## Padrão didático adotado

Cada capítulo segue a mesma estrutura:

1. Objetivo do capítulo.
2. Ideia central para prova.
3. Conceitos essenciais.
4. Diagrama Mermaid equivalente aos visuais do material.
5. Como aplicar na prática.
6. Checklist de revisão.
7. Questões de fixação.
8. Erros comuns.

## Referências oficiais úteis

- OWASP: https://owasp.org/
- OWASP API Security Top 10 2023: https://owasp.org/API-Security/editions/2023/en/0x11-t10/
- OWASP MASVS: https://mas.owasp.org/MASVS/
- OWASP API Security Tools: https://owasp.org/www-community/api_security_tools
- OWASP Juice Shop: https://owasp.org/www-project-juice-shop/
- CVE: https://www.cve.org/
- CWE: https://cwe.mitre.org/
