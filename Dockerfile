FROM debian:buster-slim as builder
ARG CARDANO_CLI_VERSION=1.19.0
ARG CARDANO_NODE_REPO_TAG=4814003f14340d5a1fc02f3ac15437387a7ada9f
RUN apt-get update && apt-get install -y \
    build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf
WORKDIR /app/cabal
RUN wget https://downloads.haskell.org/~cabal/cabal-install-3.2.0.0/cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz && \
    tar -xf cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz && \
    rm cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz cabal.sig && \
    mv cabal /usr/local/bin/
RUN cabal update
WORKDIR /app/ghc
RUN wget https://downloads.haskell.org/~ghc/8.6.5/ghc-8.6.5-x86_64-deb9-linux.tar.xz && \
    tar -xf ghc-8.6.5-x86_64-deb9-linux.tar.xz && \
    rm ghc-8.6.5-x86_64-deb9-linux.tar.xz
WORKDIR /app/ghc/ghc-8.6.5
RUN ./configure && make install
WORKDIR /app/libsodium
RUN git clone https://github.com/input-output-hk/libsodium . && \
    git checkout 66f017f1 && \
    ./autogen.sh && \
    ./configure && \
    make && make install
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"
WORKDIR /app/cardano-node
RUN git clone https://github.com/input-output-hk/cardano-node.git . && \
    git checkout ${CARDANO_NODE_REPO_TAG}
RUN cabal build cardano-cli && \
    mv ./dist-newstyle/build/x86_64-linux/ghc-8.6.5/cardano-cli-${CARDANO_CLI_VERSION}/x/cardano-cli/build/cardano-cli/cardano-cli /usr/local/bin/
RUN cardano-cli --version

FROM debian:buster-slim
COPY --from=builder /usr/lib /usr/lib
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /etc /etc
COPY --from=builder /usr/local/bin/cardano-cli /usr/local/bin/cardano-cli
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
ENV CARDANO_NODE_SOCKET_PATH=/node-ipc/node.socket
ENTRYPOINT ["cardano-cli"]
CMD [ "--help" ]
