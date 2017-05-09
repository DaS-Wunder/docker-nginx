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
    wget -O /tmp/s6-overlay.tar.gz "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz" && \
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
    mkdir -p /tmp/src && \
    cd /tmp/src && \
    wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" && \
    wget "https://raw.githubusercontent.com/senuphtyz/nginx-dav-ext-module/master/config" && \
    wget "https://raw.githubusercontent.com/arut/nginx-dav-ext-module/master/ngx_http_dav_ext_module.c" && \
    tar zxf nginx-${NGINX_VERSION}.tar.gz && \
    cd /tmp/src/nginx-${NGINX_VERSION} && \
    ./configure \
        --with-http_ssl_module \
        --with-http_gzip_static_module \
        --prefix=/etc/nginx \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --sbin-path=/usr/local/sbin/nginx \
        --with-http_dav_module \
        --add-module=/tmp/src && \
    make && \
    make install && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \

# Cleanup
    apk del --purge build-dependencies && \
    rm -rf /tmp/*

ENTRYPOINT /init
