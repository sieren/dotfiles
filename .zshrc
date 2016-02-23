# load zgen
source "${HOME}/dotfiles/zgen/zgen.zsh"
alias 'brew --prefix' /bin/ctags
set -g default-terminal "screen-256color"
alias gl='git log --decorate=full --graph'
alias gh='git hist'
alias gtl='git log --decorate=full'
alias gs='git status'
alias gsu='git submodule update --init --recursive'
alias gpf='git push --force'
# check if there's no init script
if ! zgen saved; then
    echo "Creating a zgen save"

    zgen oh-my-zsh

    # plugins
    zgen oh-my-zsh plugins/git
    zgen oh-my-zsh plugins/sudo
    zgen oh-my-zsh plugins/command-not-found
    zgen oh-my-zsh plugins/ssh-agent
    zgen load zsh-users/zsh-syntax-highlighting
#    zgen load /path/to/super-secret-private-plugin

    # bulk load
    zgen loadall <<EOPLUGINS
        zsh-users/zsh-history-substring-search
        /path/to/local/plugin
EOPLUGINS
    # ^ can't indent this EOPLUGINS

    # completions
    zgen load zsh-users/zsh-completions src

    # theme
   zgen oh-my-zsh themes/nanotech

    # save all to init script
    zgen save
fi

#ZSH_THEME=sorin
ZSH_THEME=nanotech

export QTDIR64=/Volumes/GuiEnv_64/Qt5.5.0/clang_64
export PATH=/Volumes/GuiEnv_64/Qt5.5.0/clang_64/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin

export TERM=xterm-256color
