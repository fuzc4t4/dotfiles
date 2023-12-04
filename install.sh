#!/usr/bin/env bash

echo 'Installing dependencies'

if type 'pacman' > /dev/null 2>&1; then
  sudo pacman -S fish kitty ranger bat pasystray pavucontrol playerctl picom xscreensaver rofi polybar i3-wm arandr lxrandr lxappearance zathura zathura-pdf-mupdf feh nitrogen neofetch neovim htop jq galculator arc-gtk-theme papirus-icon-theme nerd-fonts
fi
if type 'zypper' > /dev/null 2>&1; then
  sudo zypper in fish kitty ranger bat pasystray pavucontrol playerctl picom xscreensaver xscreensaver-data xscreensaver-data-extra rofi polybar i3 arandr lxrandr lxappearance zathura feh nitrogen neofetch neovim htop jq metatheme-arc-common papirus-icon-theme
fi
if type 'apt' > /dev/null 2>&1; then
  sudo apt install fish kitty ranger bat pasystray pavucontrol playerctl picom xscreensaver xscreensaver-data-extra xscreensaver-gl-extra rofi polybar i3-wm suckless-tools arandr lxrandr lxappearance zathura feh nitrogen neofetch htop jq galculator arc-theme papirus-icon-theme
  sudo dpkg -i system/nvim-linux64.deb
fi

echo 'Do you want to install nerd fonts?'
echo 'This will clone github.com/ryanoasis/nerd-fonts to .ignore/ in this directory and can take a while'
echo '(Type y to install them or anything else to not install them)'
read install_nf
typeset -l install_nf
if [ $install_nf = 'y' ]; then
  git clone --depth=1 https://github.com/ryanoasis/nerd-fonts.git .ignore/nerd-fonts/
  echo 'Installing nerd-fonts'
  bash .ignore/nerd-fonts/install.sh
else
  echo 'Font configured by default is Iosevka Nerd Font'
fi

echo 'Copying dotfiles'
cp -Trv .config ~/.config/
cp -Trv .local ~/.local/
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
echo 'Dotfiles copied'

echo 'Setting up network configuration:'
sudo cp -v system/50-macrandomize.conf /etc/NetworkManager/conf.d/
loopbackName=$(cat /etc/hostname)
if [ ${#loopbackName} -gt 0 ]; then
  sudo cp -v /dev/null /etc/hostname
  sudo hostnamectl set-hostname --transient $loopbackName
fi
sudo systemctl restart NetworkManager
