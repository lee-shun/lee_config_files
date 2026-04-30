# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.config/lee_config_files/oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"
HIST_STAMPS="mm/dd/yyyy"

plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

export EDITOR=nvim

# Source all utility scripts from oh-my-zsh/utils
for script in "$ZSH/utils"/*.sh; do
    [ -f "$script" ] && source "$script"
done

# Source all alias scripts from oh-my-zsh/aliases
for script in "$ZSH/aliases"/*.aliases.sh; do
    [ -f "$script" ] && source "$script"
done

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

___MY_VMOPTIONS_SHELL_FILE="${HOME}/.jetbrains.vmoptions.sh"; if [ -f "${___MY_VMOPTIONS_SHELL_FILE}" ]; then . "${___MY_VMOPTIONS_SHELL_FILE}"; fi
