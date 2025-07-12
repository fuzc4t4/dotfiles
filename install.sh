#!/usr/bin/env bash

# Get script directory for reliable path references
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Y/n prompt with validation
ask_user() {
  local prompt="$1"
  local response
  while true; do
    read -p "$prompt (Y/n): " -n 1 -r response
    echo
    case "$response" in
      [Yy]|"") return 0 ;;
      [Nn]) return 1 ;;
      *) echo "Invalid input. Please enter Y or n." ;;
    esac
  done
}

# Function to install dependencies
install_dependencies() {
  echo "Installing dependencies..."
  if type 'dnf' >/dev/null 2>&1; then
    sudo dnf install -y arandr arc-theme bat fd-find feh fish galculator htop i3 jgmenu jq kitty lxappearance lxmenu-data lxrandr neofetch neovim nitrogen papirus-icon-theme pasystray pavucontrol picom playerctl polybar ranger ripgrep rofi xscreensaver zathura
  elif type 'apt' >/dev/null 2>&1; then
    sudo apt install -y arandr arc-theme bat fd-find feh fish galculator htop i3-wm jgmenu jq kitty lxappearance lxmenu-data lxrandr neofetch neovim nitrogen papirus-icon-theme pasystray pavucontrol picom playerctl polybar ranger ripgrep rofi suckless-tools xscreensaver xscreensaver-data-extra xscreensaver-gl-extra zathura
  elif type 'pacman' >/dev/null 2>&1; then
    sudo pacman -S --noconfirm arandr arc-gtk-theme bat fd feh fish galculator htop i3-wm jgmenu jq kitty lxappearance lxmenu-data lxrandr neofetch neovim nerd-fonts nitrogen papirus-icon-theme pasystray pavucontrol picom playerctl polybar ranger ripgrep rofi xscreensaver zathura zathura-pdf-mupdf
  elif type 'zypper' >/dev/null 2>&1; then
    sudo zypper in -y arandr bat fd feh fish galculator htop i3 jgmenu jq kitty lxappearance lxmenu-data lxrandr metatheme-arc-common neofetch neovim nitrogen papirus-icon-theme pasystray pavucontrol picom playerctl polybar ranger ripgrep rofi xscreensaver xscreensaver-data xscreensaver-data-extra zathura
  else
    echo "Error: No supported package manager found!"
    return 1
  fi
}

# Function to install maple font
install_maple_font() {
  echo "Installing Maple Mono font..."
  FONT_DIR="${HOME}/.local/share/fonts/maple"
  mkdir -p "$FONT_DIR"

  if ! command -v curl &> /dev/null; then
    echo "Error: curl required but not found!"
    return 1
  fi
  
  if ! command -v unzip &> /dev/null; then
    echo "Error: unzip required but not found!"
    return 1
  fi

  if curl -L -o "${FONT_DIR}/MapleMono-NF.zip" "https://github.com/subframe7536/maple-font/releases/download/v7.4/MapleMono-NF.zip"; then
    unzip -qo "${FONT_DIR}/MapleMono-NF.zip" -d "$FONT_DIR"
    rm -f "${FONT_DIR}/MapleMono-NF.zip"
    fc-cache -fv
  else
    echo "Error: Failed to download font!"
    return 1
  fi
}

# Function to install dotfiles
install_dotfiles() {
  echo "Installing dotfiles..."
  if [[ -d "${SCRIPT_DIR}/HOME" ]]; then
    cp -Trv "${SCRIPT_DIR}/HOME" "${HOME}"
  else
    echo "Error: Dotfiles directory not found!"
    return 1
  fi
}

# Function to install lazyvim
install_lazyvim() {
  echo "Installing LazyVim..."
  rm -rf "${HOME}/.config/nvim"
  rm -rf "${HOME}/.local/share/nvim"
  rm -rf "${HOME}/.cache/nvim"

  if ! command -v git &> /dev/null; then
    echo "Error: git required but not found!"
    return 1
  fi

  git clone https://github.com/LazyVim/starter "${HOME}/.config/nvim"
  mkdir -p "${HOME}/.config/nvim/lua/plugins"

  cat > "${HOME}/.config/nvim/lua/plugins/colorschemes.lua" << 'EOL'
return {
  { "shaunsingh/nord.nvim" },
  { "rmehri01/onenord.nvim" },
  { "AlexvZyl/nordic.nvim" },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nordic",
    },
  },
}
EOL
}

# Function to install spacemacs
install_spacemacs() {
  echo "Installing Spacemacs..."
  if ! command -v git &> /dev/null; then
    echo "Error: git required but not found!"
    return 1
  fi
  rm -rf "${HOME}/.emacs.d"
  rm -rf "${HOME}/.emacs"
  git clone https://github.com/syl20bnr/spacemacs "${HOME}/.emacs.d"
}

# Function to install network configuration
install_network_config() {
  echo "Setting up network configuration..."
  if [[ -f "${SCRIPT_DIR}/system/50-macrandomize.conf" ]]; then
    sudo cp -v "${SCRIPT_DIR}/system/50-macrandomize.conf" /etc/NetworkManager/conf.d/
    loopbackName=$(cat /etc/hostname)
    if [[ -n "$loopbackName" ]]; then
      sudo cp -f /dev/null /etc/hostname
      sudo hostnamectl set-hostname --transient "$loopbackName"
    fi
    sudo systemctl restart NetworkManager
  else
    echo "Error: Network config file not found!"
    return 1
  fi
}

# Function to install firefox policy
install_firefox_policy() {
  echo "Installing Firefox policy..."
  rm -rf "${HOME}/.mozilla"
  POLICY_DIR="/etc/firefox/policies"
  if [[ -f "${SCRIPT_DIR}/system/policies.json" ]]; then
    sudo mkdir -p "$POLICY_DIR"
    sudo cp -v "${SCRIPT_DIR}/system/policies.json" "$POLICY_DIR/"
  else
    echo "Error: policies.json not found!"
    return 1
  fi
}

# Display menu
show_menu() {
  clear
  echo -e "\n\033[1;34mDotfiles Installation Menu\033[0m"
  echo "1. Install dependencies"
  echo "2. Install Maple Mono font"
  echo "3. Install dotfiles"
  echo "4. Install LazyVim"
  echo "5. Install Spacemacs"
  echo "6. Configure network"
  echo "7. Install Firefox policy"
  echo -e "8. \033[1;32mRun ALL configurations\033[0m"
  echo -e "0. \033[1;31mExit\033[0m"
}

# Main function
main() {
  while true; do
    show_menu
    read -p "Select an option (0-8): " choice
    
    case $choice in
      1) ask_user "Install dependencies?" && install_dependencies ;;
      2) ask_user "Install Maple Mono font?" && install_maple_font ;;
      3) ask_user "Install dotfiles?" && install_dotfiles ;;
      4) ask_user "Install LazyVim?" && install_lazyvim ;;
      5) ask_user "Install Spacemacs?" && install_spacemacs ;;
      6) ask_user "Configure network?" && install_network_config ;;
      7) ask_user "Install Firefox policy?" && install_firefox_policy ;;
      8)
        ask_user "Run ALL configurations?" && {
          install_dependencies
          install_maple_font
          install_dotfiles
          install_lazyvim
          install_spacemacs
          install_network_config
          install_firefox_policy
        }
        ;;
      0) echo "Exiting..."; exit 0 ;;
      *) echo "Invalid option!" ;;
    esac

    read -n 1 -s -r -p "Press any key to continue..."
  done
}

# Run the main function
main
