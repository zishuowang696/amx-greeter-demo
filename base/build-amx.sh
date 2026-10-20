#!/usr/bin/env bash
set -euo pipefail

SRC=/src
JOBS="${JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 2)}"

fetch() {
  local repo="$1" dir="$2" commit="$3"
  if [ ! -d "$dir/.git" ]; then
    git clone "$repo" "$dir"
  fi
  git -C "$dir" fetch --all --tags
  git -C "$dir" checkout --force "$commit"
}

build_cmake() {
  local dir="$1"
  shift
  cmake -S "$dir" -B "$dir/build" -DCMAKE_INSTALL_PREFIX=/usr "$@"
  cmake --build "$dir/build" -j"$JOBS"
  cmake --install "$dir/build"
}

build_make() {
  local dir="$1"
  make -C "$dir" -j"$JOBS"
  make -C "$dir" install
}

mkdir -p "$SRC"

fetch https://github.com/openwrt/libubox.git "$SRC/libubox" da2d205a5cf3e877c45a2eec488218cbaf452e7d
fetch https://github.com/openwrt/ubus.git "$SRC/ubus" 414c60a2e29e72c2c4f573bc50ad54aef076d169
fetch https://gitlab.com/prpl-foundation/components/ambiorix/libraries/libamxc.git "$SRC/libamxc" 9d6aac864dde1f41e0adb0e629f461e4f24e2419
fetch https://gitlab.com/prpl-foundation/components/ambiorix/libraries/libamxp.git "$SRC/libamxp" ed282fc1373f7947e5038e9261acd40fc3182ad1
fetch https://gitlab.com/prpl-foundation/components/ambiorix/libraries/libamxd.git "$SRC/libamxd" 94ff82af16439d436854c8aa208400fc3489292d
fetch https://gitlab.com/prpl-foundation/components/ambiorix/libraries/libamxs.git "$SRC/libamxs" e3bf6df204ec5beb910059387b258f43d6a9db51
fetch https://gitlab.com/prpl-foundation/components/ambiorix/libraries/libamxo.git "$SRC/libamxo" f64456bc8ea4ad26499c5e0ee53dedb60366f98c
fetch https://gitlab.com/prpl-foundation/components/ambiorix/libraries/libamxb.git "$SRC/libamxb" 20eb8e0b5af2a5b77e2eb62fc53248ca9203ecae
fetch https://gitlab.com/prpl-foundation/components/ambiorix/libraries/libamxj.git "$SRC/libamxj" 12da32d85e939384692a456ffa650743cf3bf1f5
fetch https://gitlab.com/prpl-foundation/components/ambiorix/libraries/libamxrt.git "$SRC/libamxrt" fd9d3b0131fd9aaaf3f0f2f3e9353d7d0aed582f
fetch https://gitlab.com/prpl-foundation/components/ambiorix/applications/amxrt.git "$SRC/amxrt" 195d6e6053a1e1e9e20fadaeb8f9f7f5898ec70b
fetch https://gitlab.com/prpl-foundation/components/ambiorix/modules/amxb_backends/amxb_ubus.git "$SRC/amxb_ubus" c74118306cd9f4557de2a8963c21f6d4a94c6f89

build_cmake "$SRC/libubox" -DBUILD_LUA=OFF -DBUILD_EXAMPLES=OFF
build_cmake "$SRC/ubus" -DBUILD_LUA=OFF
build_make "$SRC/libamxc"
build_make "$SRC/libamxp"
build_make "$SRC/libamxd"
build_make "$SRC/libamxb"
build_make "$SRC/libamxs"
build_make "$SRC/libamxo"
build_make "$SRC/libamxj"
build_make "$SRC/libamxrt"
build_make "$SRC/amxrt"
build_make "$SRC/amxb_ubus"

ldconfig 2>/dev/null || true

echo "AMX base installed"
