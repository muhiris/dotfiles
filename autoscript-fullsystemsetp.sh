#!/bin/bash

################################################################################
# System Setup Automation Script
# Description: Automates the setup of a new Linux system with all my tools
# Author: Your Name
# Usage: sudo ./system-setup.sh
################################################################################

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "\n${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}➜ $1${NC}"
}

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "Please run this script with sudo"
        exit 1
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

################################################################################
# MAIN INSTALLATION SECTIONS
################################################################################

# Section 1: Install Basic Build Tools
install_build_tools() {
    print_header "Installing Build Tools"
    
    apt update
    apt install -y build-essential git curl wget
    
    print_success "Build tools installed"
}

# Section 2: Clone and Setup Dotfiles
setup_dotfiles() {
    print_header "Setting Up Dotfiles"
    
    cd /home/$SUDO_USER
    
    if [ -d "dotfiles" ]; then
        print_warning "dotfiles directory already exists, skipping clone"
    else
        sudo -u $SUDO_USER git clone https://github.com/muhiris/dotfiles.git
        print_success "Dotfiles cloned"
    fi
    
    # Create config directory if it doesn't exist
    sudo -u $SUDO_USER mkdir -p /home/$SUDO_USER/.config
    
    # Move starship config
    if [ -f "dotfiles/alacritty/starship.toml" ]; then
        sudo -u $SUDO_USER cp dotfiles/alacritty/starship.toml /home/$SUDO_USER/.config/
        print_success "Starship config copied"
    else
        print_warning "starship.toml not found in dotfiles"
    fi
}

# Section 3: Install Alacritty Terminal
install_alacritty() {
    print_header "Installing Alacritty Terminal"
    
    # Try quick install first
    print_info "Attempting quick install..."
    if apt install -y alacritty 2>/dev/null; then
        print_success "Alacritty installed from apt"
        return
    fi
    
    # Build from source if apt install fails
    print_info "Building Alacritty from source..."
    
    # Install Rust if not present
    if ! command_exists rustc; then
        print_info "Installing Rust..."
        sudo -u $SUDO_USER curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sudo -u $SUDO_USER sh -s -- -y
        source /home/$SUDO_USER/.cargo/env
    fi
    
    # Install dependencies
    apt install -y cmake pkg-config libfreetype6-dev libfontconfig1-dev \
        libxcb-xfixes0-dev libxkbcommon-dev python3 cargo
    
    # Clone and build
    cd /home/$SUDO_USER
    if [ -d "alacritty" ]; then
        rm -rf alacritty
    fi
    
    sudo -u $SUDO_USER git clone https://github.com/alacritty/alacritty.git
    cd alacritty
    
    sudo -u $SUDO_USER rustup override set stable
    sudo -u $SUDO_USER rustup update stable
    sudo -u $SUDO_USER cargo build --release
    
    # Install system-wide
    cp target/release/alacritty /usr/local/bin/
    cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
    desktop-file-install extra/linux/Alacritty.desktop
    update-desktop-database
    
    print_success "Alacritty built and installed"
}

# Section 4: Install Starship Prompt
install_starship() {
    print_header "Installing Starship Prompt"
    
    if command_exists starship; then
        print_warning "Starship already installed, skipping"
        return
    fi
    
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    
    # Add to bashrc if not already there
    if ! grep -q "starship init bash" /home/$SUDO_USER/.bashrc; then
        echo 'eval "$(starship init bash)"' >> /home/$SUDO_USER/.bashrc
        print_success "Starship added to .bashrc"
    fi
    
    print_success "Starship installed"
}

# Section 5: Install Nerd Fonts
install_fonts() {
    print_header "Installing Nerd Fonts"
    
    sudo -u $SUDO_USER mkdir -p /home/$SUDO_USER/.local/share/fonts
    
    if [ -d "/home/$SUDO_USER/dotfiles/CascadiaCode_Nerd Font" ]; then
        sudo -u $SUDO_USER cp -r "/home/$SUDO_USER/dotfiles/CascadiaCode_Nerd Font"/* \
            /home/$SUDO_USER/.local/share/fonts/
        fc-cache -fv
        print_success "Nerd Fonts installed"
    else
        print_warning "CascadiaCode Nerd Font not found in dotfiles"
    fi
}

# Section 6: Setup Flatpak
setup_flatpak() {
    print_header "Setting Up Flatpak"
    
    if ! command_exists flatpak; then
        apt install -y flatpak
        print_success "Flatpak installed"
    else
        print_warning "Flatpak already installed"
    fi
    
    # Add Flathub repo if not present
    if ! flatpak remote-list | grep -q flathub; then
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        print_success "Flathub repository added"
    fi
}

# Section 7: Install OBS Studio
install_obs() {
    print_header "Installing OBS Studio"
    
    if flatpak list | grep -q com.obsproject.Studio; then
        print_warning "OBS already installed"
    else
        flatpak install -y flathub com.obsproject.Studio
        print_success "OBS Studio installed"
    fi
}

# Section 8: Setup Virtual Camera for OBS
setup_virtual_camera() {
    print_header "Setting Up Virtual Camera (v4l2loopback)"
    
    # Install v4l2loopback if not present
    if ! lsmod | grep -q v4l2loopback; then
        apt install -y v4l2loopback-dkms v4l2loopback-utils
    fi
    
    # Create systemd service file
    cat > /etc/systemd/system/v4l2loopback.service << 'EOF'
[Unit]
Description=V4L2 Loopback Virtual Camera
DefaultDependencies=no
Before=sysinit.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStartPre=-/sbin/modprobe -r v4l2loopback
ExecStart=/sbin/modprobe v4l2loopback exclusive_caps=1
ExecStop=/sbin/modprobe -r v4l2loopback

[Install]
WantedBy=sysinit.target
EOF
    
    # Enable and start service
    systemctl enable v4l2loopback.service
    systemctl start v4l2loopback.service
    
    # Verify
    if systemctl is-active --quiet v4l2loopback.service; then
        print_success "Virtual camera service is running"
        lsmod | grep v4l2loopback && print_info "v4l2loopback module loaded"
    else
        print_error "Virtual camera service failed to start"
    fi
}

# Section 9: Enable Snap (for Ubuntu-based systems)
enable_snap() {
    print_header "Enabling Snap Support"
    
    # Backup nosnap.pref if it exists
    if [ -f /etc/apt/preferences.d/nosnap.pref ]; then
        mv /etc/apt/preferences.d/nosnap.pref /etc/apt/preferences.d/nosnap.backup
        print_success "Backed up nosnap.pref"
    fi
    
    apt update
    apt install -y snapd
    
    print_success "Snap enabled"
}

# Section 10: Install JDownloader2
install_jdownloader() {
    print_header "Installing JDownloader2"
    
    if snap list | grep -q jdownloader2; then
        print_warning "JDownloader2 already installed"
    else
        snap install jdownloader2
        print_success "JDownloader2 installed"
    fi
}

# Section 11: Install LocalSend
install_localsend() {
    print_header "Installing LocalSend"
    
    if flatpak list | grep -q org.localsend.localsend_app; then
        print_warning "LocalSend already installed"
    else
        flatpak install -y flathub org.localsend.localsend_app
        print_success "LocalSend installed"
    fi
}

# Section 12: Install Jackett
install_jackett() {
    print_header "Installing Jackett"
    
    cd /opt
    
    if [ -d "/opt/Jackett" ]; then
        print_warning "Jackett directory exists, removing old installation"
        rm -rf /opt/Jackett
    fi
    
    wget -Nc https://github.com/Jackett/Jackett/releases/latest/download/Jackett.Binaries.LinuxAMDx64.tar.gz
    tar -xzf Jackett.Binaries.LinuxAMDx64.tar.gz
    rm -f Jackett.Binaries.LinuxAMDx64.tar.gz
    
    chown $SUDO_USER:$(id -g $SUDO_USER) -R /opt/Jackett
    
    cd /opt/Jackett
    ./install_service_systemd.sh
    
    systemctl start jackett.service
    
    print_success "Jackett installed - Visit http://127.0.0.1:9117"
}

# Section 13: Install Development Tools
install_dev_tools() {
    print_header "Installing Development Tools"
    
    # VS Code
    if ! snap list | grep -q code; then
        snap install code --classic
        print_success "VS Code installed"
    fi
    
    # Brave Browser
    if ! snap list | grep -q brave; then
        snap install brave
        print_success "Brave installed"
    fi
}

# Section 14: Install Media & Torrent Tools
install_media_tools() {
    print_header "Installing Media & Torrent Tools"
    
    # qBittorrent
    if ! command_exists qbittorrent; then
        apt install -y qbittorrent
        print_success "qBittorrent installed"
    fi
    
    # VLC
    if ! command_exists vlc; then
        apt install -y vlc
        print_success "VLC installed"
    fi
}

# Section 15: Install WiFi Hotspot
install_wifi_hotspot() {
    print_header "Installing Linux WiFi Hotspot"
    
    # Install dependencies
    apt install -y libgtk-3-dev build-essential gcc g++ pkg-config make \
        hostapd libqrencode-dev libpng-dev
    
    cd /home/$SUDO_USER
    
    if [ -d "linux-wifi-hotspot" ]; then
        rm -rf linux-wifi-hotspot
    fi
    
    sudo -u $SUDO_USER git clone https://github.com/lakinduakash/linux-wifi-hotspot
    cd linux-wifi-hotspot
    
    make
    make install
    
    cd ..
    rm -rf linux-wifi-hotspot
    
    print_success "Linux WiFi Hotspot installed"
}

# Section 16: Install Communication Tools
install_communication_tools() {
    print_header "Installing Communication Tools"
    
    # Slack
    if ! snap list | grep -q slack; then
        snap install slack --classic
        print_success "Slack installed"
    fi
    
    # Google Chrome
    if ! snap list | grep -q google-chrome; then
        snap install google-chrome
        print_success "Google Chrome installed"
    fi
    
    # Zoom
    if ! snap list | grep -q zoom-client; then
        snap install zoom-client
        print_success "Zoom installed"
    fi
}

# Section 17: Install NordVPN
install_nordvpn() {
    print_header "Installing NordVPN"
    
    if command_exists nordvpn; then
        print_warning "NordVPN already installed"
    else
        sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)
        print_success "NordVPN installed"
    fi
}

# Section 18: Install OBS Runner Script
install_obs_runner() {
    print_header "Installing OBS Runner Script"
    
    if [ -f "/home/$SUDO_USER/dotfiles/obs-runner.sh" ]; then
        cp /home/$SUDO_USER/dotfiles/obs-runner.sh /usr/local/bin/obs-runner
        chmod +x /usr/local/bin/obs-runner
        print_success "OBS Runner installed - run with: sudo obs-runner"
    else
        print_warning "obs-runner.sh not found in dotfiles"
    fi
}

################################################################################
# MAIN EXECUTION
################################################################################

main() {
    print_header "System Setup Automation Script"
    
    check_root
    
    print_info "This script will install and configure your entire system"
    print_info "Press Ctrl+C to cancel, or Enter to continue..."
    read
    
    # Execute all installation sections
    install_build_tools
    setup_dotfiles
    install_alacritty
    install_starship
    install_fonts
    setup_flatpak
    install_obs
    setup_virtual_camera
    enable_snap
    install_jdownloader
    install_localsend
    install_jackett
    install_dev_tools
    install_media_tools
    install_wifi_hotspot
    install_communication_tools
    install_nordvpn
    install_obs_runner
    
    print_header "Installation Complete!"
    print_success "All tools have been installed successfully"
    print_info "Please restart your terminal or run: source ~/.bashrc"
    print_info "You may need to log out and back in for all changes to take effect"
}

# Run main function
main
