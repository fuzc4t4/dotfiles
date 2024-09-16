#!/usr/bin/env bash

# Function to ask user for Y/n input
ask_user() {
  local prompt="$1"
  local response
  read -p "$prompt (Y/n): " response
  response=${response,,} # Convert to lowercase
  if [[ "$response" == "y" ]]; then
    echo "Y"
  elif [[ "$response" == "n" ]]; then
    echo "N"
  else
    echo "Invalid input. Please enter Y or n."
    ask_user "$prompt"
  fi
}

# Function to install dependencies
install_dependencies() {
  if type 'dnf' >/dev/null 2>&1; then
    sudo dnf in arandr arc-theme bat fd-find feh fish galculator htop i3 jgmenu jq kitty lxappearance lxmenu-data lxrandr neofetch neovim nitrogen papirus-icon-theme pasystray pavucontrol picom playerctl polybar ranger ripgrep rofi xscreensaver zathura
  elif type 'apt' >/dev/null 2>&1; then
    sudo apt install arandr arc-theme bat fd-find feh fish galculator htop i3-wm jgmenu jq kitty lxappearance lxmenu-data lxrandr neofetch neovim nitrogen papirus-icon-theme pasystray pavucontrol picom playerctl polybar ranger ripgrep rofi suckless-tools xscreensaver xscreensaver-data-extra xscreensaver-gl-extra zathura
  elif type 'pacman' >/dev/null 2>&1; then
    sudo pacman -S arandr arc-gtk-theme bat fd feh fish galculator htop i3-wm jgmenu jq kitty lxappearance lxmenu-data lxrandr neofetch neovim nerd-fonts nitrogen papirus-icon-theme pasystray pavucontrol picom playerctl polybar ranger ripgrep rofi xscreensaver zathura zathura-pdf-mupdf
  elif type 'zypper' >/dev/null 2>&1; then
    sudo zypper in arandr bat fd feh fish galculator htop i3 jgmenu jq kitty lxappearance lxmenu-data lxrandr metatheme-arc-common neofetch neovim nitrogen papirus-icon-theme pasystray pavucontrol picom playerctl polybar ranger ripgrep rofi xscreensaver xscreensaver-data xscreensaver-data-extra zathura
  fi
}

# Function to install nerd fonts
install_nerd_fonts() {
  echo 'Installing FantasqueSansM nerd-font'
  mkdir -p .ignore
  curl --output-dir .ignore -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FantasqueSansMono.tar.xz
  mkdir -p ~/.local/share/fonts/NerdFonts
  tar -xf ./.ignore/FantasqueSansMono.tar.xz -C ~/.local/share/fonts/NerdFonts
}

# Function to install dotfiles
install_dotfiles() {
  cp -Trv HOME/ ~/
}

# Function to install lazyvim
install_lazyvim() {
  rm -rfv ~/.config/nvim
  rm -rfv ~/.local/share/nvim
  rm -rfv ~/.cache/nvim
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  echo 'return {
  { "shaunsingh/nord.nvim" },
  { "rmehri01/onenord.nvim" },
  { "AlexvZyl/nordic.nvim" },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nordic",
    },
  },
  }' >~/.config/nvim/lua/plugins/colorschemes.lua
}

# Function to install network configuration
install_network_config() {
  echo 'Setting up network configuration:'
  sudo cp -v system/50-macrandomize.conf /etc/NetworkManager/conf.d/
  loopbackName=$(cat /etc/hostname)
  if [ ${#loopbackName} -gt 0 ]; then
    sudo cp -v /dev/null /etc/hostname
    sudo hostnamectl set-hostname --transient $loopbackName
  fi
  sudo systemctl restart NetworkManager
}

# Main function
main() {
  echo "Choose tasks to perform:"
  install_dependencies_var=$(ask_user "Install dependencies")
  install_nerd_fonts_var=$(ask_user "Install nerd fonts")
  install_dotfiles_var=$(ask_user "Install dotfiles")
  install_lazyvim_var=$(ask_user "Install lazyvim")
  install_network_config_var=$(ask_user "Install network configuration")

  [[ "$install_dependencies_var" == "Y" ]] && install_dependencies
  [[ "$install_nerd_fonts_var" == "Y" ]] && install_nerd_fonts
  [[ "$install_dotfiles_var" == "Y" ]] && install_dotfiles
  [[ "$install_lazyvim_var" == "Y" ]] && install_lazyvim
  [[ "$install_network_config_var" == "Y" ]] && install_network_config
}

# Run the main function
main
