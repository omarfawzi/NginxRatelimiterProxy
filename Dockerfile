FROM openresty/openresty:alpine-fat AS base

RUN apk add --no-cache git yaml-dev

RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-ipmatcher && \
    /usr/local/openresty/luajit/bin/luarocks install lua-resty-global-throttle && \
    /usr/local/openresty/luajit/bin/luarocks install lyaml

WORKDIR /usr/local/openresty/nginx/lua
COPY lua/* .

FROM base AS test
RUN /usr/local/openresty/luajit/bin/luarocks install busted && \
    /usr/local/openresty/luajit/bin/luarocks install luacov

FROM base AS docker
COPY nginx/nginx.docker.conf /usr/local/openresty/nginx/conf/nginx.conf
CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]

FROM base AS kube
COPY nginx/nginx.kube.conf /usr/local/openresty/nginx/conf/nginx.conf
CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]

FROM base AS local
COPY nginx/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
