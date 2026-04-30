this_script=$(readlink -f "$0")
script_dir=$(dirname "$this_script")

ln -s ${script_dir}/i3 $HOME/.config/i3
ln -s ${script_dir}/i3blocks $HOME/.config/i3blocks
ln -s ${script_dir}/i3_scripts $HOME/.config/i3_scripts
ln -s ${script_dir}/polybar $HOME/.config/polybar
ln -s ${script_dir}/ranger $HOME/.config/ranger
ln -s ${script_dir}/rofi $HOME/.config/rofi
ln -s ${script_dir}/dunst $HOME/.config/dunst
