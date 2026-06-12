FROM ubuntu:24.04

ARG TZ=UTC
ARG FLUIG_URL="https://download.totvs.com/DownloadCentral/DownloadCentral?file=%2FFTPTOTVSTECNOLOGIA%2FTECNOLOGIA%2FMIDIA%2FFLUIG%2FFLUIG-2.0.0-260609-LINUX64.ZIP&bro=true"
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /opt/fluig

# Instala dependências
RUN apt-get update && apt-get install -y --no-install-recommends \
    fontconfig unzip curl wget vim gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Cria a estrutura e baixa o instalador
RUN mkdir -p /tmp/build && \
    curl -L "${FLUIG_URL}" -o /tmp/fluig.zip && \
    unzip -q /tmp/fluig.zip -d /tmp/build && \
    rm /tmp/fluig.zip

# Copia seus arquivos de configuração (install.conf.template) do seu PC para dentro
COPY ./config/install.conf.template /tmp/build/config/install.conf.template

# Processa o template
RUN envsubst < /tmp/build/config/install.conf.template > /tmp/build/install.conf

# Instalação do Fluig
RUN cd /tmp/build && \
    chmod +x ./jdk-64/bin/java && \
    ./jdk-64/bin/java -cp fluig-installer.jar com.fluig.install.ExecuteInstall /tmp/build/install.conf && \
    rm -rf /tmp/build

# Instala MySQL Connector
RUN wget --no-check-certificate --user-agent="Mozilla/5.0" \
    https://downloads.mysql.com/archives/get/p/3/file/mysql-connector-j_9.6.0-1ubuntu24.04_all.deb \
    -O /tmp/mysql-connector.deb && \
    dpkg -i /tmp/mysql-connector.deb && \
    rm /tmp/mysql-connector.deb

# Copia apenas o necessário para um diretório de build
COPY . /tmp/build

# Processa o template usando o caminho correto
RUN envsubst < /tmp/build/config/install.conf.template > /tmp/build/install.conf

# Instalação do Fluig (ajustado para o novo caminho)
RUN cd /tmp/build && \
    chmod +x ./jdk-64/bin/java && \
    ./jdk-64/bin/java -cp fluig-installer.jar com.fluig.install.ExecuteInstall /tmp/build/install.conf && \
    sed -i 's#<inet-address .*#<any-address/>#g' /opt/fluig/appserver/standalone/configuration/standalone.xml && \
    rm -rf /tmp/build

ENTRYPOINT ["start-fluig"]