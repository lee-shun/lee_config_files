#! bash oh-my-bash.module

# Check if fzf is installed
if _omb_util_command_exists fzf; then
if [ -f ~/.fzf.bash ]; then
    source ~/.fzf.bash
fi
    eval "$(fzf --bash)"
else
    echo '[oh-my-bash] fzf not found, please install it from https://github.com/junegunn/fzf'
fi
