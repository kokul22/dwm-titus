#!/usr/bin/env bash
set -euo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
work=$(mktemp -d)
trap 'find "$work" -depth -delete' EXIT

cat >"$work/debian" <<'OS'
ID=debian
VERSION_ID="13"
ID_LIKE=debian
PRETTY_NAME="Debian GNU/Linux 13 (trixie)"
OS
cat >"$work/ubuntu" <<'OS'
ID=ubuntu
VERSION_ID="26.04"
ID_LIKE="debian"
PRETTY_NAME="Ubuntu"
OS
cat >"$work/arch" <<'OS'
ID=arch
VERSION_ID="45"
PRETTY_NAME="Arch Linux"
OS
for os in debian ubuntu; do
	[[ $(DWM_TEST_MODE=1 DWM_OS_RELEASE="$work/$os" bash -c \
		'. "$1"; printf "%s" "$DISTRO_FAMILY"' sh "$repo/scripts/dwm-utils.sh") == debian ]]
done
[[ $(DWM_TEST_MODE=1 DWM_OS_RELEASE="$work/arch" bash -c \
	'. "$1"; printf "%s" "$DISTRO_FAMILY"' sh "$repo/scripts/dwm-utils.sh") == unknown ]]

DWM_TEST_MODE=1 DWM_OS_RELEASE="$work/debian" "$repo/install.sh" \
	--dry-run --non-interactive --profile core >"$work/installer.out"
grep -Fq 'Package manager: sudo apt-get install -y' "$work/installer.out"

grep -Fxq build-essential < <("$repo/scripts/dwm-packages.sh" debian build)
grep -Fxq xserver-xorg-core < <("$repo/scripts/dwm-packages.sh" debian x11)
grep -Fxq packagekit < <("$repo/scripts/dwm-packages.sh" debian system-management)
grep -Fxq gir1.2-packagekitglib-1.0 < <("$repo/scripts/dwm-packages.sh" debian system-management)
if "$repo/scripts/dwm-packages.sh" arch build >/dev/null 2>&1; then
	printf 'Unsupported package map unexpectedly remains enabled.\n' >&2
	exit 1
fi

mkdir -p "$work/bin"
cat >"$work/bin/apt-get" <<'SH'
#!/usr/bin/env bash
printf 'apt-get\t%s\n' "$*" >>"$DWM_CALLS"
SH
cat >"$work/bin/sudo" <<'SH'
#!/usr/bin/env bash
printf 'sudo\t%s\n' "$*" >>"$DWM_CALLS"
"$@"
SH
chmod +x "$work/bin/apt-get" "$work/bin/sudo"
calls="$work/calls"
DWM_TEST_MODE=1 DWM_OS_RELEASE="$work/debian" DWM_CALLS="$calls" PATH="$work/bin:$PATH" \
	bash -c '. "$1/scripts/dwm-utils.sh"; install_packages libx11-dev libxft-dev' sh "$repo"
grep -Fx $'sudo\tapt-get install -y -- libx11-dev libxft-dev' "$calls" >/dev/null
grep -Fx $'apt-get\tinstall -y -- libx11-dev libxft-dev' "$calls" >/dev/null

printf 'Debian family detection and APT install boundary: PASS\n'
