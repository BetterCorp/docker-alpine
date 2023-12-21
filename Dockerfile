ARG ALPINE_VERSION=latest
FROM alpine:${ALPINE_VERSION} AS builder

ENV GOSU_VERSION 1.17

RUN apk add --no-cache ca-certificates dpkg gnupg && \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" && \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" && \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu && \
    command -v gpgconf && gpgconf --kill all || : && \
    rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu

# Second stage: copy only the gosu binary from the first stage
FROM alpine:${ALPINE_VERSION}

COPY --from=builder /usr/local/bin/gosu /usr/local/bin/gosu

# Verify that the binary works
RUN gosu --version && \
    gosu nobody true
