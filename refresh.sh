#!/bin/sh

set -xe

PWD=$(pwd)
cd ~/.local/new-dotfiles

cp -r ~/.config/conky/ .
cp -r ~/.config/dunst/ .
cp -r ~/.config/polybar/ .
cp -r ~/.config/qtile/ .

cp -r ~/Scripts/ .
cp -r ~/Documents/wallpaper.jpeg ./wallpaper.jpeg
cp -r ~/.Xresources ./.Xresources
cp -r /etc/environment ./etc/environment
cp -r /etc/mkinitcpio.d/linux-zen.preset ./etc/mkinitcpio.d/linux-zen-preset

cp -r ~/.emacs.d/init.el ./.emacs.d/init.el
cp -r ~/.emacs.d/custom.el ./.emacs.d/custom.el
cp -r ~/.emacs.d/custom-packages/ ./.emacs.d/
cp -r ~/.emacs.d/snippets/ ./.emacs.d/

git add .
git commit -m "updet"
git push

cd $PWD
