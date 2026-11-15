#!/usr/bin/env bash
set -euo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
work=$(mktemp -d)
trap 'find "$work" -depth -delete' EXIT

cat >"$work/debian13" <<'EOF'
ID=debian
VERSION_ID="13"
PRETTY_NAME="Debian GNU/Linux 13 (trixie)"
EOF
cat >"$work/debian12" <<'EOF'
ID=debian
VERSION_ID="12"
EOF
cat >"$work/unsupported" <<'EOF'
ID=ubuntu
VERSION_ID="25.10"
ID_LIKE=debian
EOF

family=$(DWM_TEST_MODE=1 DWM_OS_RELEASE="$work/debian13" bash -c \
	'. "$1"; printf "%s" "$DISTRO_FAMILY"' sh "$repo/scripts/dwm-utils.sh")
[[ $family == debian13 ]]
[[ $(DWM_TEST_MODE=1 DWM_OS_RELEASE="$work/debian12" bash -c \
	'. "$1"; printf "%s" "$DISTRO_FAMILY"' sh "$repo/scripts/dwm-utils.sh") == unknown ]]
[[ $(DWM_TEST_MODE=1 DWM_OS_RELEASE="$work/unsupported" bash -c \
	'. "$1"; printf "%s" "$DISTRO_FAMILY"' sh "$repo/scripts/dwm-utils.sh") == unknown ]]

set +e
DWM_TEST_MODE=1 DWM_OS_RELEASE="$work/debian13" "$repo/install.sh" \
	--dry-run --non-interactive --profile core >"$work/installer.out" 2>&1
installer_status=$?
set -e
[[ $installer_status == 1 ]]
grep -Fq 'dwm-titus supports Fedora only.' "$work/installer.out"

source "$repo/scripts/dwm-packages.sh"
for package in build-essential pkg-config libx11-dev libxft-dev libxinerama-dev \
	libxrender-dev libimlib2-dev libxcb1-dev libxcb-res0-dev libfontconfig1-dev libfreetype-dev; do
	dwm_packages debian13 build | grep -Fx "$package" >/dev/null
done
for package in xserver-xorg-core xinit x11-xserver-utils x11-xkb-utils xinput xkbset; do
	dwm_packages debian13 x11 | grep -Fx "$package" >/dev/null
done
for package in quickshell thunar picom bubblewrap libseccomp2; do
	dwm_packages debian13 desktop | grep -Fx "$package" >/dev/null
done
if dwm_packages debian13 full | grep -Eq 'dnf|rpm|NetworkManager-wifi|power-profiles-daemon|celluloid|sxiv'; then
	printf 'Debian DWM package map includes Fedora or out-of-scope system packages.\n' >&2
	exit 1
fi
if dwm_packages debian13 build | grep -Eq '(^|-)devel$|\.rpm$'; then
	printf 'Debian build profile contains Fedora-style package names.\n' >&2
	exit 1
fi
if "$repo/scripts/dwm-packages.sh" debian13 system-management >/dev/null 2>&1; then
	printf 'Debian system-management profile unexpectedly exists.\n' >&2
	exit 1
fi

mkdir -p "$work/bin"
cat >"$work/bin/apt-get" <<'EOF'
#!/usr/bin/env bash
printf 'apt-get\t%s\n' "$*" >>"$DWM_CALLS"
EOF
cat >"$work/bin/sudo" <<'EOF'
#!/usr/bin/env bash
printf 'sudo\t%s\n' "$*" >>"$DWM_CALLS"
"$@"
EOF
chmod +x "$work/bin/apt-get" "$work/bin/sudo"
calls="$work/calls"
result=$(DWM_TEST_MODE=1 DWM_OS_RELEASE="$work/debian13" DWM_CALLS="$calls" \
	PATH="$work/bin:$PATH" bash -c '
        . "$1/scripts/dwm-utils.sh"
        install_packages "libx11-dev" "libxft-dev"
    ' sh "$repo")
[[ -z $result ]]
grep -Fx $'sudo\tapt-get install -y -- libx11-dev libxft-dev' "$calls" >/dev/null
grep -Fx $'apt-get\tinstall -y -- libx11-dev libxft-dev' "$calls" >/dev/null

cat >"$work/bin/dpkg-query" <<'EOF'
#!/usr/bin/env bash
[[ $* == '-W -f=${db:Status-Status} -- gnome-keyring' ]] || exit 2
printf 'installed\n'
EOF
chmod +x "$work/bin/dpkg-query"
DWM_TEST_MODE=1 DWM_OS_RELEASE="$work/debian13" PATH="$work/bin:$PATH" \
	bash -c '. "$1/scripts/dwm-utils.sh"; package_installed gnome-keyring' sh "$repo"

fedora_packages=$(dwm_packages fedora build)
grep -Fxq gcc <<<"$fedora_packages"
grep -Fxq libX11-devel <<<"$fedora_packages"
if grep -Fxq libx11-dev <<<"$fedora_packages"; then
	printf 'Debian package names leaked into Fedora build profile.\n' >&2
	exit 1
fi

printf 'Debian 13 DWM package map and APT install boundary: PASS\n'
