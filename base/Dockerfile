ARG BASE_IMAGE=ubuntu:22.04

# Build stage: AMX base components only (no example)
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
COPY base/build-amx.sh /src/build-amx.sh
RUN chmod +x /src/build-amx.sh && /src/build-amx.sh

RUN mkdir -p /deploy/usr/bin /deploy/usr/sbin /deploy/usr/lib /deploy/usr/include \
    && cp /usr/sbin/ubusd /deploy/usr/sbin/ \
    && cp /usr/bin/ubus /usr/bin/amxrt /deploy/usr/bin/ \
    && cp -a /usr/bin/mods /deploy/usr/bin/ \
    && find /usr/lib /usr/lib/x86_64-linux-gnu -maxdepth 1 \
         \( -name 'libamx*.so*' -o -name 'libubox*.so*' -o -name 'libubus*.so*' \
            -o -name 'libblobmsg_json*.so*' -o -name 'libjson_script*.so*' \) \
         -exec cp -a {} /deploy/usr/lib/ \; \
    && cp -a /usr/include/amx* /usr/include/libubox /deploy/usr/include/ \
    && cp /usr/include/libubus.h /usr/include/ubusmsg.h /usr/include/ubus_common.h /deploy/usr/include/

# Base image: runtime + headers (demo-friendly, examples compile against it)
FROM ${BASE_IMAGE} AS base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        libcap-ng0 \
        libcap2 \
        libevent-2.1-7 \
        libjson-c5 \
        liblua5.3-0 \
        libncurses6 \
        libreadline8 \
        libssl3 \
        liburiparser1 \
        libxml2 \
        libyajl2 \
        util-linux \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /deploy/ /

RUN useradd -m -s /bin/bash demo \
    && mkdir -p /etc/ubus-acl /var/run/ubus \
    && ldconfig

COPY base/acl/demo.json /etc/ubus-acl/demo.json
RUN chmod 0644 /etc/ubus-acl/demo.json

CMD ["/bin/bash"]
