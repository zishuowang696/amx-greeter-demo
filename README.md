# amx-greeter-demo

A reproducible Docker demo for **Ambiorix / greeter_plugin**: build the AMX stack,
start `ubusd + greeter`, and call the data model through `ubus`.

Companion article:
[官方例子 06：greeter_plugin](https://embedai.com.cn/posts/amx-example-greeter-plugin)
([English](https://embedai.com.cn/en/posts/amx-example-greeter-plugin)).

## Quick start

```bash
docker build -t amx-greeter-demo .
docker run --rm -it amx-greeter-demo
```

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

## Stages

`Dockerfile` has three stages:

1. **build** — Ubuntu 22.04 + toolchain; clones pinned commits of
   libubox, ubus, libamxc/amxp/amxd/amxb/amxs/amxo/amxj/amxrt,
   amxb_ubus, amxrt and greeter_plugin; compiles/install them.
2. **deploy** — runtime libraries + `/opt/amx`; runs a real smoke test:
   start `ubusd`, start `greeter`, call `_set` / `say` / `History.2 _get`.
   The build fails if registration or the calls fail.
3. **runtime** — the deploy image plus `entrypoint.sh` / `demo.sh`.

Pinned commits are in [`build-amx.sh`](build-amx.sh).

## Why root?

The container runs as root by default. That matters: with a non-root client
and no ubusd ACL, `ubus_add_object` fails (and `amxb_ubus` does not surface
the error). For a non-root demo, configure a ubusd ACL that allows publish.
This is the same trap documented in the article.

## Notes

- Base image: Ubuntu 22.04 (multi-stage; final image ~187 MB in the tested build).
- AMX/greeter source is cloned at build time, not vendored.
- `ubus` method names in this stack are `_get` / `_set`, not the README's
  `get` / `set`.
- No OpenWrt device is required; this is a PC/container demo.

## License

The Dockerfile/scripts are MIT (see `LICENSE`). Cloned upstream projects keep
their own licenses.
