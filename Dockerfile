ARG BASE_IMAGE=ubuntu:22.04

# 1) build: toolchain + compile/install into /usr
FROM ${BASE_IMAGE} AS build

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bison \
        build-essential \
        ca-certificates \
        cmake \
        flex \
        git \
        libcap-dev \
        libcap-ng-dev \
        libevent-dev \
        libjson-c-dev \
        liblua5.3-dev \
        libncurses-dev \
        libreadline-dev \
        libssl-dev \
        liburiparser-dev \
        libxml2-dev \
        libyajl-dev \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY build-amx.sh /src/build-amx.sh
RUN chmod +x /src/build-amx.sh && /src/build-amx.sh

RUN mkdir -p /deploy/bin /deploy/lib /deploy/etc/amx/greeter \
    && cp /usr/sbin/ubusd /usr/bin/ubus /usr/bin/amxrt /deploy/bin/ \
    && cp -a /usr/bin/mods /deploy/bin/ \
    && find /usr/lib /usr/lib/x86_64-linux-gnu -maxdepth 1 \
         \( -name 'libamx*.so*' -o -name 'libubox*.so*' -o -name 'libubus*.so*' -o -name 'libblobmsg_json*.so*' -o -name 'libjson_script*.so*' \) \
         -exec cp -a {} /deploy/lib/ \; \
    && cp -a /usr/lib/amx /deploy/lib/ \
    && cp -a /etc/amx/greeter/. /deploy/etc/amx/greeter/ \
    && cp /deploy/lib/amx/greeter/greeter.so /deploy/etc/amx/greeter/ \
    && ln -sf amxrt /deploy/bin/greeter

# 2) deploy: runtime libs + /opt/amx, with a real registration smoke test
FROM ${BASE_IMAGE} AS deploy

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        libcap-ng0 \
        libevent-2.1-7 \
        libcap2 \
        libjson-c5 \
        liblua5.3-0 \
        libncurses6 \
        libreadline8 \
        libssl3 \
        liburiparser1 \
        libxml2 \
        libyajl2 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /deploy/ /opt/amx/

ENV PATH=/opt/amx/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/amx/lib

RUN set -eux; \
    mkdir -p /var/run/ubus /tmp/greeter-data; \
    ubusd -s /var/run/ubus/ubus.sock & \
    i=0; until ubus -s /var/run/ubus/ubus.sock -t 1 list >/dev/null 2>&1 || [ "$i" -ge 50 ]; do i=$((i+1)); sleep 0.1; done; \
    cd /opt/amx/etc/amx; \
    amxrt -A -B /opt/amx/bin/mods/amxb/mod-amxb-ubus.so \
        -u ubus:/var/run/ubus/ubus.sock -N ./greeter/greeter.odl \
        -o name=greeter -o rw_data_path=/tmp/greeter-data >/tmp/greeter.log 2>&1 & \
    i=0; until ubus -s /var/run/ubus/ubus.sock -t 1 list 2>/dev/null | grep -qx Greeter || [ "$i" -ge 50 ]; do i=$((i+1)); sleep 0.1; done; \
    ubus -s /var/run/ubus/ubus.sock -t 2 list; \
    ubus -s /var/run/ubus/ubus.sock -t 2 call Greeter _set '{"parameters":{"State":"Start"}}'; \
    ubus -s /var/run/ubus/ubus.sock -t 2 call Greeter say '{"from":"Docker","message":"Hello from AMX"}'; \
    ubus -s /var/run/ubus/ubus.sock -t 2 call Greeter.History.2 _get '{}'; \
    pkill -x amxrt || true; pkill -x ubusd || true

# 3) runtime: same deploy image + entrypoint/demo
FROM deploy AS runtime

COPY entrypoint.sh demo.sh /demo/
RUN chmod +x /demo/entrypoint.sh /demo/demo.sh

ENTRYPOINT ["/demo/entrypoint.sh"]
CMD ["/demo/demo.sh"]
