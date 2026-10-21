ARG BASE_IMAGE=amx-base:ubuntu
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        cmake \
        git \
        libcap-ng-dev \
        libcmocka-dev \
        libevent-dev \
        libjson-c-dev \
        libssl-dev \
        liburiparser-dev \
        libxml2-dev \
        libyajl-dev \
        pkg-config \
        valgrind \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

RUN git clone https://gitlab.com/prpl-foundation/components/ambiorix/libraries/libamxm.git \
    && git -C libamxm checkout --force fc658d061a4d750812df2a762c9af0c349a812e5 \
    && make -C libamxm -j"$(nproc)" \
    && make -C libamxm install \
    && ldconfig

RUN git clone https://gitlab.com/prpl-foundation/components/core/libraries/libsahtrace.git \
    && git -C libsahtrace checkout --force 9db38d1c7ed41a3e288bd1f7fa5f6201c4985a64 \
    && make -C libsahtrace -j"$(nproc)" \
    && make -C libsahtrace install \
    && ldconfig

RUN git clone https://gitlab.com/prpl-foundation/components/core/plugins/tr181-led.git \
    && git -C tr181-led checkout --force 97ae80680d5c8a5e8f63d3d0ca4aa2f93d712a74

WORKDIR /src/tr181-led
RUN make -C test run SHELL=/bin/bash

CMD ["bash", "-lc", "cd /src/tr181-led && make -C test run SHELL=/bin/bash"]
