FROM ubuntu:16.04
RUN groupadd --system --gid 19000 parity \
	&& useradd --system --uid 19000 --create-home --gid parity parity
RUN set -ex \
	&& apt-get update \
#	&& apt-get install -qq ca-certificates dirmngr supervisor python-requests gpgv git wget openssl \
	&& apt-get install -qq ca-certificates \
	&& rm -rf /var/lib/apt/lists/*
ARG PARITY_VERSION=stable-release
ENV PARITY_VERSION=$PARITY_VERSION
ENV DEPS_FOR_BUILDING g++ build-essential curl git file libssl-dev pkg-config libudev-dev
RUN { set -ex; \
    # install deps
    apt-get update; \
    apt-get install --no-install-recommends -y $DEPS_FOR_BUILDING; \
    ####################### DAEMON ###################################################
    curl https://sh.rustup.rs -sSf | sh -s -- -y; \
    export PATH=/root/.cargo/bin:${PATH}; \
	# show tool versions
	rustc -vV; \
	cargo -V; \
	gcc -v; \
	g++ -v; \
	# download
    git clone https://github.com/paritytech/parity /tmp/parity --depth 1 --branch $PARITY_VERSION; \
    cd /tmp/parity; \
    git checkout $PARITY_VERSION; \
    # build & install
    export RUST_BACKTRACE=1; \
    cargo build --release --features final --verbose; \
    mv target/release/parity /usr/bin; \
    rm -rf /root/.cargo /root/.rustup; \
    ########################## CLEAN UP ################################################
    apt-get remove -y $DEPS_FOR_BUILDING; \
    apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
}
#RUN { set -ex; \
#    mkdir /default; \
#    mkdir /data; chown -R parity:parity /data; \
#    mkdir /secrets; chown -R parity:parity /secrets; \
#    mkdir /config; \
#    mkdir /logs; \
#}
#VOLUME ["/data", "/secrets", "/config", "/logs"]
#ENV PARITY_OPTIONS=
#COPY conf/* /default/
# supervisor
#RUN { set -ex; \
#    git clone https://github.com/chainstorage/CCUnRPC.git /usr/lib/python2.7/dist-packages/ccunrpc/; \
#    mkdir -p /var/run; \
#}
#COPY ep_lib.sh /ep_lib.sh
#COPY entrypoint.sh /entrypoint.sh
#ENTRYPOINT ["/entrypoint.sh"]
ENTRYPOINT ["parity"]
EXPOSE 8080 8545 8180
