appwilio/nginx
==============

Nginx docker image by appwilio. Based on official nginx image.

## Features

* brotli support
* mTLS runtime config
* watch ssl directory and auto reload on certificate update

## Environment variables

| Variable            | Default        | Description                                                              |
|---------------------|----------------|--------------------------------------------------------------------------|
| CLIENT_VERIFICATION |                | http://nginx.org/ru/docs/http/ngx_http_ssl_module.html#ssl_verify_client |
| CLIENT_CA_FILENAME  | client-ca.pem  |                                                                          |
| NGINX_SSL_ROOT      | /etc/nginx/ssl | directory containing ssl keys and certificates                           |
| LOADBALANCER_SUBNET | 127.0.0.1      | PROXY_PROTOCOL trusted network                                           |
| APP_ENV             | production     | Allow to run or omit some scripts depending environment                  |

## HOWTO

### Mutal TLS

1. Mount client CA certificate (filename configured by `CLIENT_CA_FILENAME` env variable) to `NGINX_SSL_ROOT`
2. Set `CLIENT_VERIFICATION` environment variable to `on`
3. Include `ssl-client.conf` in server configuration:

```nginx.conf
include ssl-client.conf;
```

### Brotli

1. Compress static files with brotli
2. Add load_module directive to nginx.conf:

```nginx.conf
load_module /usr/local/nginx/modules/ngx_http_brotli_static_module.so;
```

3. Add directive to static location:

```nginx.conf
location /static/ {
    brotli_static on;
}
```