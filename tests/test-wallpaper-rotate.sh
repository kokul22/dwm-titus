#!/usr/bin/env bash
set -euo pipefail

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
mkdir -p "$work/bin" "$work/Pictures"

cat >"$work/bin/sleep" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
cat >"$work/bin/xset" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
count=0
[[ ! -s ${DWM_TEST_XSET_COUNT_FILE:?} ]] || read -r count <"$DWM_TEST_XSET_COUNT_FILE"
printf '%s\n' "$((count + 1))" >"$DWM_TEST_XSET_COUNT_FILE"
[[ $count -eq 0 ]]
EOF
cat >"$work/wallpaper-helper" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
[[ $# -eq 1 && $1 == randomize ]]
printf '%s\n' "$DWM_APPEARANCE_WALLPAPER_DIR" >"$DWM_TEST_ROTATION_DIR_FILE"
EOF
chmod +x "$work/bin/sleep" "$work/bin/xset" "$work/wallpaper-helper" "$repo/scripts/dwm-wallpaper-rotate"

HOME=$work \
PATH="$work/bin:/usr/bin:/bin" \
DISPLAY=:test \
DWM_TEST_XSET_COUNT_FILE="$work/xset-count" \
DWM_TEST_ROTATION_DIR_FILE="$work/rotation-dir" \
DWM_WALLPAPER_ROTATE_DIR="$work/Pictures" \
DWM_WALLPAPER_ROTATE_INTERVAL=1 \
DWM_WALLPAPER_ROTATE_CHECK_INTERVAL=1 \
DWM_SETTINGS_WALLPAPER_HELPER="$work/wallpaper-helper" \
	"$repo/scripts/dwm-wallpaper-rotate"

[[ $(cat "$work/rotation-dir") == "$work/Pictures" ]]
