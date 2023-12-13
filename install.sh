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
    if type 'pacman' > /dev/null 2>&1; then
        sudo pacman -S fish kitty ranger bat pasystray pavucontrol playerctl picom xscreensaver rofi jgmenu lxmenu-data polybar i3-wm arandr lxrandr lxappearance zathura zathura-pdf-mupdf feh nitrogen neofetch neovim htop jq galculator arc-gtk-theme papirus-icon-theme nerd-fonts ripgrep
    elif type 'zypper' > /dev/null 2>&1; then
        sudo zypper in fish kitty ranger bat pasystray pavucontrol playerctl picom xscreensaver xscreensaver-data xscreensaver-data-extra rofi jgmenu lxmenu-data polybar i3 arandr lxrandr lxappearance zathura feh nitrogen neofetch neovim htop jq metatheme-arc-common papirus-icon-theme ripgrep
    elif type 'apt' > /dev/null 2>&1; then
        sudo apt install fish kitty ranger bat pasystray pavucontrol playerctl picom xscreensaver xscreensaver-data-extra xscreensaver-gl-extra rofi jgmenu lxmenu-data polybar i3-wm suckless-tools arandr lxrandr lxappearance zathura feh nitrogen neofetch htop jq galculator arc-theme papirus-icon-theme ripgrep
        sudo dpkg -i system/nvim-linux64.deb
    fi
}

# Function to install nerd fonts
install_nerd_fonts() {
    echo 'This will clone github.com/ryanoasis/nerd-fonts to .ignore/ in this directory and can take a while'
    git clone --depth=1 https://github.com/ryanoasis/nerd-fonts.git .ignore/nerd-fonts/
    echo 'Installing nerd-fonts'
    bash .ignore/nerd-fonts/install.sh
    echo 'Font configured by default is FantasqueSansM Nerd Font'
}

# Function to install dotfiles
install_dotfiles() {
    cp -Trv HOME/ ~/
}

# Function to install nvchad
install_nvchad() {
    rm -rfv ~/.config/nvim
    rm -rfv ~/.local/share/nvim
    git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
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

# Function to install Firefox profile
install_firefox_profile() {
    pkill firefox*
    rm -rfv ~/.mozilla
    tar xvf system/wildy.tar.bz2 -C ~/
}

# Main function
main() {
    echo "Choose tasks to perform:"
    install_dependencies_var=$(ask_user "Install dependencies")
    install_nerd_fonts_var=$(ask_user "Install nerd fonts")
    install_dotfiles_var=$(ask_user "Install dotfiles")
    install_nvchad_var=$(ask_user "Install nvchad")
    install_network_config_var=$(ask_user "Install network configuration")
    echo "Wildy Firefox profile is only compatible with Firefox ESR."
    install_firefox_profile_var=$(ask_user "Install Firefox profile")

    [[ "$install_dependencies_var" == "Y" ]] && install_dependencies
    [[ "$install_nerd_fonts_var" == "Y" ]] && install_nerd_fonts
    [[ "$install_dotfiles_var" == "Y" ]] && install_dotfiles
    [[ "$install_nvchad_var" == "Y" ]] && install_nvchad
    [[ "$install_network_config_var" == "Y" ]] && install_network_config
    [[ "$install_firefox_profile_var" == "Y" ]] && install_firefox_profile
}

# Run the main function
main

