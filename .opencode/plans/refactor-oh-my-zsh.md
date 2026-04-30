# oh-my-zsh 重构计划

## 概述
参考 oh-my-bash 的模块化结构，将 oh-my-zsh/zshrc 中的内联配置拆分到 `utils/` 和 `aliases/` 目录。

---

## 第一步：创建 utils/ 模块

### oh-my-zsh/utils/cuda.sh
```bash
# CUDA
export PATH="/usr/local/cuda/bin:$PATH"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64"
```

### oh-my-zsh/utils/opencv.sh
```bash
# OpenCV
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/opencv470/lib"
```

### oh-my-zsh/utils/texlive.sh
```bash
# texlive
export MANPATH=${MANPATH}:/usr/local/texlive/2025/texmf-dist/doc/man
export INFOPATH=${INFOPATH}:/usr/local/texlive/2025/texmf-dist/doc/info
export PATH=${PATH}:/usr/local/texlive/2025/bin/x86_64-linux
```

### oh-my-zsh/utils/perl.sh
```bash
# perl
PATH="/home/ls/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/ls/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/ls/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/ls/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/ls/perl5"; export PERL_MM_OPT;
```

### oh-my-zsh/utils/cargo.sh
```bash
# cargo
export PATH="/home/ls/.cargo/bin:$PATH"
```

### oh-my-zsh/utils/npm.sh
```bash
# npm
export PATH=~/node_modules/.bin:$PATH
```

### oh-my-zsh/utils/ros.sh
```bash
# ROS distributed settings
export ROS_IP=`hostname -I | awk '{print $1}'`
export ROS_HOSTNAME=`hostname -I | awk '{print $1}'`
```

---

## 第二步：创建 aliases/ 模块

### oh-my-zsh/aliases/general.aliases.sh
```bash
# 基本映射
alias vim="nvim"
alias Q="exit"
alias cl="clear"

# cd 系列
alias cd=' cd'
alias ..=' cd ..; ls'
alias ...=' cd ..; cd ..; ls'
alias ....=' cd ..; cd ..; cd ..; ls'
alias cd..='..'
alias cd...='...'
alias cd....='....'

# 编辑文件
alias zshrc="nvim ~/.zshrc"
alias vimrc="nvim ~/.config/nvim/init.vim"
alias i3conf="cd ~/.config/i3/&& nvim config"

# 工具
alias lg="lazygit"
alias sys="neofetch"
alias R="ranger"
export RANGER_LOAD_DEFAULT_RC=FALSE
alias J="joshuto"

# chrome
alias google-chrome="google-chrome --password-store=gnome"

# download
alias down="aria2c -s16 -x16 -k1M"
alias SSD="cd /media/ls/SSD"

# local lsp
alias luamake=/home/ls/local_lsp/lua-language-server/3rd/luamake/luamake
```

### oh-my-zsh/aliases/git.aliases.sh
```bash
alias P='git push'
alias p='git pull'
alias c='git commit -m'
```

### oh-my-zsh/aliases/tmux.aliases.sh
```bash
alias tsnew="tmux new -s "
alias tl="tmux list-sessions"
alias tat="tmux attach -t"
alias tks="tmux kill-session -t"
alias tkw="tmux kill-window -t"
alias tkp="tmux kill-pane -t"
```

### oh-my-zsh/aliases/debian.aliases.sh
```bash
alias update="sudo apt update"
alias canupgrade="sudo apt list --upgradable"
alias upgrade="sudo apt upgrade"
alias install="sudo apt install"
alias remove="sudo apt remove"
alias autoremove="sudo apt autoremove"

alias getinstall="sudo apt-get install"
alias getupdate="sudo apt-get update"
alias getremove="sudo apt-get remove"
```

### oh-my-zsh/aliases/display.aliases.sh
```bash
alias INON="xrandr --output eDP-1-1 --auto"
alias OUTON="xrandr --output HDMI-1-1 --auto"
alias INOFF="xrandr --output eDP-1-1 --off"
alias OUTOFF="xrandr --output HDMI-1-1 --off"
```

---

## 第三步：重写 zshrc

用以下内容替换 `oh-my-zsh/zshrc`：

```bash
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH=$HOME/.oh-my-zsh

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
ZSH_UTILS="$HOME/.config/lee_config_files/oh-my-zsh/utils"
for script in "$ZSH_UTILS"/*.sh; do
    [ -f "$script" ] && source "$script"
done

# Source all alias scripts from oh-my-zsh/aliases
ZSH_ALIASES="$HOME/.config/lee_config_files/oh-my-zsh/aliases"
for script in "$ZSH_ALIASES"/*.aliases.sh; do
    [ -f "$script" ] && source "$script"
done

# 加速粘贴速度
pasteinit() {
    OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
    zle -N self-insert url-quote-magic
}
pastefinish() {
    zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

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

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

___MY_VMOPTIONS_SHELL_FILE="${HOME}/.jetbrains.vmoptions.sh"; if [ -f "${___MY_VMOPTIONS_SHELL_FILE}" ]; then . "${___MY_VMOPTIONS_SHELL_FILE}"; fi

# # >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/home/ls/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/home/ls/anaconda3/etc/profile.d/conda.sh" ]; then
#         . "/home/ls/anaconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="/home/ls/anaconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# # <<< conda initialize <<<
```

---

## 变更清单

| 操作 | 文件 |
|---|---|
| 新建 | `oh-my-zsh/utils/cuda.sh` |
| 新建 | `oh-my-zsh/utils/opencv.sh` |
| 新建 | `oh-my-zsh/utils/texlive.sh` |
| 新建 | `oh-my-zsh/utils/perl.sh` |
| 新建 | `oh-my-zsh/utils/cargo.sh` |
| 新建 | `oh-my-zsh/utils/npm.sh` |
| 新建 | `oh-my-zsh/utils/ros.sh` |
| 新建 | `oh-my-zsh/aliases/general.aliases.sh` |
| 新建 | `oh-my-zsh/aliases/git.aliases.sh` |
| 新建 | `oh-my-zsh/aliases/tmux.aliases.sh` |
| 新建 | `oh-my-zsh/aliases/debian.aliases.sh` |
| 新建 | `oh-my-zsh/aliases/display.aliases.sh` |
| 重写 | `oh-my-zsh/zshrc` |

## 删除内容
- `ANTHROPIC_API_KEY` (原 L205) — 已删除
- `source ~/rs.bash` (原 L122) — 文件不存在，已删除
- ASCII art 头部 — 精简移除
- `virc` alias — 指向 `~/.vim/init.vim` 疑似过时，已删除

## 执行方式
由于当前权限限制，请按上述计划手动创建/修改文件，或者调整权限规则后让我继续执行。
