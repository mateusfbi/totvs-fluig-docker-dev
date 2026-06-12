FROM ubuntu:24.04

ENV FLUIG_URL="https://download.totvs.com/DownloadCentral/DownloadCentral?file=%2FFTPTOTVSTECNOLOGIA%2FTECNOLOGIA%2FMIDIA%2FFLUIG%2FFLUIG-2.0.0-260609-LINUX64.ZIP&bro=true"
ENV DEBIAN_FRONTEND=noninteractive
# Exporte-os para que o envsubst os veja
ARG TZ
ARG INSTALL_NODE
ARG INSTALL_SOLR
ARG JAVA_XMS
ARG JAVA_XMX
ARG FLUIG_DB_USER
ARG FLUIG_DB_PASS
ARG FLUIG_DB_HOST
ARG FLUIG_DB_PORT
ARG FLUIG_DB_NAME
# 2. Transfere os valores de ARG para ENV para o envsubst conseguir ler
ENV TZ=$TZ
ENV INSTALL_NODE=$INSTALL_NODE
ENV INSTALL_SOLR=$INSTALL_SOLR
ENV JAVA_XMS=$JAVA_XMS
ENV JAVA_XMX=$JAVA_XMX
ENV FLUIG_DB_USER=$FLUIG_DB_USER
ENV FLUIG_DB_PASS=$FLUIG_DB_PASS
ENV FLUIG_DB_HOST=$FLUIG_DB_HOST
ENV FLUIG_DB_PORT=$FLUIG_DB_PORT
ENV FLUIG_DB_NAME=$FLUIG_DB_NAME

WORKDIR /opt/fluig

# Instala dependências
RUN apt-get update && \
    apt-get install -y \
    curl \
    unzip \
    tzdata \
    wget \
    fontconfig \
    libfreetype6 \
    ca-certificates \
    openjdk-11-jdk \
    gettext-base \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Instala MySQL Connector
RUN wget --no-check-certificate --user-agent="Mozilla/5.0" \
    https://downloads.mysql.com/archives/get/p/3/file/mysql-connector-j_9.6.0-1ubuntu24.04_all.deb \
    -O /tmp/mysql-connector.deb && \
    dpkg -i /tmp/mysql-connector.deb && \
    rm /tmp/mysql-connector.deb

# Copia o contexto atual (config, installer, etc) para um diretório de build
COPY . /tmp/build

# Verifica se o fluig-installer.jar existe na pasta copiada. Caso não, faz o download.
RUN if [ ! -f "/tmp/build/installer/fluig-installer.jar" ]; then \
        echo "Instalador local não encontrado. Baixando da URL..." && \
        mkdir -p /tmp/build/installer && \
        curl -k -A "Mozilla/5.0" -L "${FLUIG_URL}" -o /tmp/build/fluig.zip && \
        unzip -q /tmp/build/fluig.zip -d /tmp/build/installer && \
        rm /tmp/build/fluig.zip; \
    else \
        echo "Instalador local encontrado! Pulando o download."; \
    fi

# Processa o template usando o caminho correto
RUN envsubst < /tmp/build/config/install.conf.template > /tmp/build/install.conf

# Instalação do Fluig usando os arquivos em /tmp/build/installer
RUN cd /tmp/build/installer && \
    chmod +x ./jdk-64/bin/java && \
    ./jdk-64/bin/java -cp fluig-installer.jar com.fluig.install.ExecuteInstall /tmp/build/install.conf && \
    sed -i 's#<inet-address .*#<any-address/>#g' /opt/fluig/appserver/standalone/configuration/standalone.xml && \
    cd /opt/fluig && \
    rm -rf /tmp/build

ENTRYPOINT ["start-fluig"]