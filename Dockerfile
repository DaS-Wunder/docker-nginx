FROM alpine:3.6

COPY ./docker-entrypoint.sh /docker-entrypoint.sh

ARG NGINX_VERSION="1.12.2"

# Install core packages
RUN apk add --no-cache \
        ca-certificates \
        coreutils \
        shadow \
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

# Create user
    useradd -r -u 911 -m -s /bin/false nginx && \
    usermod -G users nginx && \

# Install runtime packages
    apk add --no-cache \
        expat \
        pcre && \

# Build nginx
    wget -qO /tmp/nginx.tar.gz "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" && \
    wget -qO /tmp/config "https://raw.githubusercontent.com/senuphtyz/nginx-dav-ext-module/master/config" && \
    wget -qO /tmp/ngx_http_dav_ext_module.c "https://raw.githubusercontent.com/arut/nginx-dav-ext-module/master/ngx_http_dav_ext_module.c" && \
    tar zxf /tmp/nginx.tar.gz -C /tmp && \
    cd /tmp/nginx-${NGINX_VERSION} && \
    ./configure \
        --with-http_ssl_module \
        --with-http_gzip_static_module \
        --with-http_v2_module \
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
    rm -rf /tmp/* &&\

# Set file permissions
    chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
