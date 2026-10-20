#!/usr/bin/env bash
set -e

SOCK=/var/run/ubus/ubus.sock
run() {
  runuser -u demo -- ubus -s "$SOCK" -t 2 "$@"
}

echo "== ubus list (as demo, via ACL) =="
run list

echo
echo "== start Greeter (as demo) =="
run call Greeter _set '{"parameters":{"State":"Start"}}'

echo
echo "== say (as demo) =="
run call Greeter say '{"from":"demo","message":"Hello from AMX in Docker"}'

echo
echo "== History.2 (as demo) =="
run call Greeter.History.2 _get '{}'

echo
echo "Demo is running. Use 'docker exec -it <container> bash' to explore."
exec tail -f /dev/null
