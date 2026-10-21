# amx-greeter-demo

A reproducible Docker demo for **Ambiorix / greeter_plugin**: build the AMX stack,
start `ubusd + greeter`, and call the data model through `ubus`.

Companion article:
[官方例子 06：greeter_plugin](https://embedai.com.cn/posts/amx-example-greeter-plugin)
([English](https://embedai.com.cn/en/posts/amx-example-greeter-plugin)).

## Quick start

```bash
git clone https://github.com/zishuowang696/amx-greeter-demo.git
cd amx-greeter-demo
./build.sh
docker run --rm -it amx-greeter-demo:ubuntu
```

`./build.sh` builds both images (or run the two steps separately):

```bash
./build-base.sh       # amx-base:ubuntu
./build-example.sh    # amx-greeter-demo:ubuntu, FROM amx-base
```

1. `amx-base:ubuntu` — AMX base components + ubus + ACL;
2. `amx-greeter-demo:ubuntu` — `FROM amx-base`, clones `greeter_plugin` from Git,
   compiles it, and adds the entrypoint/demo.

The container starts `ubusd` and `greeter`, then runs a scripted demo:

- `ubus list`
- `ubus call Greeter _set '{"parameters":{"State":"Start"}}'`
- `ubus call Greeter say '{"from":"Docker","message":"Hello from AMX in Docker"}'`
- `ubus call Greeter.History.2 _get '{}'`

It stays alive after the demo. Explore from another shell:

```bash
docker exec -it <container> bash
ubus -s /var/run/ubus/ubus.sock list
ubus -s /var/run/ubus/ubus.sock call Greeter _get '{}'
```

## LED virtual-node test

The `tr181-led` unit tests use the plugin's mock LEDs (`test/common/mock_leds`)
instead of `/sys/class/leds`:

```bash
docker build -f examples/led/Dockerfile -t amx-led-test .
docker run --rm amx-led-test
```

It builds `libamxm`, `libsahtrace` and `tr181-led`, then runs the upstream
unit tests. Expected: **4 suites / 14 tests / 0 failures**.

## Images

### 1. `amx-base:ubuntu`

`base/Dockerfile` builds the AMX base components only:

- libubox, ubus
- libamxc, libamxp, libamxd, libamxb, libamxs, libamxo, libamxj, libamxrt
- amxrt app, amxb_ubus
- headers + libs (so examples can compile against the base)
- `demo` user + `/etc/ubus-acl/demo.json`

It runs `ubusd` with `-A /etc/ubus-acl`; the ACL lets `demo` publish/subscribe
and access all methods. The ACL file must be owned by root and mode `0644`;
`ubusd` silently rejects group/other-writable ACL files.

Pinned base commits are in [`base/build-amx.sh`](base/build-amx.sh).

### 2. `amx-greeter-demo:ubuntu`

`examples/greeter/Dockerfile` starts `FROM amx-base:ubuntu`:

- `git clone` the official `greeter_plugin` (pinned commit), then `make`;
- runtime copies only ODL + `greeter.so` + scripts;
- `ubusd` runs as root, `amxrt` runs as **`demo`** (non-root), proving the ACL;
- `demo.sh` calls `ubus` through `runuser -u demo`.

The example build does not recompile AMX; it reuses the base image headers/libs.

## Why the ACL matters

`ubusd` runs as root, but `amxrt` runs as **`demo`**. Without an ACL that allows
`demo` to publish, `ubus_add_object` returns `2` (`INVALID_ARGUMENT`) and
`amxb_ubus` does not surface the error: `ubus list` is just empty.

The demo ships `/etc/ubus-acl/demo.json` and starts `ubusd -A /etc/ubus-acl`.
The file must be root-owned and mode `0644`; group/other-writable ACL files are
rejected by `ubusd` (again, silently).

## Notes

- Base image: Ubuntu 22.04 (multi-stage; `amx-base:ubuntu` ~189 MB, example image ~187 MB in the tested build).
- AMX/greeter source is cloned at build time, not vendored.
- `ubus` method names in this stack are `_get` / `_set`, not the README's
  `get` / `set`.
- No OpenWrt device is required; this is a PC/container demo.

## License

The Dockerfile/scripts are MIT (see `LICENSE`). Cloned upstream projects keep
their own licenses.

## Docker Hub blocked?

`build.sh` takes the base OS image as an env var:

```bash
BASE_OS_IMAGE=docker.m.daocloud.io/library/ubuntu:22.04 ./build.sh
```
