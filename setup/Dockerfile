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
ARG LS_HOST
ARG LS_PORT
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
ENV LS_HOST=$LS_HOST
ENV LS_PORT=$LS_PORT

WORKDIR /opt/fluig

# Copia o script da pasta local para dentro do container
COPY --chmod=755 ./start-fluig.sh /usr/local/bin/start-fluig

# Instala dependências
RUN apt-get update && \
    apt-get install -y \
    curl \
    unzip \
    tzdata \
    fontconfig \
    gettext-base \
    wget \
    vim \
    libfreetype6 \
    ca-certificates \
    openjdk-11-jdk \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && locale-gen pt_BR.UTF-8 \
    && apt-get clean

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

# Processa o template, instala o fluig e limpa os arquivos temporários em uma única camada para evitar deixar arquivos sensíveis no histórico do Docker. Também ajusta a configuração do WildFly para aceitar conexões de qualquer endereço e garante que o script de inicialização tenha permissão de execução.
RUN envsubst < /tmp/build/config/install.conf.template > /tmp/build/install.conf && \
    chmod -R +x /tmp/build/installer/ && \
    cd /tmp/build/installer && \
    chmod +x ./jdk-64/bin/java && \
    ./jdk-64/bin/java -cp fluig-installer.jar com.fluig.install.ExecuteInstall /tmp/build/install.conf > /tmp/install.log && \    
    sed -i 's#<inet-address .*#<any-address/>#g' /opt/fluig/appserver/standalone/configuration/standalone.xml && \
    cd /opt/fluig && \
    rm -rf /tmp/build
RUN echo "alias log='tail -f /opt/fluig/appserver/standalone/log/server.log'" >> /root/.bashrc;
# Configura os scripts de inicialização para o Fluig e RealTime, e garante que o Node.js tenha permissão de execução
RUN cd /opt/fluig/appserver/bin/service && \    
    cp wildfly-init-debian.sh /etc/init.d/fluig && \
    chmod -R +x /etc/init.d/fluig && \
    update-rc.d fluig defaults
    
RUN if [ "$INSTALL_NODE" = "true" ]; then \ 
        cd /opt/fluig/node && \
        cp fluig_RealTime /etc/init.d/fluig_RealTime && \
        chmod +x /etc/init.d/fluig_RealTime && \
        update-rc.d fluig_RealTime defaults && \
        chmod +x /opt/fluig/node/bin/node && \
        chmod +x /opt/fluig/node/bin/npm && \
        echo "Node.js instalado e configurado para iniciar com o sistema."; \
     else \
        echo "Node.js não será instalado. Pulando configuração de RealTime."; \
    fi

# Configura o diretório de volume para o Fluig
RUN mkdir -p /opt/fluig-volume && chmod 777 /opt/fluig-volume

CMD ["start-fluig"]