# TOTVS Fluig - Docker DEV

Este repositório contém a infraestrutura como código (Dockerfile e scripts associados) para criar uma imagem Docker base contendo a instalação automatizada da plataforma **TOTVS Fluig**.

## 📋 Arquitetura e Componentes

- **Sistema Operacional Base:** Ubuntu 24.04
- **Banco de Dados Suportado:** MySQL (Driver JDBC `mysql-connector-j` 9.6.0 pré-instalado).
- **Java:** Utiliza a versão empacotada localmente do Java (`jdk-64`) para compatibilidade e execução do instalador.
- **Instalação Dinâmica:** O uso do utilitário `envsubst` permite injetar variáveis de ambiente no arquivo de respostas de instalação (`install.conf.template`), viabilizando a automação (silent install).
- **Serviços Opcionais:** Suporte condicional à instalação do Node.js para o Fluig RealTime.

## 🚀 Pré-requisitos

Antes de realizar o build desta imagem, certifique-se de ter:

1. **Docker** instalado em sua máquina.
2. Os artefatos do instalador do Fluig posicionados na pasta raiz ou diretório esperado:
   - `installer/fluig-installer.jar`
   - Diretório `installer/jdk-64/`

   > **Observação:** Caso o diretório `installer` esteja vazio ou o arquivo `fluig-installer.jar` não seja encontrado, o processo de build fará automaticamente o download do instalador a partir do site oficial da TOTVS (FLUIG 2.0.0-260609).
3. O arquivo de template de instalação: `config/install.conf.template` configurado adequadamente com variáveis de ambiente padrão.
4. (Opcional) Um script `start-fluig` presente no `PATH` do container (ou copiado junto com os arquivos no Dockerfile), pois ele atua como o entrypoint da aplicação.

## 🛠️ Como fazer o Build

Você pode construir a imagem passando as variáveis de ambiente necessárias que serão interceptadas pelo template de instalação.

No diretório base do projeto (onde está localizado o `Dockerfile`), execute:

```bash
docker build -t fluig-base:latest .
```

> **Nota:** Caso o `install.conf.template` dependa de variáveis (ex: `$DB_HOST`, `$DB_USER`, `$DB_PASS`), certifique-se de passá-las como `ARG` e `ENV` no Dockerfile, ou utilizar o `--build-arg` conforme aplicável.

## 🎛️ Variáveis de Ambiente

O projeto utiliza um arquivo `.env` para gerenciar as configurações. As principais variáveis são:

- **Configurações de Banco de Dados:** `FLUIG_DB_HOST`, `FLUIG_DB_PORT`, `FLUIG_DB_NAME`, `FLUIG_DB_USER`, `FLUIG_DB_PASS`.
- **Memória da JVM:** 
  - `JAVA_XMS`: Memória inicial alocada (ex: `2g`)
  - `JAVA_XMX`: Memória máxima permitida (ex: `4g`)
- **License Server:** `LS_HOST` e `LS_PORT` (ex: `5555`) para conexão com o servidor de licenças da TOTVS.
- **Serviços Adicionais:**
  - `INSTALL_NODE`: Se `true`, instala e configura o Node.js para o serviço Fluig RealTime.
  - `INSTALL_SOLR`: Se `true`, prepara o ambiente para o serviço Apache Solr.
- **Fuso Horário:** `TZ` (ex: `America/Sao_Paulo`) para garantir a data/hora correta nos logs e agendamentos.

**Exemplo de arquivo `.env`:**
```env
FLUIG_DB_HOST=meu-mysql-server
FLUIG_DB_PORT=3306
FLUIG_DB_NAME=fluig
FLUIG_DB_USER=fluiguser
FLUIG_DB_PASS=senha123
JAVA_XMS=2g
JAVA_XMX=4g
LS_HOST=192.168.0.100
LS_PORT=5555
INSTALL_NODE=true
INSTALL_SOLR=false
TZ=America/Sao_Paulo
```

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
  --env-file .env \
  -v fluig_volume:/opt/fluig-volume \
  fluig-base:latest
```

> **Atenção:** O fluig consome bastante memória RAM. Recomenda-se ajustar as configurações de memória da JVM no JBoss/Wildfly ou garantir que o Host possua pelo menos 8GB a 16GB de RAM livres para o container.

### 💾 Persistência de Dados (Volumes)

O Fluig armazena arquivos físicos de documentos e artefatos. É **fundamental** mapear volumes para garantir que os dados não sejam perdidos caso o container seja destruído ou atualizado.

O diretório criado e configurado dentro do container para armazenar o **Volume do Fluig** (arquivos físicos de documentos) é o `/opt/fluig-volume`. No comando de execução acima, o volume Docker `fluig_volume` está sendo montado na (`/opt/fluig-volume`), o que já protege todos os dados do volume e configurações.

Certifique-se de que o **Volume de Documentos** definido durante a instalação (no `install.conf.template`) aponte corretamente para este caminho persistido.

### 🌐 Acesso à Aplicação

Devido à complexidade do TOTVS Fluig, o servidor pode levar alguns minutos (dependendo do hardware) para iniciar todos os serviços e estar pronto para receber requisições após o comando `docker run`.

Quando a inicialização for concluída, acesse a plataforma pelo navegador:
```text
http://localhost:8080
```
*(Substitua `localhost` pelo IP do seu Docker Host, se estiver acessando de outra máquina).*

### 🕵️ Logs e Troubleshooting

Para acompanhar o processo de inicialização, identificar se a aplicação já subiu ou debugar possíveis erros de conexão com o banco de dados, utilize o comando de logs do Docker:
```bash
docker logs -f fluig-server
```

## 📁 Estrutura de Diretórios Esperada (Contexto do Docker)

```text
.
├── docker-compose.yml
├── .env
└── setup/
    ├── Dockerfile
    ├── start-fluig.sh               # Entrypoint script
    ├── config/
    │   └── install.conf.template    # Arquivo modelo com as variáveis
    └── installer/
        ├── fluig-installer.jar      # Executável do instalador
        └── jdk-64/                  # JDK base utilizado pelo instalador
```

## 📝 Customização

Sinta-se à vontade para estender esta imagem modificando o arquivo `install.conf.template` para suportar diferentes bancos de dados (ex: SQL Server, Oracle) ou alterar os parâmetros de performance (heaps do Java) nativos no `standalone.xml`.