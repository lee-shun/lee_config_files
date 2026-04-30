# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_BASE=/home/ls/.vim/dein/repos/github.com/junegunn/fzf
export FZF_DEFAULT_OPTS='--bind ctrl-j:down,ctrl-k:up --preview "[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (ccat --color=always {} || highlight -O ansi -l {} || cat {}) 2> /dev/null | head -500"'
export FZF_DEFAULT_COMMAND='fdfind'
export FZF_COMPLETION_TRIGGER='\'
export FZF_TMUX=1
export FZF_TMUX_HEIGHT='80%'
export fzf_preview_cmd='[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (ccat --color=always {} || highlight -O ansi -l {} || batcat {} || cat {}) 2> /dev/null | head -500'

_fzf_compgen_path() {
    fdfind --hidden --follow --exclude ".git" . "$1" --exclude ".wine32" . "$1" --exclude ".cache" . "$1"
}
_fzf_compgen_dir() {
    fdfind --type d --hidden --follow --exclude ".git" . "$1" --exclude ".wine32" . "$1" --exclude ".cache" . "$1"
}
_fzf_comprun() {
    local command=$1
    shift
    case "$command" in
        cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
        export|unset) fzf "$@" --preview "eval 'echo \$'{}" ;;
        ssh)          fzf "$@" --preview 'dig {}' ;;
        *)            fzf "$@" ;;
    esac
}
