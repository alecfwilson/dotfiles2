#!/bin/bash

# leave bashrc for any OS-specific stuff, i guess?
#[[ -f ~/.bashrc ]] && . ~/.bashrc


DEFAULT_GIT_REMOTE=origin

[[ -f ~/.private ]] && . ~/.private

#
# ~/.bash_profile
#
function just_git_branch {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    echo "${ref#refs/heads/}"
}

function parse_git_branch {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    echo " ("${ref#refs/heads/}") "
}

function print_symlink {
    wd="$(pwd)"
    linkdir="$(readlink -n $wd)";
    if readlink -n $wd >/dev/null;
    then
        echo " -> $linkdir ";
    fi
}

# switch to the nvm version defined by .nvmrc
enter_directory() {
if [[ $PWD == $PREV_PWD ]]; then
    return
fi
PREV_PWD=$PWD
if [[ -f ".nvmrc" ]]; then
    nvm use
    NVM_DIRTY=true
elif [[ $NVM_DIRTY = true ]]; then
    nvm use default
    NVM_DIRTY=false
fi
}
export PROMPT_COMMAND="enter_directory; ${PROMPT_COMMAND}"

# https://timingapp.com/help/terminal
PROMPT_TITLE='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}\007"'
export PROMPT_COMMAND="${PROMPT_TITLE}; ${PROMPT_COMMAND}"

export PS1='\h \[\e[0;32m\] \W\[\e[0;36m\]$(print_symlink)\[\e[0;31m\]$(parse_git_branch)\[\e[0m\] $ '
export EDITOR=vim
set -o vi

export PATH=$PATH:~/.dotfiles/bin
export PATH=~/bin:~/scripts/:~/private-scripts:$PATH
export PATH=/usr/local/bin:/usr/local/sbin:$PATH

alias la='ls -al'
alias ll='ls -lth'
alias ls='ls -F'
alias rm='rm -i'
alias wip='git add . && git commit -m WIP && git push ${DEFAULT_GIT_REMOTE} $(just_git_branch)'


alias pomo25="open focus://focus?minutes=25"
alias pomo10="open focus://focus?minutes=10"
alias pomo5="open focus://focus?minutes=5"
alias pomobreak="open focus://break?minutes=5"

# make sure DOTFILES_OS and DOTFILES_PROFILE are set.
[[ -f ~/.dotfiles_env ]] && . ~/.dotfiles_env

# default settings that may get overriden by profiles...
export CONDA_HOME=/opt/conda

#
# OS-specific settings
#
if [ "$DOTFILES_OS" == "macos" ]
then
    echo "using OS=macos"

    export PATH=$PATH:/Applications/Araxis\ Merge.app/Contents/Utilities
    export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)

    # from tensorflow setup GPU on mac...
    export CUDA_HOME=/usr/local/cuda
    export DYLD_LIBRARY_PATH="$CUDA_HOME/lib"
    export PATH="$CUDA_HOME/bin:$PATH"
    export LD_LIBRARY_PATH=$CUDA_HOME/lib
    
    . /usr/local/etc/bash_completion
    ## ignore this conditional and just assume im using bash?
    #if [ -f $(brew --prefix)/etc/bash_completion ]; then
    #fi

    # macvim loading stuff:
    # - https://github.com/altercation/solarized/issues/60
    alias vim=/Applications/MacVim.app/Contents/MacOS/Vim

elif [ "$DOTFILES_OS" == "linux" ]
then
    echo "using OS=linux"

    if [ "$DOTFILES_PROFILE" == "home" ]
    then
        echo "using profile 'home', aka archlinux setup"
        export TERM=rxvt-unicode-256color
        export JAVA_HOME="/opt/jdk/latest"
    elif [ "$DOTFILES_PROFILE" == "work" ]
    then
        echo "using profile 'work', aka basic cloud ubuntu setup"
        #export TERM=xterm-256color
    fi
else 
    echo "using OS=${DOTFILES_OS}"
fi

#
# profile-specific settings
#
if [ "$DOTFILES_PROFILE" == "home" ]
then
    echo "using PROFILE=home"

    export GOROOT="/usr/local/go"
    export GOPATH="$HOME/go"
    export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
else
    if [ "$DOTFILES_PROFILE" == "work" ]
    then
        echo "using PROFILE=work"

        # add arcanist to path.
        export PATH=$PATH:~/tools/arcanist/bin
        export PATH=~/miniconda2/bin:$PATH
    else
        echo "using PROFILE=${DOTFILES_PROFILE}"
    fi
fi


#############################
# Java
#
# Notes:
# - JAVA_HOME is set per-OS
#############################

if [ -n "${JAVA_HOME+set}" ]; then
    echo '$JAVA_HOME is already set'
else
    echo '$JAVA_HOME must be set' && exit 1
fi
export PATH="$PATH:$JAVA_HOME/bin"
export M2_HOME="/opt/apache/maven/latest"



#############################
# Golang
#############################


#############################
# GCLOUD
#############################

# The next line updates PATH for the Google Cloud SDK.
if [ -f /opt/google/google-cloud-sdk/path.bash.inc ]; then
  source '/opt/google/google-cloud-sdk/path.bash.inc'
fi
# The next line enables shell command completion for gcloud.
if [ -f /opt/google/google-cloud-sdk/completion.bash.inc ]; then
  source '/opt/google/google-cloud-sdk/completion.bash.inc'
fi
export APPENGINE_HOME=/opt/google/google_appengine
export PATH=$PATH:$APPENGINE_HOME


#############################
# CONDA
#############################
echo "about to check for conda..."
echo $(which python)
if [ -d $CONDA_HOME/miniconda3 ]; then
    export PATH="/opt/conda/miniconda3/bin:$PATH"
    
    # DEBUGGING
    echo "miniconda3 found"
    echo $(which python)
fi
if [ -d $CONDA_HOME/miniconda2 ]; then
    export PATH="/opt/conda/miniconda2/bin:$PATH"
    
    # DEBUGGING
    echo "miniconda2 found"
    echo $(which python)
fi

# nvm setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# for installing node-gyp / node-sass
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:/usr/local/opt/libffi/lib/pkgconfig"

#
# Working paths
#
export DROPBOX="${HOME}/Dropbox"
export DROPBOX_PROJECTS="${DROPBOX}/_Projects"
export DROPBOX_ARCHIVE="${DROPBOX}/_Archive"
export DROPBOX_WORKING="${DROPBOX}/_Working"
export WORKDIR_WEBSITE="${DROPBOX_PROJECTS}/artx/sharex/my-website"

alias cdmysite="cd ${WORKDIR_WEBSITE}"
alias cdwebapp="cd ${HOME}/code/PLATO/webapp"
