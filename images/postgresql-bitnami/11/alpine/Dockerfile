# ================================================================
# REFERENCES:
# - https://github.com/bitnami/bitnami-docker-postgresql/blob/967cb8448edd4e5571a36cc65e45d96f630d6968/11/debian-11/Dockerfile
# - https://github.com/docker-library/postgres/blob/ba4abaac0739e6393a0ff3ecec2fa7b5ecb001a0/11/alpine/Dockerfile
# ================================================================

# ================================
# build `nss_wrapper` from source
# ================================
FROM alpine:3.16 as nss-wrapper-builder

# args -- software versions
ARG NSS_WRAPPER_VERSION=1.1.11

# install -- nss_wrapper build dependanices
RUN apk --no-cache add \
    bash \
    cmake \
    curl \
    g++ \
    gcc \
    gnupg \
    libc-dev \
    make \
    musl-nscd-dev

# build and install postgres
RUN curl -sSL "https://ftp.samba.org/pub/cwrap/nss_wrapper-${NSS_WRAPPER_VERSION}.tar.gz" -o /tmp/nss_wrapper.tar.gz \
 && curl -sSL "https://ftp.samba.org/pub/cwrap/nss_wrapper-${NSS_WRAPPER_VERSION}.tar.gz.asc" -o /tmp/nss_wrapper.tar.gz.asc \
 && gpg -q --keyserver keyserver.ubuntu.com --receive-keys 7EE0FC4DCC014E3D \
 && gpg -q --verify /tmp/nss_wrapper.tar.gz.asc /tmp/nss_wrapper.tar.gz \
 && rm /tmp/nss_wrapper.tar.gz.asc \
 && mkdir /tmp/nss_wrapper \
 && tar -xf /tmp/nss_wrapper.tar.gz -C /tmp/nss_wrapper --strip-components=1 \
 && rm /tmp/nss_wrapper.tar.gz \
 && cd /tmp/nss_wrapper \
 && mkdir obj \
 && cd obj \
 && cmake -DCMAKE_INSTALL_PREFIX=/opt/bitnami/common .. \
 && make \
 && make install

# ================================
# build `postgresql` from source
# ================================
FROM alpine:3.16 as postgres-builder

# args -- software versions
ARG PG_VERSION=11.16
# pgaudit versions 1.3.X are for postgres 11 (https://github.com/pgaudit/pgaudit#postgresql-version-compatibility)
ARG PGAUDIT_VERSION=1.3.4

# use "en_US.UTF-8" locale so postgres will be UTF-8 enabled by default
# NOTE: alpine doesn't require explicit locale-file generation
ENV LANG=en_US.UTF-8

# install -- postgres build dependanices
RUN apk --no-cache add \
    bash \
    bison \
    clang \
    coreutils \
    curl \
    dpkg-dev dpkg \
    flex \
    g++ \
    gcc \
    gettext \
    icu-dev \
    krb5-dev \
    libc-dev \
    libedit-dev \
    libxml2-dev \
    libxslt-dev \
    linux-headers \
    llvm-dev \
    make \
    musl-libintl \
    openldap-dev \
    openssl-dev \
    perl-dev \
    perl-ipc-run \
    perl-utils \
    python3-dev \
    tcl-dev \
    util-linux-dev \
    zlib-dev

# build and install postgres
RUN curl -sSL "https://ftp.postgresql.org/pub/source/v${PG_VERSION}/postgresql-${PG_VERSION}.tar.bz2" -o /tmp/postgresql.tar.bz2 \
 && curl -sSL "https://ftp.postgresql.org/pub/source/v${PG_VERSION}/postgresql-${PG_VERSION}.tar.bz2.sha256" -o /tmp/postgresql.tar.bz2.sha256 \
 && echo "$(cat /tmp/postgresql.tar.bz2.sha256 | awk '{ print $1; }') /tmp/postgresql.tar.bz2" | sha256sum --check \
 && rm /tmp/postgresql.tar.bz2.sha256 \
 && mkdir /tmp/postgresql \
 && tar -xf /tmp/postgresql.tar.bz2 -C /tmp/postgresql --strip-components=1 \
 && rm /tmp/postgresql.tar.bz2 \
 && cd /tmp/postgresql \
 # alpine seems to require all unix sockets be under `/var/run`, we set `DEFAULT_PGSOCKET_DIR` to work around this
 && sed -i -e 's|DEFAULT_PGSOCKET_DIR  "/tmp"|DEFAULT_PGSOCKET_DIR  "/var/run/postgresql"|g' src/include/pg_config_manual.h \
 && ./configure \
    --prefix=/opt/bitnami/postgresql \
    --enable-nls \
    --enable-integer-datetimes \
    --enable-thread-safety \
    --enable-tap-tests \
    --disable-rpath \
    --with-uuid=e2fs \
    --with-gnu-ld \
    --with-pgport=5432 \
    --with-system-tzdata=/usr/share/zoneinfo \
    --with-includes=/usr/local/include \
    --with-libraries=/usr/local/lib \
    --with-gssapi \
    --with-ldap \
    --with-tcl \
    --with-perl \
    --with-python \
    --with-openssl \
    --with-libxml \
    --with-libxslt \
    --with-icu \
    --with-llvm \
 && make -j "$(nproc)" world-bin \
 && make install-world-bin

# build and install pgAudit extension
RUN curl -sSL "https://github.com/pgaudit/pgaudit/archive/refs/tags/${PGAUDIT_VERSION}.tar.gz" -o /tmp/pgaudit.tar.gz \
 && mkdir /tmp/pgaudit \
 && tar -xf /tmp/pgaudit.tar.gz -C /tmp/pgaudit --strip-components=1 \
 && rm /tmp/pgaudit.tar.gz \
 && cd /tmp/pgaudit \
 && make install USE_PGXS=1 PG_CONFIG=/opt/bitnami/postgresql/bin/pg_config

# ================================
# a bitnami-like postgres image
# ================================
FROM alpine:3.16

# args -- uid/gid
ARG POSTGRES_USER=postgres
ARG POSTGRES_GROUP=postgres
ARG POSTGRES_UID=1001
ARG POSTGRES_GID=1001
ARG POSTGRES_HOME=/home/${POSTGRES_USER}

# use "en_US.UTF-8" locale so postgres will be UTF-8 enabled by default
# NOTE: alpine doesn't require explicit locale-file generation
ENV LANG=en_US.UTF-8

# install -- nss_wrapper
COPY --from=nss-wrapper-builder --chown=${POSTGRES_UID}:${POSTGRES_GID} /opt/bitnami/common /opt/bitnami/common

# install -- postgres
COPY --from=postgres-builder --chown=${POSTGRES_UID}:${POSTGRES_GID} /opt/bitnami/postgresql /opt/bitnami/postgresql

# install -- postgres runtime dependencies
# NOTE: we remove pl/perl, pl/python and pl/tcl dependencies to save image size,
#       to use the pl extensions, those have to be installed in a derived image
RUN runtime_deps="$( \
      scanelf \
        --needed \
        --nobanner \
        --format '%n#p' \
        --recursive /opt/bitnami/postgresql \
      | tr ',' '\n' \
      | sort -u \
      | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
      | grep -v -e perl -e python -e tcl \
    )" \
 && apk --no-cache add \
    ${runtime_deps} \
    bash \
    icu-data-full \
    musl-locales \
    musl-locales-lang \
    net-tools \
    su-exec \
    tzdata \
    zstd \
 # alias `su-exec` as `gosu` because they are fully compatible
 && ln -s /sbin/su-exec /sbin/gosu \
 # this file sets `LANG` and `LC_COLLATE`, but we want our ENV instruction to set the postgres locale
 && rm /etc/profile.d/locale.sh \
 # we use `/var/run/postgresql` for postgres unix sockets (set by `DEFAULT_PGSOCKET_DIR` in build)
 && mkdir -p /var/run/postgresql \
 && chown -R ${POSTGRES_UID}:${POSTGRES_GID} /var/run/postgresql

# include bitnami-postgres scripts and configs
ENV BITNAMI_APP_NAME="postgresql" \
    PATH="/opt/bitnami/common/bin:/opt/bitnami/postgresql/bin:$PATH"
COPY prebuildfs /
COPY rootfs /

# run bitnami-postgres postinstall setup and ensure permissions
RUN /opt/bitnami/scripts/postgresql/postunpack.sh \
 && mkdir -p /bitnami/postgresql \
 && chown -R ${POSTGRES_UID}:${POSTGRES_GID} /bitnami/postgresql /opt/bitnami

# create non-root 'postgres' user/group
RUN addgroup -g ${POSTGRES_GID} "${POSTGRES_GROUP}" \
 && adduser -D -h "${POSTGRES_HOME}" -u ${POSTGRES_UID} -G "${POSTGRES_GROUP}" "${POSTGRES_USER}" \
 && mkdir -p "${POSTGRES_HOME}" \
 && chown -R ${POSTGRES_UID}:${POSTGRES_GID} "${POSTGRES_HOME}"

USER ${POSTGRES_UID}
WORKDIR /opt/bitnami

VOLUME [ "/bitnami/postgresql", "/docker-entrypoint-initdb.d", "/docker-entrypoint-preinitdb.d" ]

ENTRYPOINT [ "/opt/bitnami/scripts/postgresql/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/postgresql/run.sh" ]