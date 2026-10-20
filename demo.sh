#!/usr/bin/env bash
set -e

SOCK=/var/run/ubus/ubus.sock
U="ubus -s $SOCK -t 2"

echo "== ubus list =="
$U list

echo
echo "== start Greeter =="
$U call Greeter _set '{"parameters":{"State":"Start"}}'

echo
echo "== say =="
$U call Greeter say '{"from":"Docker","message":"Hello from AMX in Docker"}'

echo
echo "== History.2 =="
$U call Greeter.History.2 _get '{}'

echo
echo "Demo is running. Use 'docker exec -it <container> bash' to explore."
exec tail -f /dev/null
