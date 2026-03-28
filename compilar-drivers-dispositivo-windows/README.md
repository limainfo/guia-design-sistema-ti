# Procedimento Operacional

## Compilação, assinatura e instalação do driver virtual `avshws` em ambiente Windows com EWDK/Visual Studio
* Clonar repositório [https://github.com/robot9706/VirtualCameraDriver.git](https://github.com/robot9706/VirtualCameraDriver.git)
* Instalar https://learn.microsoft.com/en-us/legal/windows/hardware/enterprise-wdk-license-2022
* Abrir o arquivo .iso diretamente no Windows Explorer (montado como uma unidade E:, F: ou equivalente)
* Executar como administrador LaunchBuildEnv.cmd (vai abrir o terminal com tudo configurado)
---

### 1. Identificação 
**Procedimento:** Compilação e instalação do driver virtual `avshws`
**Projeto:** `VirtualCameraDriver`
**Módulo:** `Driver\avshws`
**Ambiente-alvo:** Windows x64
**Ferramental principal:** Enterprise WDK + Visual Studio Build Tools + MSBuild + SignTool + Inf2Cat
**Status atual:** Build e empacotamento concluídos com sucesso; pendência remanescente relacionada ao carregamento do driver no sistema operacional.

---

## 2. Objetivo

Estabelecer um procedimento padronizado para:

* compilar o driver `avshws` em arquitetura x64;
* aplicar os ajustes necessários no projeto para contornar incompatibilidades de build;
* gerar e assinar manualmente os artefatos do driver;
* adicionar o pacote ao Driver Store do Windows;
* registrar o estágio atual da instalação e a pendência ainda existente para carregamento definitivo do driver.

---

## 3. Escopo

Este procedimento aplica-se à reprodução do processo técnico realizado sobre o projeto `VirtualCameraDriver`, especificamente no diretório:

```text
D:\Documentos\GoogleDrive\camera-fake\VirtualCameraDriver\Driver\avshws
```

---

## 4. Pré-requisitos

### 4.1. Ambiente

* Windows 64 bits
* Prompt do Visual Studio / EWDK
* Enterprise WDK instalado
* Windows Kits instalados com `signtool.exe` e `Inf2Cat.exe`

### 4.2. Código-fonte

Repositório clonado localmente com a estrutura do projeto `VirtualCameraDriver`.

### 4.3. Certificado

Certificado de teste disponível para assinatura manual, identificado pelo thumbprint:

```text
6D1416DE6C271502E48C6DFFBACB5669B0685716
```

### 4.4. Configuração do Windows para carregamento do driver de teste
Para permitir o carregamento do driver de teste no Windows, foi necessário manter o sistema com testsigning habilitado e, adicionalmente, desabilitar temporariamente o recurso Integridade da memória em Segurança do Windows > Segurança do dispositivo > Isolamento de núcleo.

Durante a validação, verificou-se que:

* testsigning já estava habilitado;
* Secure Boot estava desativado;
* o bloqueio remanescente era causado pela Integridade da memória (HVCI/VBS);
* após desabilitar a Integridade da memória e reiniciar o sistema, o driver passou a carregar corretamente.

---

## 5. Fundamentação técnica resumida

Durante a execução do processo, foram identificados os seguintes comportamentos:

1. o projeto não podia ser compilado em Win32, exigindo build em x64;
2. o compilador mantinha /WX, transformando o warning C4996 em erro;
3. o target automático de assinatura falhava por não informar /fd SHA256;
4. após a falha de assinatura, o build removia automaticamente os artefatos não assinados;
5. a geração manual do .cat e sua assinatura resolveram a etapa de aceitação do pacote pelo Driver Store;
6. o carregamento do driver somente foi concluído com sucesso após desabilitar a Integridade da memória e reiniciar o Windows.

---

## 6. Ajustes obrigatórios no projeto

### 6.1. Compilar exclusivamente em x64

O projeto deve ser compilado com:

```bat
msbuild avshws.vcxproj /t:Clean;Build /p:Configuration=Debug /p:Platform=x64
```

A tentativa com `Win32` não é válida para o cenário tratado.

---

### 6.2. Desabilitação específica do warning 4996

O projeto continuava compilando com `/WX`, mesmo quando se tentava desabilitar o tratamento global de warnings como erro por linha de comando. Assim, a abordagem efetiva foi desabilitar especificamente o warning `4996`, relacionado ao uso de `ExAllocatePoolWithTag`. 

#### Ajuste aplicado no `avshws.vcxproj`

No bloco `ClCompile` da configuração `Debug|x64`, incluir:

```xml
<DisableSpecificWarnings>4996;%(DisableSpecificWarnings)</DisableSpecificWarnings>
```

---

### 6.3. Neutralização dos targets automáticos de assinatura e remoção de artefatos

Foi identificado que, após o link do driver, o build chamava `DriverTestSign` e `TestSign`. Quando a assinatura automática falhava, o target `RemoveUnsignedOutput` removia o `.sys`, `.inf` e `.pdb` gerados. 

#### Ajuste aplicado no final do arquivo `avshws.vcxproj`

Antes de `</Project>`, adicionar:

```xml
<Target Name="DriverTestSign" />
<Target Name="TestSign" />
<Target Name="RemoveUnsignedOutput" />
```

Esse ajuste foi indispensável para preservar os artefatos gerados e permitir a assinatura manual posterior.

---

## 7. Compilação do driver

### 7.1. Comando de build

Executar no diretório do projeto:

```bat
msbuild avshws.vcxproj /t:Clean;Build /p:Configuration=Debug /p:Platform=x64
```

### 7.2. Resultado esperado

A build gera os artefatos principais, mas pode terminar com falha no DrvCat.
Ao final, devem existir os artefatos abaixo em:

```text
x64\Debug\
```

Arquivos principais esperados:

* `avshws.sys`
* `avshws.inf`
* `avshws.pdb`

A geração do `.sys` foi confirmada no diretório de saída. 

---

## 8. Assinatura manual do arquivo `.sys`

Como a assinatura automática do projeto não funcionou corretamente, a assinatura foi realizada manualmente.

### 8.1. Comando

```bat
"E:\Program Files\Windows Kits\10\bin\10.0.28000.0\x86\signtool.exe" sign /ph /fd SHA256 /sha1 "6D1416DE6C271502E48C6DFFBACB5669B0685716" "x64\Debug\avshws.sys"
```

### 8.2. Resultado esperado

Mensagem de sucesso informando assinatura concluída.

---

## 9. Geração do catálogo do pacote (`.cat`)

A instalação do pacote via `INF` exige catálogo válido.

### 9.1. Geração do catálogo

```bat
"E:\Program Files\Windows Kits\10\bin\10.0.28000.0\x86\Inf2Cat.exe" /driver:"D:\Documentos\GoogleDrive\camera-fake\VirtualCameraDriver\Driver\avshws\x64\Debug" /os:10_X64
```

### 9.2. Resultado esperado

Geração do arquivo:
A geração do catálogo pode produzir x64\Debug\avshws.cat e x64\Debug\avshws\avshws.cat. Para assinatura, validação e instalação, deve-se utilizar como padrão o arquivo da pasta empacotada:
```text
x64\Debug\avshws\avshws.cat
```

A geração do catálogo foi concluída sem erros nem warnings.

---

## 10. Assinatura do catálogo

### 10.1. Comando

```bat
"E:\Program Files\Windows Kits\10\bin\10.0.28000.0\x86\signtool.exe" sign /fd SHA256 /sha1 "6D1416DE6C271502E48C6DFFBACB5669B0685716" "x64\Debug\avshws\avshws.cat"
```

### 10.2. Resultado esperado

Mensagem de sucesso informando assinatura concluída do catálogo.

### 10.3. Validação do catálogo assinado
A validação do catálogo deve ser realizada com a opção /pa, pois essa verificação confirmou corretamente a assinatura do pacote para fins de instalação PnP. A validação sem /pa pode acusar cadeia não confiável, mesmo quando o catálogo já está adequado ao processo de instalação test-signed.

```bat
"E:\Program Files\Windows Kits\10\bin\10.0.28000.0\x86\signtool.exe" verify /v /pa "x64\Debug\avshws\avshws.cat"
```

### 10.4. Exportação e confiança do certificado de teste
Durante os testes, foi necessário garantir explicitamente a confiança do certificado utilizado na assinatura. O certificado WDKTestCert..., identificado pelo thumbprint 6D1416DE6C271502E48C6DFFBACB5669B0685716, foi localizado no repositório pessoal do usuário, exportado para arquivo .cer e confirmado nos repositórios de confiança pertinentes.

```bat
certutil -user -store my 6D1416DE6C271502E48C6DFFBACB5669B0685716
certutil -user -store my 6D1416DE6C271502E48C6DFFBACB5669B0685716 WDKTestCert.cer
certutil -addstore "Root" WDKTestCert.cer
certutil -addstore "TrustedPublisher" WDKTestCert.cer
certutil -user -addstore "Root" WDKTestCert.cer
```


---

## 11. Ajuste recomendado no INF

Durante a validação do INF, foi emitido aviso recomendando a inclusão de `PnpLockdown=1` na seção `[Version]`. Esse item não bloqueou o processo, mas deve ser mantido como melhoria de conformidade. 

### Ajuste recomendado

Na seção `[Version]` do `x64\Debug\avshws\avshws.inf e avshws.inf`, incluir:

```ini
PnpLockdown=1
```

---

## 12. Adição do pacote ao Driver Store

### 12.1. Comando

```bat
pnputil /add-driver "x64\Debug\avshws\avshws.inf" /install
```

### 12.2. Resultado obtido

O pacote foi adicionado com sucesso ao sistema, recebendo nome publicado (`oem141.inf`). Em uma das tentativas, foi informado que o pacote foi adicionado com sucesso, porém inicialmente instalado em `0 dispositivo(s)`, comportamento compatível com ausência de correspondência automática de dispositivo presente. Posteriormente, o pacote foi aceito pelo sistema.

---

## 13. Evidências de sucesso parcial

Até o estágio atual, foram obtidas as seguintes evidências objetivas:

* compilação concluída com geração de `avshws.sys`; 
* assinatura manual do `.sys` concluída com sucesso;
* geração do `avshws.cat` via `Inf2Cat` sem erros;
* assinatura manual do `avshws.cat` concluída com sucesso;
* pacote aceito pelo `pnputil` e adicionado ao Driver Store.

---
## 14. Sequência resumida de reprodução

### 14.1. Ajustar o projeto

1. desabilitar warning `4996` no `.vcxproj`;
2. neutralizar os targets:

   * `DriverTestSign`
   * `TestSign`
   * `RemoveUnsignedOutput`

### 14.2. Compilar

```bat
msbuild avshws.vcxproj /t:Clean;Build /p:Configuration=Debug /p:Platform=x64
```

### 14.3. Assinar o `.sys`

```bat
"E:\Program Files\Windows Kits\10\bin\10.0.28000.0\x86\signtool.exe" sign /ph /fd SHA256 /sha1 "6D1416DE6C271502E48C6DFFBACB5669B0685716" "x64\Debug\avshws.sys"
```

### 14.4. Gerar o catálogo

```bat
"E:\Program Files\Windows Kits\10\bin\10.0.28000.0\x86\Inf2Cat.exe" /driver:"D:\Documentos\GoogleDrive\camera-fake\VirtualCameraDriver\Driver\avshws\x64\Debug" /os:10_X64
```

### 14.5. Assinar o catálogo

```bat
"E:\Program Files\Windows Kits\10\bin\10.0.28000.0\x86\signtool.exe" sign /fd SHA256 /sha1 "6D1416DE6C271502E48C6DFFBACB5669B0685716" "x64\Debug\avshws\avshws.cat"
```

### 14.6. Instalar o pacote

```bat
pnputil /add-driver "x64\Debug\avshws\avshws.inf" /install
```

### 14.7. Validar políticas de segurança do Windows

* Confirmar se o Windows está em modo de teste:
```bat
bcdedit /enum
```
Verificar se a entrada abaixo está presente no carregador atual do Windows:
```bat
testsigning             Yes
```
Caso não esteja habilitado, executar em prompt com privilégio administrativo:
```bat
bcdedit /set testsigning on
```
e reiniciar o sistema.
* Confirmar a confiança do certificado de teste:
```bat
certutil -user -store my 6D1416DE6C271502E48C6DFFBACB5669B0685716
certutil -user -store my 6D1416DE6C271502E48C6DFFBACB5669B0685716 WDKTestCert.cer
certutil -addstore "Root" WDKTestCert.cer
certutil -addstore "TrustedPublisher" WDKTestCert.cer
certutil -user -addstore "Root" WDKTestCert.cer
```
* Validar o catálogo assinado para instalação PnP:
```bat
"E:\Program Files\Windows Kits\10\bin\10.0.28000.0\x86\signtool.exe" verify /v /pa "x64\Debug\avshws\avshws.cat"
```
* Confirmar pré-condições do sistema:
** Secure Boot desativado;
** testsigning habilitado;
** certificado de teste confiado;
** catálogo validado com sucesso por /pa.

### 14.8. Desabilitar Integridade da memória e reiniciar

* acessar Segurança do Windows > Segurança do dispositivo > Isolamento de núcleo;
* desabilitar Integridade da memória;
* reiniciar o Windows antes de testar novamente o dispositivo.

### 14.9. Instalar/testar o hardware

* instalar o dispositivo;
* validar se o driver é carregado sem Código 52.

---

## 15. Conclusão

O procedimento foi validado de ponta a ponta, incluindo:

* compilação do driver em x64;
* geração do binário .sys;
* geração e assinatura do catálogo .cat;
* validação do catálogo para instalação PnP;
* configuração de confiança do certificado de teste;
* instalação do pacote no Windows;
* liberação do carregamento do driver após desabilitação da Integridade da memória e reinicialização do sistema.

Assim, o processo passou a ser reproduzível não apenas até a instalação do pacote, mas também até o carregamento efetivo do driver no ambiente testado.

