# load zgen
source "${HOME}/dotfiles/zgen/zgen.zsh"
source "${HOME}/dotfiles/git-functions.bash"
export TERM="xterm-256color"
export IDF_PATH=~/Development/esp-idf/
# Brew Aliases
if [ "$(uname 2> /dev/null)" != "Linux" ]; then
  alias cat='bat'
  alias ping='prettyping'
  alias diff='diff-so-fancy'
fi
set -g default-terminal "screen-256color"
alias gl='git log --decorate=full --graph'
alias gh='git hist'
alias gtl='git log --decorate=full'
alias gs='git status'
alias gsu='git submodule update --init --recursive'
alias gpf='git push --force'
POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon context dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator time)
# check if there's no init script
if ! zgen saved; then
    echo "Creating a zgen save"

    zgen oh-my-zsh

    # plugins
    zgen oh-my-zsh plugins/git
  #  zgen oh-my-zsh plugins/sudo
     zgen oh-my-zsh plugins/command-not-found
#    zgen oh-my-zsh plugins/ssh-agent
    zgen load zsh-users/zsh-syntax-highlighting
#    zgen load /path/to/super-secret-private-plugin
  zgen load zsh-users/zsh-autosuggestions
    # bulk load
    zgen loadall <<EOPLUGINS
        zsh-users/zsh-history-substring-search
        /path/to/local/plugin
EOPLUGINS
    # ^ can't indent this EOPLUGINS

    # completions
    zgen load zsh-users/zsh-completions src

    # theme
    zgen load romkatv/powerlevel10k powerlevel10k
#    zgen oh-my-zsh themes/nanotech
 #   zgen load bhilburn/powerlevel9k powerlevel9k
# save all to init script
    zgen save
fi

#ZSH_THEME=nanotech
ZSH_THEME=powerlevel10k
DISABLE_UNTRACKED_FILES_DIRTY="true"


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
