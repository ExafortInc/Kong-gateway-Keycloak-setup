#!/bin/bash

cd $(readlink -f $0 | grep -o '.*/')
. common.sh

set -x
docker run -d -t \
    --name $DOCKER_CONTAINER \
    --hostname $DOCKER_CONTAINER \
    --network=kong-net \
    -e KONG_LOG_LEVEL=${KONG_LOG_LEVEL:-info} \
    -e "KONG_DATABASE=postgres" \
    -e "KONG_PG_HOST=kong-database" \
    -e "KONG_PG_USER=kong" \
    -e "KONG_PG_PASSWORD=kongpass" \
    -e KONG_ADMIN_ACCESS_LOG=/dev/stdout \
    -e KONG_ADMIN_ERROR_LOG=/dev/stderr \
    -e KONG_ADMIN_GUI_ACCESS_LOG=/dev/stdout \
    -e KONG_ADMIN_GUI_ERROR_LOG=/dev/stderr \
    -e KONG_PORTAL_API_ACCESS_LOG=/dev/stdout \
    -e KONG_PORTAL_API_ERROR_LOG=/dev/stderr \
    -e KONG_PROXY_ACCESS_LOG=/dev/stdout \
    -e KONG_PROXY_ERROR_LOG=/dev/stderr \
    -e KONG_ANONYMOUS_REPORTS='false' \
    -e KONG_CLUSTER_LISTEN='off' \
    -e KONG_LUA_PACKAGE_PATH='/opt/?.lua;/opt/?/init.lua;;' \
    -e KONG_NGINX_WORKER_PROCESSES='1' \
    -e KONG_PLUGINS='bundled,oidc,cookies-to-headers' \
    -e KONG_ADMIN_LISTEN='0.0.0.0:8001' \
    -e KONG_PROXY_LISTEN='0.0.0.0:8000, 0.0.0.0:8443 http2 ssl' \
    -e KONG_STATUS_LISTEN='0.0.0.0:8100' \
    -e KONG_NGINX_DAEMON='off' \
    -e KONG_X_SESSION_SECRET='ejhXZPX4Xl0ZYDfPMSvB9c3650N8lzTQuGPINT0wY2Uh' \
    -e KONG_X_SESSION_MEMCACHE_PORT="'1234'" \
    -e KONG_X_SESSION_COMPRESSOR=zlib \
    -v $PWD/test:/kong_dbless \
    -p $KONG_LOCAL_ADMIN_PORT:8001 \
    -p $KONG_LOCAL_HTTP_PORT:8000 \
    -p $KONG_LOCAL_HTTPS_PORT:8443 \
    -p 8002:8002\
    -p 8444:8444 \
    -p 8445:8445 \
    -p 8003:8003 \
    -p 8004:8004 \
    $DOCKER_IMAGE \
    $*
# 