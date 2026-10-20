ARG BASE_IMAGE=amx-base:ubuntu

# Example build stage: starts from git clone, compiles against amx-base headers/libs
FROM ${BASE_IMAGE} AS build

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        git \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://gitlab.com/prpl-foundation/components/ambiorix/examples/datamodel/greeter_plugin.git /src/greeter_plugin \
    && git -C /src/greeter_plugin checkout --force f7b3dae7e9e55684265fafe97ab6c55ee5520448

RUN make -C /src/greeter_plugin -j"$(nproc)" \
    && make -C /src/greeter_plugin install

# Runtime: base + compiled example + entrypoint
FROM ${BASE_IMAGE}

COPY --from=build /etc/amx/greeter /etc/amx/greeter
COPY --from=build /usr/lib/amx/greeter /usr/lib/amx/greeter
COPY --from=build /usr/bin/greeter.odl /usr/bin/greeter.odl
COPY examples/greeter/entrypoint.sh examples/greeter/demo.sh /demo/
RUN chmod +x /demo/entrypoint.sh /demo/demo.sh \
    && ln -sf /usr/bin/amxrt /usr/bin/greeter \
    && ldconfig

ENTRYPOINT ["/demo/entrypoint.sh"]
CMD ["/demo/demo.sh"]
