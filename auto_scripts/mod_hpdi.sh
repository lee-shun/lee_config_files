this_script=$(readlink -f "$0")
script_dir=$(dirname "$this_script")

ln -s ${script_dir}/profile $HOME/.profie
ln -s ${script_dir}/Xresources $HOME/.Xresources
