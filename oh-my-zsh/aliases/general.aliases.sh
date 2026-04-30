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
