A stack for deploying flask/django python applications via Docker, utilizing gunicorn and nginx.

# Usage

- Build this image, tag it something you'll remember
```
# docker build . -t flask_stack
```
- Inherit from this image in your own projects Dockerfile.
- Be sure to include a requirements.txt in the root directory of your project
- Be sure to include a setup.py in the root directory of your project
- Set any project specific environmental variables in your projects Dockerfile
- Set the environmental variable APP_NAME to the module name which contains your wsgi callable
- Set the environmental variable APP_CALLABLE if the callable is not named "app"
- Build your project
- Run a container

## Example Project Dockerfile

```
FROM flask_stack

ARG MY_APP_VERBOSITY="WARN"
ARG MY_APP_SECRET_KEY
ENV MY_APP_VERBOSITY=$MY_APP_VERBOSITY \
    MY_APP_SECRETY_KEY=$MY_APP_SECRET_KEY
# Require a secret key on build -
# You can always clobber it at run time to change it
RUN ["test", "-n", "$MY_APP_SECRET_KEY"]

ENV APP_NAME=my_app
```

## Customization

Functionality can be customized by tweaking environmental variables in any of the following places:

- In this Dockerfile
- In the CLI args to building the flask_stack image
- In your projects Dockerfile
- In the CLI args to building your projects image
- In the CLI args to starting your project container

Changes made to the flask_stack Dockerfile or flask_stack build CLI args will inherit into every project based on the image. Changes made in your projects Dockerfile or your projects build CLI args will become the defaults for your projects containers, and changes made in the CLI args when starting a container will apply to that container only.

# Docker Build Args

- NGINX_WORKER_PROCESSES=4
- NGINX_USER=nobody
- NGINX_GROUP=nogroup
- NGINX_WORKER_CONNECTIONS=1024
- NGINX_PORT=80
- NGINX_TIMEOUT=300
- NGINX_ROOT_DIR=/dev/null
- NGINX_ACCEPT_MUTEX=on
- NGINX_SENDFILE=on
- NGINX_CLIENT_MAX_BODY_SIZE=4G
- NGINX_SERVER_EXTEND
- NGINX_HTTP_EXTEND
- NGINX_EVENTS_EXTEND
- NGINX_ROOT_EXTEND
- NGINX_UPSTREAM_EXTEND
- NGINX_PROXY_EXTEND
- NGINX_CLI_EXTEND
- GUNICORN_WORKER_TYPE=eventlet
- GUNICORN_WORKERS=4
- GUNICORN_TIMEOUT=300
- GUNICORN_CLI_EXTEND
- APP_CALLABLE=app
