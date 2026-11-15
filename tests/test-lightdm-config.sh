#!/usr/bin/env bash
set -euo pipefail

repo=$(
	unset CDPATH
	cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd
)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

debian_stage="$work/debian"

make -C "$repo/lightdm" --no-print-directory \
	DESTDIR="$debian_stage" \
	LIGHTDM_SEAT_SECTION='Seat:*' \
	LIGHTDM_GREETER_SESSION=slick-greeter \
	LIGHTDM_SESSION_WRAPPER= \
	LIGHTDM_LOGIND_CHECK=true \
	install >/dev/null
cat >"$work/debian.expected" <<'CONF'
[LightDM]
logind-check-graphical=true

[Seat:*]
greeter-session=slick-greeter
user-session=dwm
CONF
cmp -s "$work/debian.expected" "$debian_stage/etc/lightdm/lightdm.conf"

grep -Fqx 'xft-dpi=96' "$debian_stage/etc/lightdm/slick-greeter.conf"
grep -Fqx 'activate-numlock=false' "$debian_stage/etc/lightdm/slick-greeter.conf"

printf 'LightDM config rendering: PASS\n'
