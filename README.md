# TOTVS Fluig - Docker Base Image

Este repositório contém a infraestrutura como código (Dockerfile e scripts associados) para criar uma imagem Docker base contendo a instalação automatizada da plataforma **TOTVS Fluig**.

## 📋 Arquitetura e Componentes

- **Sistema Operacional Base:** Ubuntu 24.04
- **Banco de Dados Suportado:** MySQL (Driver JDBC `mysql-connector-j` 9.6.0 pré-instalado).
- **Java:** Utiliza a versão empacotada localmente do Java (`jdk-64`) para compatibilidade e execução do instalador.
- **Instalação Dinâmica:** O uso do utilitário `envsubst` permite injetar variáveis de ambiente no arquivo de respostas de instalação (`install.conf.template`), viabilizando a automação (silent install).

## 🚀 Pré-requisitos

Antes de realizar o build desta imagem, certifique-se de ter:

1. **Docker** instalado em sua máquina.
2. Os artefatos do instalador do Fluig posicionados na pasta raiz ou diretório esperado:
   - `installer/fluig-installer.jar`
   - Diretório `installer/jdk-64/`
3. O arquivo de template de instalação: `config/install.conf.template` configurado adequadamente com variáveis de ambiente padrão.
4. (Opcional) Um script `start-fluig` presente no `PATH` do container (ou copiado junto com os arquivos no Dockerfile), pois ele atua como o entrypoint da aplicação.

## 🛠️ Como fazer o Build

Você pode construir a imagem passando as variáveis de ambiente necessárias que serão interceptadas pelo template de instalação.

No diretório base do projeto (onde está localizado o `Dockerfile`), execute:

```bash
docker build -t fluig-base:latest .
```

> **Nota:** Caso o `install.conf.template` dependa de variáveis (ex: `$DB_HOST`, `$DB_USER`, `$DB_PASS`), certifique-se de passá-las como `ARG` e `ENV` no Dockerfile, ou utilizar o `--build-arg` conforme aplicável.

## ⚙️ Configurações Importantes Internas

O `Dockerfile` aplica as seguintes modificações após o processo padrão de instalação do Fluig:

- **Liberação de Rede (`standalone.xml`):** O servidor de aplicação nativo é reconfigurado para escutar em todos os endereços IP disponíveis (`<any-address/>`), no lugar de travar no localhost (`127.0.0.1`), permitindo o acesso à plataforma a partir do host do Docker ou por outros containers.
- **Limpeza:** A pasta `/var/fluig` que continha os artefatos de instalação é removida ao final do processo para manter o tamanho final da imagem reduzido e otimizado.

## ▶️ Como Executar

Após criar a imagem base, você poderá rodar a plataforma Fluig. Por padrão, a aplicação deverá escutar as portas 8080 (HTTP) e adicionais que podem variar da sua instalação.

```bash
docker run -d \
  --name fluig-server \
  -p 8080:8080 \
  -v fluig_volume:/opt/fluig \
  fluig-base:latest
```

> **Atenção:** O fluig consome bastante memória RAM. Recomenda-se ajustar as configurações de memória da JVM no JBoss/Wildfly ou garantir que o Host possua pelo menos 8GB a 16GB de RAM livres para o container.

## 📁 Estrutura de Diretórios Esperada (Contexto do Docker)

```text
.
├── Dockerfile
├── config/
│   └── install.conf.template    # Arquivo modelo com as variáveis
├── installer/
│   ├── fluig-installer.jar      # Executável do instalador
│   └── jdk-64/                  # JDK base utilizado pelo instalador
└── start-fluig                  # Entrypoint script (exemplo)
```

## 📝 Customização

Sinta-se à vontade para estender esta imagem modificando o arquivo `install.conf.template` para suportar diferentes bancos de dados (ex: SQL Server, Oracle) ou alterar os parâmetros de performance (heaps do Java) nativos no `standalone.xml`.