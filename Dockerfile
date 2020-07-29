FROM debian:buster-slim as cardano_haskell_builder
ARG CARDANO_CLI_VERSION=1.18.0
ARG CARDANO_NODE_REPO_TAG=42f17e5cb3050e489b7e7c879d1af809cedacf62
WORKDIR /build
RUN apt-get update && apt-get install -yq \
    build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsodium-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5
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
RUN ./configure
RUN make install
WORKDIR /app
RUN git clone https://github.com/input-output-hk/cardano-node.git && \
    cd cardano-node && \
    git fetch --all --tags && \
    git checkout ${CARDANO_NODE_REPO_TAG}
WORKDIR /app/cardano-node
COPY config/cabal.project.local .
RUN cabal build cardano-cli && \
    mv ./dist-newstyle/build/x86_64-linux/ghc-8.6.5/cardano-cli-${CARDANO_CLI_VERSION}/x/cardano-cli/build/cardano-cli/cardano-cli /usr/local/bin/

FROM debian:buster-slim
COPY --from=cardano_haskell_builder /usr/lib /usr/lib
COPY --from=cardano_haskell_builder /etc /etc
COPY --from=cardano_haskell_builder /usr/local/bin/cardano-cli /usr/local/bin/cardano-cli
ENTRYPOINT ["cardano-cli"]
