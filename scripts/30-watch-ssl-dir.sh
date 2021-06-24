#!/bin/sh

while inotifywait "$NGINX_SSL_ROOT" -qq -e create -e modify -e move -e delete; do
  echo "Detected certificate changes"
  nginx -t && nginx -s reload
done &

exit 0
