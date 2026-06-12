FROM ubuntu:24.04

ARG TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /opt/fluig

# Instala dependências
RUN apt-get update && apt-get install -y --no-install-recommends \
    fontconfig unzip curl wget vim gettext-base \
    && rm -rf /var/lib/apt/lists/*

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