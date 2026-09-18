#!/bin/sh

PWD=$(pwd)
cd ~/.local/new-dotfiles

cp -r ~/.config/conky/ ./conky/
cp -r ~/.config/dunst/ ./dunst/
cp -r ~/.config/polybar/ ./polybar/
cp -r ~/.config/qtile/ ./qtile/

cp -r ~/Scripts/ ./Scripts/
cp -r ~/Documents/wallpaper.jpeg ./wallpaper.jpeg
cp -r ~/.Xresources ./.Xresources
cp -r /etc/environment ./etc/environment

cp -r ~/.emacs.d/init.el ./.emacs.d/init.el
cp -r ~/.emacs.d/custom.el ./.emacs.d/custom.el
cp -r ~/.emacs.d/custom-packages/ ./.emacs.d/custom-packages/
cp -r ~/.emacs.d/snippets/ ./.emacs.d/snippets/

git add .
git commit -m "updet"
git push

cd $PWD
