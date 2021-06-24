#!/bin/sh

case "$CLIENT_VERIFICATION" in
  1 | true | on)
  SSL_VERIFY_CLIENT=optional
  sslFixFF=1
  addSection=1
  ;;
  0 | false | off)
  SSL_VERIFY_CLIENT=off
  ;;
  optional)
  SSL_VERIFY_CLIENT=optional
  addSection=1
  ;;
  optional_no_ca)
  SSL_VERIFY_CLIENT=optional_no_ca
  addSection=1
  ;;
  *) SSL_VERIFY_CLIENT=off;;
esac

if [ -n "$addSection" ]; then
  targetFile=/etc/nginx/ssl-client.conf
  clientCertificateFileName=${CLIENT_CA_FILENAME:-client-ca.pem}
  cat > "$targetFile" <<EOF
### Client verification ###
ssl_client_certificate $NGINX_SSL_ROOT/$clientCertificateFileName;
ssl_verify_client $SSL_VERIFY_CLIENT;

EOF

  if [ -n "$sslFixFF" ]; then
    cat >> "$targetFile" <<FIX
## Fix Firefox mTLS OPTIONS request
# https://bugzilla.mozilla.org/show_bug.cgi?id=1019603
set \$allow 0;

if (\$ssl_client_verify = SUCCESS) {
  set \$allow 1;
}

if (\$request_method = OPTIONS) {
  set \$allow 1;
}

if (\$allow != 1) {
  return 400;
}
FIX
  fi
fi

exit 0
