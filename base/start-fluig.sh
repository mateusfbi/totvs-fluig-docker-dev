#!/usr/bin/env bash

# Define o caminho do log do Fluig
LOG_FILE="/opt/fluig/appserver/standalone/log/server.log"

# 1. Função para capturar o desligamento do container e parar os serviços de forma segura
graceful_shutdown() {
    echo "=========================================================="
    echo "Recebido sinal de parada (SIGTERM/SIGINT) do Docker."
    echo "Iniciando o desligamento seguro do Fluig..."
    echo "=========================================================="
    
    service fluig stop
    service fluig_Indexer stop
    service fluig_RealTime stop
    
    echo "Fluig encerrado com sucesso. Parando o container."
    exit 0
}

# Registra os sinais (quando executar 'docker stop' ou 'Ctrl+C')
trap 'graceful_shutdown' SIGTERM SIGINT

# 2. Inicia os serviços 
echo "Iniciando os serviços do TOTVS Fluig..."
service fluig_RealTime start
service fluig_Indexer start
service fluig start

# 3. Aguarda a criação do arquivo de log do JBoss/Wildfly
echo "Aguardando a inicialização do arquivo de log ($LOG_FILE)..."
while [ ! -f "$LOG_FILE" ]; do
    sleep 2
done

echo "Log do servidor encontrado! Redirecionando a saída para o Docker:"
echo "-----------------------------------------------------------------"

# 4. Faz o rastreio do arquivo de log de forma contínua
tail -f "$LOG_FILE" &
TAIL_PID=$!

# Aguarda indefinidamente o processo do tail, mantendo o container vivo e esperando o trap
wait $TAIL_PID
