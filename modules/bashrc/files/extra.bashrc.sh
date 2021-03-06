alias vi='vim'
alias l='/bin/ls -la --color=tty'

HISTTIMEFORMAT='%F %T '
export HISTTIMEFORMAT
HISTFILESIZE=100000
export HISTFILESIZE
HISTSIZE=100000
export HISTSIZE
export HISTCONTROL=ignoredups

VISUAL=vim
export VISUAL
EDITOR=vim
export EDITOR

export PROMPT_COMMAND="history -a"