FROM python:3.5
# Set up nginx
ENV NGINX_VERSION 1.9.11-1~jessie
RUN apt-key adv \
        --keyserver hkp://pgp.mit.edu:80 \
        --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
    && echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list \
    && apt-get update -qq \
    && apt-get install -y ca-certificates nginx=${NGINX_VERSION} gettext-base 
COPY ./nginx_conf_build.sh /nginx_conf_build.sh
COPY ./nginx.template /etc/nginx/nginx.template
RUN chmod +x /nginx_conf_build.sh
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log
# Set up runit - also clean up the package manager now
#RUN apt-get update -qq && \
RUN apt-get install --yes runit && \
    rm -rf /var/lib/apt/lists/*
COPY gunicorn_run /etc/sv/gunicorn/run
COPY nginx_run /etc/sv/nginx/run
RUN chmod +x /etc/sv/gunicorn/run && \
    chmod +x /etc/sv/nginx/run && \
    ln -s /etc/sv/gunicorn /etc/service/gunicorn && \
    ln -s /etc/sv/nginx /etc/service/nginx
# Grab all the args, toss them in the environment
# NOTE: All of these pertaining to nginx.conf need to
# ALSO appear in the nginx_conf_build.sh envsubst command
ARG NGINX_WORKER_PROCESSES=4
ARG NGINX_USER=nobody
ARG NGINX_GROUP=nogroup
ARG NGINX_WORKER_CONNECTIONS=1024
ARG NGINX_PORT=80
ARG NGINX_TIMEOUT=300
ARG NGINX_ROOT_DIR=/dev/null
ARG NGINX_ACCEPT_MUTEX=on
ARG NGINX_SENDFILE=on
ARG NGINX_CLIENT_MAX_BODY_SIZE=4G
ARG NGINX_SERVER_EXTEND
ARG NGINX_HTTP_EXTEND
ARG NGINX_EVENTS_EXTEND
ARG NGINX_ROOT_EXTEND
ARG NGINX_UPSTREAM_EXTEND
ARG NGINX_PROXY_EXTEND
ARG NGINX_CLI_EXTEND
ARG GUNICORN_WORKER_TYPE=eventlet
ARG GUNICORN_WORKERS=4
ARG GUNICORN_TIMEOUT=300
ARG GUNICORN_CLI_EXTEND
ARG APP_CALLABLE=app
ENV \
    NGINX_WORKER_PROCESSES=$NGINX_WORKER_PROCESSES \
    NGINX_USER=$NGINX_USER \
    NGINX_GROUP=$NGINX_GROUP \
    NGINX_WORKER_CONNECTIONS=$NGINX_WORKER_CONNECTIONS \
    NGINX_PORT=$NGINX_PORT \
    NGINX_TIMEOUT=$NGINX_TIMEOUT \
    NGINX_ROOT_DIR=$NGINX_ROOT_DIR \
    NGINX_ACCEPT_MUTEX=$NGINX_ACCEPT_MUTEX \
    NGINX_SENDFILE=$NGINX_SENDFILE \
    NGINX_CLIENT_MAX_BODY_SIZE=$NGINX_CLIENT_MAX_BODY_SIZE \
    NGINX_SERVER_EXTEND=$NGINX_SERVER_EXTEND \
    NGINX_HTTP_EXTEND=$NGINX_HTTP_EXTEND \
    NGINX_EVENTS_EXTEND=$NGINX_EVENTS_EXTEND \
    NGINX_ROOT_EXTEND=$NGINX_ROOT_EXTEND \
    NGINX_UPSTREAM_EXTEND=$NGINX_UPSTREAM_EXTEND \
    NGINX_PROXY_EXTEND=$NGINX_PROXY_EXTEND \
    NGINX_CLI_EXTEND=$NGINX_CLI_EXTEND \
    GUNICORN_WORKER_TYPE=$GUNICORN_WORKER_TYPE \
    GUNICORN_WORKERS=$GUNICORN_WORKERS \
    GUNICORN_TIMEOUT=$GUNICORN_TIMEOUT \
    GUNICORN_CLI_EXTEND=$GUNICORN_CLI_EXTEND \
    APP_CALLABLE=$APP_CALLABLE
# Toss in the files we need.
RUN ./nginx_conf_build.sh
# Install the flask/gunicorn basics via pip
RUN pip install flask greenlet eventlet gevent gunicorn
# Copy in the code from project specific builds
# and install it
ONBUILD COPY . /code/
ONBUILD WORKDIR /code
ONBUILD RUN pip install -r requirements.txt
ONBUILD RUN python /code/setup.py install 
# We should be good to go, fire it up.
CMD /nginx_conf_build.sh && \
    test -n $APP_NAME  && \
    runsvdir -P /etc/service
