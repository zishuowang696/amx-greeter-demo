#!/usr/bin/env bash
set -e

SOCK=/var/run/ubus/ubus.sock
mkdir -p /var/run/ubus /tmp/greeter-data
chown demo:demo /tmp/greeter-data

ubusd -A /etc/ubus-acl -s "$SOCK" >/var/log/ubusd.log 2>&1 &
for _ in $(seq 1 50); do
  ubus -s "$SOCK" -t 1 list >/dev/null 2>&1 && break
  sleep 0.1
done

runuser -u demo -- amxrt -A -B /usr/bin/mods/amxb/mod-amxb-ubus.so \
  -u "ubus:$SOCK" -N /etc/amx/greeter/greeter.odl \
  -o name=greeter -o rw_data_path=/tmp/greeter-data >/var/log/greeter.log 2>&1 &

for _ in $(seq 1 50); do
  if ubus -s "$SOCK" -t 1 list 2>/dev/null | grep -qx Greeter; then
    break
  fi
  sleep 0.1
done

if ! ubus -s "$SOCK" -t 1 list 2>/dev/null | grep -qx Greeter; then
  echo "Greeter did not register (demo user + ACL)" >&2
  echo "--- ubusd ---" >&2
  cat /var/log/ubusd.log >&2 || true
  echo "--- greeter ---" >&2
  cat /var/log/greeter.log >&2 || true
  exit 1
fi

exec "$@"
