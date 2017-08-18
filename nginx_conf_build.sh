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
