#!/usr/bin/env bash
# Shared Debian package capability map for installers and diagnostics.

dwm_packages() {
	local family=$1
	local profile=$2

	case "$family:$profile" in
	debian:provider-policy)
		printf '%s\n' $'xserver-xorg-core\txserver\tXorg'
		;;
	debian:build)
		printf '%s\n' build-essential pkg-config libx11-dev libxft-dev libxinerama-dev \
			libxrender-dev libimlib2-dev libxcb1-dev libxcb-res0-dev libfontconfig1-dev libfreetype-dev
		;;
	debian:ci-smoke)
		dwm_packages "$family" build
		printf '%s\n' quickshell python3 dbus-daemon util-linux procps \
			xvfb xdotool x11-utils x11-xserver-utils xsettingsd jq inotify-tools \
			fonts-noto-core xkb-data xinput x11-utils
		;;
	debian:x11)
		printf '%s\n' xserver-xorg-core xinit x11-xserver-utils x11-xkb-utils xinput xkbset
		;;
	debian:runtime-required)
		printf '%s\n' dbus-x11 curl git procps psmisc unzip util-linux xclip xdotool \
			x11-utils xdg-utils gnome-keyring libpam-gnome-keyring
		;;
	debian:keyring)
		printf '%s\n' gnome-keyring libpam-gnome-keyring
		;;
	debian:desktop)
		# DWM session services and the managed Quickshell shell. Quickshell is
		# published in Debian 13 backports; users need that suite enabled.
		printf '%s\n' quickshell thunar picom python3 feh dex mate-polkit xsettingsd \
			bubblewrap libseccomp2 alsa-utils brightnessctl dbus-bin inotify-tools jq \
			pulseaudio-utils pipewire pipewire-pulse wireplumber libnotify-bin power-profiles-daemon systemd-timesyncd \
			light-locker xserver-xorg-input-libinput bluez blueman playerctl upower \
			flatpak xdg-desktop-portal-gtk network-manager-gnome
		;;
	debian:source-update)
		printf '%s\n' xsettingsd xkbset bubblewrap libseccomp2
		dwm_packages "$family" keyring
		;;
	debian:theme)
		printf '%s\n' dconf-gsettings-backend adwaita-icon-theme papirus-icon-theme
		;;
	debian:theme-gtk)
		printf '%s\n' arc-theme yaru-theme-gtk yaru-theme-icon
		;;
	debian:theme-optional)
		printf '%s\n' qt6ct qt5ct
		;;
	debian:fonts)
		printf '%s\n' fonts-noto-color-emoji fonts-noto-mono
		;;
	debian:qml-development)
		printf '%s\n' qt6-declarative-dev qt6-declarative-dev-tools
		;;
	debian:qml-validation)
		printf '%s\n' quickshell xsettingsd
		dwm_packages "$family" qml-development
		;;
	debian:lightdm)
		printf '%s\n' lightdm slick-greeter
		;;
	debian:terminal)
		printf '%s\n' alacritty kitty
		;;
	debian:terminal-primary)
		printf '%s\n' alacritty
		;;
	debian:screenshot-optional)
		printf '%s\n' maim
		;;
	debian:media)
		printf '%s\n' celluloid mpv sxiv python3 desktop-file-utils
		;;
	debian:system-management)
		printf '%s\n' packagekit packagekit-tools libpackagekit-glib2-18 gir1.2-packagekitglib-1.0 python3-gi python3-apt accountsservice cups system-config-printer
		;;
	debian:required)
		dwm_packages "$family" build
		dwm_packages "$family" x11
		dwm_packages "$family" runtime-required
		dwm_packages "$family" media
		;;
	debian:recommended)
		dwm_packages "$family" desktop
		dwm_packages "$family" screenshot-optional
		dwm_packages "$family" theme
		dwm_packages "$family" theme-gtk
		dwm_packages "$family" fonts
		;;
	debian:optional)
		dwm_packages "$family" theme-optional
		;;
	debian:full)
		dwm_packages "$family" required
		dwm_packages "$family" recommended
		dwm_packages "$family" optional
		;;

	*)
		return 1
		;;
	esac
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	[[ $# == 2 ]] || {
		printf 'usage: %s FAMILY PROFILE\n' "$0" >&2
		exit 2
	}
	dwm_packages "$1" "$2"
	exit $?
fi

dwm_install_package_profile() {
	local profile=$1
	local packages=()
	local package

	while IFS= read -r package; do
		[[ -n $package ]] || continue
		if dwm_package_provider_installed "$package"; then
			printf '%s\n' \
				"Retaining installed provider; skipping $package." >&2
			continue
		fi
		packages+=("$package")
	done < <(dwm_packages "$DISTRO_FAMILY" "$profile")

	if ((${#packages[@]} == 0)); then
		return 0
	fi

	install_packages "${packages[@]}"
}

dwm_package_provider_installed() {
	local package=$1 candidate capability commands command
	local -a alternatives=()
	while IFS=$'\t' read -r candidate capability commands; do
		[[ $candidate == "$package" ]] || continue
		IFS=, read -r -a alternatives <<<"$commands"
		for command in "${alternatives[@]}"; do
			[[ $command == - ]] || { command -v "$command" >/dev/null 2>&1 && return 0; }
		done
		case "$DISTRO_FAMILY" in
		debian) package_installed "$candidate" ;;
		esac
		return $?
	done < <(dwm_packages "$DISTRO_FAMILY" provider-policy)
	return 1
}

dwm_install_available_package_profile() {
	local profile=$1
	local package
	local status=0

	while IFS= read -r package; do
		[[ -n $package ]] || continue
		if ! install_optional_package "$package"; then
			printf 'Skipping unavailable optional package: %s\n' "$package" >&2
			status=1
		fi
	done < <(dwm_packages "$DISTRO_FAMILY" "$profile")

	return "$status"
}

dwm_install_first_available_package() {
	local package

	for package in "$@"; do
		if install_optional_package "$package" 2>/dev/null; then
			return 0
		fi
	done

	return 1
}

dwm_install_first_available_profile() {
	local profile=$1
	local packages=()
	local package

	while IFS= read -r package; do
		[[ -n $package ]] && packages+=("$package")
	done < <(dwm_packages "$DISTRO_FAMILY" "$profile")

	if ((${#packages[@]} == 0)); then
		return 1
	fi

	dwm_install_first_available_package "${packages[@]}"
}
