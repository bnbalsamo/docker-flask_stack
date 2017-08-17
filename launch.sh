# Build the nginx.config from the template
# taking into account the proper env vars
envsubst '$$NGINX_WORKER_PROCESSES \
          $$NGINX_USER \
          $$NGINX_GROUP
          $$NGINX_WORKER_CONNECTIONS \
          $$NGINX_PORT \
          $$NGINX_TIMEOUT \
          $$NGINX_ROOT_DIR \
          $$NGINX_ACCEPT_MUTEX \
          $$NGINX_SENDFILE \
          $$NGINX_CLIENT_MAX_BODY_SIZE \
          $$NGINX_SERVER_EXTEND \
          $$NGINX_HTTP_EXTEND \
          $$NGINX_EVENTS_EXTEND \
          $$NGINX_ROOT_EXTEND \
          $$NGINX_UPSTREAM_EXTEND \
          $$NGINX_PROXY_EXTEND' < /etc/nginx/nginx.template > /etc/nginx/nginx.conf
# Be sure an APP_NAME env var is available
test -n "$APP_NAME"
# Fire up gunicorn, bind to a socket, background
gunicorn $APP_NAME:$APP_CALLABLE -k $GUNICORN_WORKER_TYPE -w $GUNICORN_WORKERS -t $GUNICORN_TIMEOUT -b unix:/tmp/gunicorn.sock $GUNICORN_CLI_EXTEND &
# Fire up nginx, keep it in the foreground
nginx -g "daemon off;" $NGINX_CLI_EXTEND
