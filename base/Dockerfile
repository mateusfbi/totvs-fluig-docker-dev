FROM ubuntu:24.04

ARG TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /opt/fluig

# Instala dependências e o envsubst (via gettext-base)
RUN apt-get update && apt-get install -y --no-install-recommends \
    fontconfig unzip curl wget vim gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Instala MySQL Connector
RUN wget -q https://downloads.mysql.com/archives/get/p/3/file/mysql-connector-j_9.6.0-1ubuntu24.04_all.deb -O /tmp/mysql-connector.deb \
    && dpkg -i /tmp/mysql-connector.deb && rm /tmp/mysql-connector.deb

COPY . /var/fluig

# Processa o template do install.conf dinamicamente
RUN envsubst < /var/fluig/config/install.conf.template > /var/fluig/install.conf

# Instalação do Fluig
RUN cd /var/fluig/installer && \
    chmod +x ./jdk-64/bin/java && \
    ./jdk-64/bin/java -cp fluig-installer.jar com.fluig.install.ExecuteInstall /var/fluig/install.conf && \
    sed -i 's#<inet-address .*#<any-address/>#g' /opt/fluig/appserver/standalone/configuration/standalone.xml && \
    rm -rf /var/fluig

ENTRYPOINT ["start-container"]
