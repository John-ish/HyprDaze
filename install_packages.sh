#!/bin/bash

# --- Function to check for package and install ---
install_package() {
    PACKAGE=$1
    if ! command -v "$PACKAGE" &> /dev/null; then
        echo "Installing $PACKAGE..."
        sudo pacman -S --noconfirm "$PACKAGE"
    else
        echo "$PACKAGE is already installed."
    fi
}

sudo pacman -S --noconfirm figlet toilet

# --- Function to display welcome message ---
display_welcome() {
    # Check if 'toilet' is installed, otherwise use 'figlet'
    if command -v toilet &> /dev/null; then
        toilet -f mono12 -F metal "welcome to"
        toilet -f future -F metal "Hypr-Daze"
    elif command -v figlet &> /dev/null; then
        figlet "welcome to Hypr-Daze"
    else
        echo "=============================="
        echo " Welcome to Hypr-Daze "
        echo "=============================="
    fi
}

# --- Start of Script ---
display_welcome

echo "Starting prerequisite package installation..."

# Install basic tools and banner programs
install_package "git"
install_package "wget"
install_package "curl"
install_package "figlet"
# Note: 'toilet' is often in the official repos, so you can try installing it.
install_package "toilet"

# Install core packages from official repositories
CORE_PACKAGES="feh zoxide swww"
echo "Installing core packages: $CORE_PACKAGES"
sudo pacman -S --noconfirm $CORE_PACKAGES

# Install packages with potential external dependencies (like Yazi's recommended deps)
# Yazi, fzf often need specific versions or dependencies; we'll install general ones.
# Assuming official packages for yazi, fzf (may vary depending on repo state)
YAZI_FZF_DEPS="yazi fzf ripgrep fd"
echo "Installing file manager and search utilities: $YAZI_FZF_DEPS"
sudo pacman -S --noconfirm $YAZI_FZF_DEPS

# --- Install yay (AUR Helper) ---
echo "Checking for and installing yay (AUR Helper)..."
if ! command -v yay &> /dev/null; then
    echo "Installing 'yay'..."
    sudo pacman -S --noconfirm base-devel # base-devel is needed for building AUR packages
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd - > /dev/null # Go back to the previous directory
else
    echo "yay is already installed."
fi

# --- Install AUR packages using yay ---
# wpgtk: Often available in AUR
# Note: yay may prompt for sudo or confirmations on first run.
AUR_PACKAGES="wpgtk"
if command -v yay &> /dev/null; then
    echo "Installing AUR packages: $AUR_PACKAGES with yay..."
    yay -S --noconfirm $AUR_PACKAGES
else
    echo "yay not found. Skipping AUR package installation for $AUR_PACKAGES."
fi


# --- Install snapd (Snap Package Manager) ---
echo "Checking for and enabling snapd..."
if ! command -v snap &> /dev/null; then
    # Install snapd
    sudo pacman -S --noconfirm snapd

    # Enable and start the snapd socket
    sudo systemctl enable --now snapd.socket

    # Wait for the service to be ready and create the symlink
    echo "Waiting for snapd service to start and creating symlink..."
    sleep 5 # Give the system a few seconds to start the service

    # Create the symlink required for snap to work
    if [ ! -L /var/lib/snapd/snap ]; then
        sudo ln -s /var/lib/snapd/snap /snap
    fi
    echo "snapd installed and enabled."
else
    echo "snapd is already installed and running."
fi

# --- Install LazyVim (Requires Neovim and Git) ---
# NOTE: Neovim is a prerequisite for LazyVim. It is recommended to install
# Neovim first, ideally from an official source or a recent package.
echo "Installing Neovim (Prerequisite for LazyVim)..."
# Check if neovim is installed (assuming 'nvim' executable)
if ! command -v nvim &> /dev/null; then
    sudo pacman -S --noconfirm neovim
fi

echo "Installing LazyVim starter config..."
if [ -d "$HOME/.config/nvim" ]; then
    echo "Backing up existing Neovim config to $HOME/.config/nvim.bak"
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
fi
git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
rm -rf "$HOME/.config/nvim/.git" # Remove .git folder so it can be its own repo
echo "LazyVim starter installed. Run 'nvim' to finish the installation and download plugins."

echo "Installation script finished. Run 'nvim' to finalize LazyVim setup."
