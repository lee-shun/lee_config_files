# ###############################################################
#  _                           _
# | |    ___  ___      _______| |__  _ __ ___
# | |   / _ \/ _ \____|_  / __| '_ \| '__/ __|
# | |__|  __/  __/_____/ /\__ \ | | | | | (__
# |_____\___|\___|    /___|___/_| |_|_|  \___|
# 
#
# Author:lee-shun
# 
# Email:lee970802@163.com
# 
## ##############################################################
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
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

# 加速粘贴速度
# This speeds up pasting w/ autosuggest
# https://github.com/zsh-users/zsh-autosuggestions/issues/238
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}

pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

#基本映射
# alias vim="nvim"

alias Q="exit"
alias cl="clear"

alias cd=' cd'
alias ..=' cd ..; ls'
alias ...=' cd ..; cd ..; ls'
alias ....=' cd ..; cd ..; cd ..; ls'
alias cd..='..'
alias cd...='...'
alias cd....='....'

alias update="sudo apt update"
alias canupgrade="sudo apt list --upgradable"
alias upgrade="sudo apt upgrade"
alias install="sudo apt install"
alias remove="sudo apt remove"
alias autoremove="sudo apt autoremove"

alias getinstall="sudo apt-get install"
alias getupdate="sudo apt-get update"
alias getremove="sudo apt-get remove"

#  编辑文件
alias zshrc="vim ~/.zshrc"
alias vimrc="vim ~/.config/nvim/init.vim"
alias virc="vi ~/.vim/init.vim"
alias i3conf="cd ~/.config/i3/&& vim config"
# 添加lazygit
alias lg="lazygit"

# 添加neofetch
alias sys="neofetch"

# 添加ranger
alias R="ranger"
export RANGER_LOAD_DEFAULT_RC=FALSE

alias J="joshuto"

#  git
alias P='git push'
alias p='git pull'
alias c='git commit -m'

#添加tmux
alias tsnew="tmux new -s "
alias tl="tmux list-sessions"
alias tat="tmux attach -t"
alias tks="tmux kill-session -t"
alias tkw="tmux kill-window -t"
alias tkp="tmux kill-pane -t"

# chrome with key
alias google-chrome="google-chrome  --password-store=gnome"

# display
alias INON="xrandr --output eDP-1-1 --auto"
alias OUTON="xrandr --output HDMI-1-1 --auto"
alias INOFF="xrandr --output eDP-1-1 --off"
alias OUTOFF="xrandr --output HDMI-1-1 --off"

# down with aria2c
alias down="aria2c -s16 -x16 -k1M"

# texlive
export MANPATH=${MANPATH}:/usr/local/texlive/2022/texmf-dist/doc/man
export INFOPATH=${INFOPATH}:/usr/local/texlive/2022/texmf-dist/doc/info
export PATH=${PATH}:/usr/local/texlive/2022/bin/x86_64-linux

# ros1
# source /opt/ros/noetic/setup.zsh
# source ~/catkin_ws/devel/setup.zsh
# cv_bridge
# source ~/cv_bridge_ws/install/setup.zsh --extend

# ros2
# source /opt/ros/foxy/setup.zsh
# source ~/ros2_ws/install/setup.zsh

# 分布式ros
## Bell984
# export ROS_IP=`hostname -I | awk '{print $1}'`
# export ROS_HOSTNAME=`hostname -I | awk '{print $1}'`
# export ROS_MASTER_URI=http://192.168.2.39:11311/

## Linksys
# export ROS_IP=`hostname -I | awk '{print $1}'`
# export ROS_HOSTNAME=`hostname -I | awk '{print $1}'`
# export ROS_MASTER_URI=http://192.168.1.110:11311/

# 配置opencv
# export PKG_CONFIG_PATH=/usr/share/pkgconfig:$PKG_CONFIG_PATH

# CUDA
export PATH="/usr/local/cuda/bin:$PATH"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64"

# Tensorrt
# export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/TensorRT-7.1.3.4/lib"

# perl
PATH="/home/ls/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/ls/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/ls/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/ls/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/ls/perl5"; export PERL_MM_OPT;

# cargo
export PATH="/home/ls/.cargo/bin:$PATH"

# npm
export PATH=~/node_modules/.bin:$PATH

# local lsp
alias luamake=/home/ls/local_lsp/lua-language-server/3rd/luamake/luamake

#fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#  fzf-settings
export FZF_BASE=/home/ls/.vim/dein/repos/github.com/junegunn/fzf
export FZF_DEFAULT_OPTS='--bind ctrl-j:down,ctrl-k:up --preview "[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (ccat --color=always {} || highlight -O ansi -l {} || cat {}) 2> /dev/null | head -500"'
export FZF_DEFAULT_COMMAND='fdfind'
export FZF_COMPLETION_TRIGGER='\'
export FZF_TMUX=1
export FZF_TMUX_HEIGHT='80%'
export fzf_preview_cmd='[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (ccat --color=always {} || highlight -O ansi -l {} || batcat {} || cat {}) 2> /dev/null | head -500'

#  Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fdfind --hidden --follow --exclude ".git" . "$1" --exclude ".wine32" . "$1" --exclude ".cache" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fdfind --type d --hidden --follow --exclude ".git" . "$1" --exclude ".wine32" . "$1" --exclude ".cache" . "$1"
}

# (EXPERIMENTAL) Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
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
