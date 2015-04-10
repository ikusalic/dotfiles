function set_bash_prompt {
    local last_status=$?

    GIT_PS1_SHOWDIRTYSTATE=true
    GIT_PS1_SHOWUNTRACKEDFILES=true
    GIT_PS1_SHOWUPSTREAM="verbose git"

    local red="\[\e[0;31m\]"
    local green="\[\e[0;32m\]"
    local light_green="\[\e[1;32m\]"
    local color_off="\[\e[0m\]"

    if [ $last_status -eq 0 ]; then
        local status_indicator="$green \$ $color_off"
    else
        local status_indicator="$red \$ $color_off"
    fi

    local git_branch=$(__git_ps1 "%s")
    if [ -n "$git_branch" ]; then
        git diff --quiet HEAD &>/dev/null
        if [ $? == 1 ]; then
            git_result="$red ($git_branch)$color_off"
        else
            git_result="$green ($git_branch)$color_off"
        fi
    fi
    git rev-parse &> /dev/null || git_result=''

    # use PS_CUSTOM_PREFIX for additional customization

    export PS1="$PS_CUSTOM_PREFIX[\t] $light_green[\u \w$color_off$git_result$light_green]$status_indicator"
}
export PROMPT_COMMAND=set_bash_prompt

export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export EDITOR=vim

export HISTTIMEFORMAT="%F %T "
export HISTCONTROL=ignoredups:ignorespace
export HISTIGNORE="pwd:ls:dir:ls -al:ls -l:h:history"
export HISTFILESIZE=100000
export HISTSIZE=100000
export HISTCONTROL=ignoredups:ignorespace
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S> "

shopt -s checkwinsize
shopt -s extglob
shopt -s histappend
shopt -s hostcomplete

alias g="grep -v grep | grep -i"
alias a="ack"
alias af="ack --files-with-matches"
alias as="ack --ignore-dir='target' --ignore-dir='.idea'"
alias ap="ack --python"
alias ar="ack --ruby"
alias d="diff -y --suppress-common-lines"
alias l="ls -ahl"
alias ll="ls -ahl"
alias lr="less -r"
alias ls="ls -FGh"
alias lsd="find . -type d -maxdepth 1 -exec basename {} \;"
alias lt="ls -hlrt"
alias t="tree -C --matchdirs -I target"
alias tarc="tar -cvzf"
alias tard="tar -xvzf"
alias tg="tree -C --matchdirs -I target -f | grep -i"
alias w="watch -n 0.5"


##### OS SPECIFIC SETTINGS #####
if [[ "$OSTYPE" == "darwin"* ]]
then  # MAC OS X
    alias nosleep="pmset noidle"
    alias vim="/Applications/MacVim.app/Contents/MacOS/Vim"

    export PATH="/usr/local/bin:$PATH"  # for homebrew
    export PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:$PATH"
    export PATH=$PATH:$HOME/.rvm/bin  # Add RVM to PATH for scripting
    export PATH=$PATH:/usr/texbin  # for pdflatex

    [[ -s "$(brew --prefix)/etc/bash_completion" ]] && source "$(brew --prefix)/etc/bash_completion"

    [[ -s "$HOME/.git-prompt.sh" ]] && source "$HOME/.git-prompt.sh"
elif [[ "$OSTYPE" == "linux-gnu" ]]
then  # LINUX
    [[ -s /etc/bash_completion ]] && source /etc/bash_completion
fi


##### LANGUAGE SPECIFIC SETTINGS #####
[[ -s "$HOME/.pythonbrew/etc/bashrc" ]] && source "$HOME/.pythonbrew/etc/bashrc"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

alias be="bundle exec"
alias rg_use="rvm gemset use"
alias rg_list="rvm gemset list"

alias cr="$HOME/other/source/devaut/src/main/bash/checkrepo"
alias push="$HOME/other/source/devaut/src/main/bash/push --dry-run"
alias eachrepo="$HOME/other/source/devaut/src/main/bash/eachrepo"

alias brewup="brew update && brew upgrade"

##### HOST SPECIFIC SETTINGS #####
# use .hostrc for additional customization
[[ -s $HOME/.hostrc ]] && source $HOME/.hostrc
