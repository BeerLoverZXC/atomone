FROM ubuntu:latest

ENV DAEMON_NAME=atomoned \
ATOMONE_CHAIN_ID="atomone-1" \
HOME=/app \
DAEMON_HOME=/app/.atomone \
DAEMON_ALLOW_DOWNLOAD_BINARIES=false \
DAEMON_RESTART_AFTER_UPGRADE=true \
GO_VER="1.22.3" \
PATH="/usr/local/go/bin:/app/go/bin:${PATH}" \
SEEDS="f19d9e0f8d48119aa4cafde65de923ae2c29181a@atomone-mainnet-seed.itrocket.net:61656" \
PEERS="ed0e36c57122184ab05b6c635b2f2adf592bfa0c@atomone-mainnet-peer.itrocket.net:61657,5d913650738a081aa02631a7f108dc7812330f0b@37.27.129.24:13656,706a835221dcc171afa14429fac536d6b5a3736d@63.250.54.71:26656,4ef48d2cc03b332f9a711fc65dc0453839f9040d@8.52.153.92:61656,752bb5f1c914c5294e0844ddc908548115c1052c@65.108.236.5:14556,6c4b686add2ae26aad617a15e4db012e7496eee1@154.91.1.108:26656,d3adcf9eee8665ee2d3108f721b3613cdd18c3a3@23.227.223.49:26656,8391dab9a9ece4e3f80e06512bdd1a84af5f257f@95.217.36.103:14556,61b7861a468dfa84532526afd98bea81bf41a874@121.78.247.244:16656,42c384bdf78ea2a2e7fc0c4e1716ef94951fca16@95.214.52.233:36656,37201c92625df2814a55129f73f10ab6aa2edc35@185.16.39.137:27396"

WORKDIR /app

RUN apt-get update && apt-get upgrade -y && \
    apt-get install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y

RUN wget "https://golang.org/dl/go$GO_VER.linux-amd64.tar.gz" && \
    tar -C /usr/local -xzf "go$GO_VER.linux-amd64.tar.gz" && \
    rm "go$GO_VER.linux-amd64.tar.gz" && \
    mkdir -p /app/go/bin && \
    mkdir -p /app/.atomone/cosmovisor/genesis/bin && \
    mkdir -p /app/.atomone/cosmovisor/upgrades

RUN cd $HOME && \
    git clone https://github.com/atomone-hub/atomone && \
    cd atomone && \
    git checkout v1.0.1 && \
    make install && \
    mv /app/go/bin/atomoned /app/.atomone/cosmovisor/genesis/bin/atomoned && \
    chmod +x /app/.atomone/cosmovisor/genesis/bin/atomoned

RUN go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@latest

RUN /app/.atomone/cosmovisor/genesis/bin/atomoned init "Shadow Sakura" --chain-id $ATOMONE_CHAIN_ID

RUN wget -O $HOME/.atomone/config/genesis.json https://server-7.itrocket.net/mainnet/atomone/genesis.json && \
wget -O $HOME/.atomone/config/addrbook.json  https://server-7.itrocket.net/mainnet/atomone/addrbook.json

ENTRYPOINT ["/app/entrypoint.sh"]
