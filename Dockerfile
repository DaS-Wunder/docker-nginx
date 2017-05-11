FROM alpine:3.5

ARG S6_OVERLAY_VERSION="1.19.1.1"
ARG NGINX_VERSION="1.11.8"

COPY root/ /

# Install core packages
RUN apk add --no-cache \
        ca-certificates \
        coreutils \
        tzdata && \

# Install build packages
    apk add --no-cache --virtual=build-dependencies \
        expat-dev \
        gcc \
        g++ \
        gzip \
        libressl-dev \
        make \
        pcre-dev \
        tar \
        wget \
        zlib-dev && \

# Add S6 overlay
    wget -qO /tmp/s6-overlay.tar.gz "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz" && \
    tar xfz /tmp/s6-overlay.tar.gz -C / && \

# Create user
    adduser -D -S -u 99 -G users -s /sbin/nologin duser && \

# Install runtime packages
    apk add --no-cache \
        expat \
        pcre \
        php7-curl \
        php7-fpm && \

# Build nginx
    wget -qO /tmp/nginx.tar.gz "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" && \
    wget -qO /tmp/config "https://raw.githubusercontent.com/senuphtyz/nginx-dav-ext-module/master/config" && \
    wget -qO /tmp/ngx_http_dav_ext_module.c "https://raw.githubusercontent.com/arut/nginx-dav-ext-module/master/ngx_http_dav_ext_module.c" && \
    tar zxf /tmp/nginx.tar.gz -C /tmp && \
    cd /tmp/nginx-${NGINX_VERSION} && \
    ./configure \
        --with-http_ssl_module \
        --with-http_gzip_static_module \
        --prefix=/etc/nginx \
        --http-log-path=/dev/stdout \
        --error-log-path=/dev/stderr \
        --sbin-path=/usr/local/sbin/nginx \
        --with-http_dav_module \
        --add-module=/tmp && \
    make && \
    make install && \

# Cleanup
    apk del --purge build-dependencies && \
    rm -rf /tmp/*

ENTRYPOINT /init
