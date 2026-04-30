#! bash oh-my-bash.module

# Check if zoxide is installed
if [ -f ~/.fzf.bash ]; then
    source ~/.fzf.bash
else
    echo '[oh-my-bash] fzf not found, please install it from https://github.com/junegunn/fzf'
fi


