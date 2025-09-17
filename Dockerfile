FROM ubuntu:noble-20250910

LABEL org.opencontainers.image.url="https://github.com/misotolar/docker-signopad-server"
LABEL org.opencontainers.image.description="signotec signoPAD-API/Web server image"
LABEL org.opencontainers.image.authors="Michal Sotolar <michal@sotolar.com>"

ENV SIGNOPAD_VERSION=3.4.0
ARG SIGNOPAD_SHA256=5340b5847ef03dafe4c19afb6905962c7c3b2087e20a5ff5acd8250737da0b2b
ARG SIGNOPAD_URL=https://downloads.signotec.com/signoPAD-API_Web/signoPAD-API_Web_Linux_$SIGNOPAD_VERSION.zip

ENV SIGNOPAD_ADDRESS=127.0.0.1
ENV SIGNOPAD_PORT=49494

ENV DEBIAN_FRONTEND=noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
ENV LD_LIBRARY_PATH=/usr/local/signoPAD:/usr/lib:/lib

WORKDIR /usr/local/signoPAD

RUN set -ex; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        unzip \
        \
        libtiff6 \
        libjpeg-turbo8 \
        libpangocairo-1.0-0 \
        libpng16-16t64 \
        libusb-1.0-0 \
    ; \
    curl -fsSL -o /tmp/signoPAD.zip $SIGNOPAD_URL; \
    echo "$SIGNOPAD_SHA256 */tmp/signoPAD.zip" | sha256sum -c -; \
    unzip \
        -j /tmp/signoPAD.zip \
        -d /usr/local/signoPAD \
        STPadServer/libSTCPImageEngine.so \
        STPadServer/libSTPadLib.so \
        STPadServer/STPadServer \
        STPadServer/STPad.ini \
    ; \
    chmod 755 /usr/local/signoPAD/STPadServer; \
    ln -s /usr/lib/x86_64-linux-gnu/libtiff.so.6 /usr/lib/x86_64-linux-gnu/libtiff.so.5; \
    apt-get remove --purge -y \
        ca-certificates \
        curl \
        unzip \
    ; \
    apt-get autoremove --purge -y; \
    apt-get clean autoclean -y; \
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

COPY resources/entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
CMD ["/usr/local/signoPAD/STPadServer"]
