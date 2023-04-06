FROM alpine:3.15 AS builder

# args -- software versions
ARG PGBOUNCER_VERSION=1.18.0

# install -- pgbouncer build dependanices
RUN apk --no-cache add \
    autoconf \
    automake \
    c-ares-dev \
    ca-certificates \
    curl \
    g++ \
    gcc \
    libevent-dev \
    libtool \
    make \
    openssl-dev \
    pkgconfig

# install -- pgbouncer
RUN curl -sL "https://www.pgbouncer.org/downloads/files/${PGBOUNCER_VERSION}/pgbouncer-${PGBOUNCER_VERSION}.tar.gz" -o /tmp/pgbouncer.tar.gz \
 && curl -sL "https://www.pgbouncer.org/downloads/files/${PGBOUNCER_VERSION}/pgbouncer-${PGBOUNCER_VERSION}.tar.gz.sha256" -o /tmp/pgbouncer.tar.gz.sha256 \
 && echo "$(cat /tmp/pgbouncer.tar.gz.sha256 | awk '{ print $1; }')  /tmp/pgbouncer.tar.gz" | sha256sum -c - \
 && mkdir /tmp/pgbouncer \
 && tar -xzf /tmp/pgbouncer.tar.gz --strip-components 1 -C /tmp/pgbouncer \
 && cd /tmp/pgbouncer \
 && ./configure --prefix=/usr/local \
 && make \
 && make install

FROM alpine:3.15

# args -- uid/gid
ARG PGBOUNCER_USER=pgbouncer
ARG PGBOUNCER_GROUP=pgbouncer
ARG PGBOUNCER_UID=1001
ARG PGBOUNCER_GID=1001
ARG PGBOUNCER_HOME=/home/${PGBOUNCER_USER}

# install -- dumb-init
RUN apk --no-cache add \
    dumb-init

# install -- pgbouncer runtime dependanices
RUN apk --no-cache add \
    c-ares \
    ca-certificates \
    libevent \
    libressl

# install -- psql and python3 (used in k8s probes)
RUN apk --no-cache add \
    postgresql-client \
    python3

# install -- openssl (used in startup script to generate self-signed certs)
RUN apk --no-cache add \
    openssl

# install -- pgbouncer
COPY --from=builder /usr/local/bin/pgbouncer /usr/local/bin/pgbouncer

# create non-root 'pgbouncer' user/group
RUN addgroup -g ${PGBOUNCER_GID} "${PGBOUNCER_GROUP}" \
 && adduser -D -h "${PGBOUNCER_HOME}" -u ${PGBOUNCER_UID} -G ${PGBOUNCER_GROUP} "${PGBOUNCER_USER}"

USER ${PGBOUNCER_UID}:${PGBOUNCER_GID}
WORKDIR ${PGBOUNCER_HOME}

# copy a default pgbouncer.ini config
COPY pgbouncer.ini .

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["pgbouncer", "./pgbouncer.ini"]