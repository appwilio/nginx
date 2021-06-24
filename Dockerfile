FROM nginx:stable-alpine as builder

RUN apk add --no-cache --virtual .build-deps \
    git \
    gcc \
    libc-dev \
    make \
    openssl-dev \
    pcre-dev \
    zlib-dev \
    linux-headers \
    libxslt-dev \
    gd-dev \
    geoip-dev \
    perl-dev \
    libedit-dev \
    mercurial \
    bash \
    alpine-sdk \
    findutils && \
    mkdir -p /usr/src && \
    wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O nginx.tar.gz && \
    tar -zxC /usr/src -f nginx.tar.gz 
WORKDIR /usr/src
RUN CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p')
RUN git clone https://github.com/google/ngx_brotli.git && cd ngx_brotli && git submodule update --init
RUN cd /usr/src/nginx-$NGINX_VERSION && \
 ./configure --with-compat $CONFARGS --add-dynamic-module=/usr/src/ngx_brotli && \
 make modules

FROM nginx:stable-alpine
ENV APP_ENV=production NGINX_SSL_ROOT=/etc/nginx/ssl LOADBALANCER_SUBNET=127.0.0.1 

COPY --from=builder /usr/src/nginx-$NGINX_VERSION/objs/*.so /usr/local/nginx/modules/
RUN apk add --no-cache inotify-tools && \
    touch /etc/nginx/ssl-client.conf
COPY scripts/* /docker-entrypoint.d/
