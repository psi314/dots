#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <username> <timezone>" >&2
    echo "Example: $0 jim America/New_York" >&2
    exit 1
fi

USERNAME="$1"
TIMEZONE="$2"

if [[ ! -e "/usr/share/zoneinfo/$TIMEZONE" ]]; then
    echo "Error: timezone '$TIMEZONE' does not exist in /usr/share/zoneinfo" >&2
    exit 1
fi

IMP_PKGS=(
    "base-devel"
    "bluez"
    "bluez-utils"
    "git"
    "intel-ucode"
    "linux"
    "linux-firmware-intel"
    "linux-firmware-other"
    "linux-firmware-realtek"
    "networkmanager"
    "sof-firmware"
    "sudo"
    "thermald"
    "ufw"
)

WAYLAND_WM_PACKAGES=(
    "brightnessctl"
    "hypridle"
    "hyprlock"
    "mangowm-git"
    "rofi"
    "swaybg"
    "wl-clip-persist"
    "wl-clipboard"
    "wlopm"
    "wlsunset"
    "xdg-desktop-portal-gtk"
    "xdg-desktop-portal-wlr"
    "xdg-utils"
)

AUDIO_PACKAGES=(
    "pipewire"
    "pipewire-alsa"
    "pipewire-jack"
    "pipewire-pulse"
)

UTILITY_PACKAGES=(
    "alacritty"
    "aria2"
    "btop"
    "dunst"
    "eza"
    "fastfetch"
    "ffmpegthumbnailer"
    "fish"
    "gamemode"
    "gvfs"
    "gvfs-mtp"
    "imagemagick"
    "jq"
    "less"
    "man-db"
    "mpv"
    "ncdu"
    "neovim"
    "openssh"
    "power-profiles-daemon"
    "python-gobject"
    "rustup"
    "stow"
    "thunar"
    "tumbler"
    "visual-studio-code-bin"
)

GRAPHICS_PACKAGES=(
    "intel-media-driver"
    "vulkan-icd-loader"
    "vulkan-intel"
    "vpl-gpu-rt"
    "intel-compute-runtime"
)

THEME_PACKAGES=(
    "adw-gtk-theme"
    "breeze"
    "breeze-cursors"
    "gnu-free-fonts"
    "matugen"
    "noto-fonts-emoji"
    "nwg-look"
    "papirus-icon-theme"
    "qt6ct-kde"
    "ttf-jetbrains-mono"
)

install_packages() {
    local package

    for package in "$@"; do
        pacman -S "$package" --noconfirm
    done
}

update_system() {
    pacman -Syu --noconfirm
}

enable_service() {
    local service="$1"
    local is_user="${2:-false}"

    if [[ "$is_user" == "true" ]]; then
        systemctl --user enable "$service"
        systemctl --user start "$service"
    else
        systemctl enable "$service"
        systemctl start "$service"
    fi
}

disable_service() {
    local service="$1"
    local is_user="${2:-false}"

    if [[ "$is_user" == "true" ]]; then
        systemctl --user disable "$service"
        systemctl --user mask "$service"
        systemctl --user stop "$service"
    else
        systemctl disable "$service"
        systemctl mask --now "$service"
        systemctl stop "$service"
    fi
}

create_user() {
    useradd -m -G wheel,audio,video "$USERNAME"
    echo "Please set a password for the new user:"
    passwd "$USERNAME"
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" | tee  /etc/sudoers.d/wheel
}

setup_locales() {
    sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    locale-gen
    echo "LANG=en_US.UTF-8" | tee /etc/locale.conf
    echo "KEYMAP=us" | tee /etc/vconsole.conf
}

setup_grub() {
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
    grub-mkconfig -o /boot/grub/grub.cfg
}

setup_timezone() {
    ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
    hwclock --systohc
}

setup_yay() {
    mkdir -p "$HOME/Projects"
    local yay_dir="$HOME/Projects/yay"
    git clone https://aur.archlinux.org/yay-bin.git "$yay_dir"
    (cd "$yay_dir" && makepkg -si --noconfirm)
    rm -rf "$yay_dir"
}

setup_dotfiles() {
    cp -r "$(pwd)/dots" "$HOME/dots"
    (cd "$HOME/dots" && stow -t "$HOME/.config" */)
}

setup_root_password() {
    echo "Please set a password for the root user:"
    passwd
}

setup_rust() {
    rustup toolchain install stable
    rustup component add rust-analyzer
    rustup component add rust-src
}

run_as_user() {
    sudo -u "$USERNAME" -H "$@"
}

run_function_as_user() {
    local func_name="$1"
    shift
    sudo -u "$USERNAME" -H bash -c "$(declare -f "$func_name"); $func_name $@"
}

main() {
    update_system
    install_packages "${IMP_PKGS[@]}"
    setup_locales
    setup_timezone
    setup_grub
    disable_service "systemd-networkd.service"
    disable_service "systemd-userdbd.service"
    disable_service "systemd-networkd.socket"
    disable_service "systemd-userdbd.socket"
    disable_service "NetworkManager-wait-online.service"
    enable_service "NetworkManager"
    enable_service "thermald"
    setup_root_password
    create_user 
    run_function_as_user setup_yay
    run_as_user yay -S --noconfirm "${AUDIO_PACKAGES[@]}" 
    enable_service "pipewire" true
    enable_service "pipewire-pulse" true
    enable_service "wireplumber" true
    run_as_user yay -S --noconfirm "${GRAPHICS_PACKAGES[@]}"
    run_as_user yay -S --noconfirm "${WAYLAND_WM_PACKAGES[@]}"
    run_as_user yay -S --noconfirm "${UTILITY_PACKAGES[@]}"
    run_as_user yay -S --noconfirm "${THEME_PACKAGES[@]}"
    run_function_as_user setup_dotfiles
    run_as_user setup_rust
    echo "%wheel ALL=(ALL) ALL" | tee /etc/sudoers.d/wheel
}

main "$@"