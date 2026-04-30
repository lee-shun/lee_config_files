this_script=$(readlink -f "$0")
script_dir=$(dirname "$this_script")

ln -s ${script_dir}/zshrc $HOME/.zshrc
ln -s ${script_dir}/oh-my-zsh $HOME/.oh-my-zsh

echo "change the default shell."
sudo apt install -y zsh
chsh -s /bin/zsh
