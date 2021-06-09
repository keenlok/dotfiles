# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=1000
setopt appendhistory beep extendedglob nomatch
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/Users/lok/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstalli

# Determine OS
getDistro() {

    if [[ "`uname`" == "Darwin" ]]; then
        local DISTRO="Darwin";
    elif [[ "`uname`" == "Linux" ]]; then
        local DISTRO="Linux"
        source /etc/*release
        echo $DISTRIB_ID
    else
        local DISTRO=""
    fi

    if [[ -z $DISTRO ]]; then
        return 1
    else
        echo $DISTRO
    fi

}

# Path Variables
BIN=/usr/local/bin


source ~/.zprofile

# node nvm
export NVM_DIR=$HOME/.nvm
if [[ "$(getDistro)" == "Darwin" ]]; then
    . "/usr/local/opt/nvm/nvm.sh"
fi

# python / pyenv / pipenv
alias pip=pip3
alias python2=/Users/lok/.pyenv/shims/python
alias python=python3
# export PATH="/root/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
# eval "$(pipenv --completion)"

# Libindy
export LIBRARY_PATH="~/Downloads/libindy_1.15.0/lib"
