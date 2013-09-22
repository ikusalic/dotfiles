function set_bash_prompt {
    local red="\[\e[0;31m\]"
    local green="\[\e[0;32m\]"
    local light_green="\[\e[1;32m\]"
    local color_off="\[\e[0m\]"

    local git_branch=$(__git_ps1 "%s")
    if [ -n "$git_branch" ]; then
        git diff --quiet HEAD &>/dev/null
        if [ $? == 1 ]; then
            git_result="$red ($git_branch)$color_off"
        else
            git_result="$green ($git_branch)$color_off"
        fi
    fi
    export PS1="[\t] $light_green[\u \w$color_off$git_result$light_green]\$$color_off "
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
export HISTCONTROL=ignoredups
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S> "

shopt -s checkwinsize
shopt -s extglob
shopt -s histappend
shopt -s hostcomplete

alias hist="history | grep $1"
alias ls="ls -FG"
alias ll="ls -al"
alias lt="ls -ltr"


##### OS SPECIFIC SETTINGS #####
if [[ "$OSTYPE" == "darwin"* ]]
then  # MAC OS X
    alias nosleep="pmset noidle"
    alias vim="/Applications/MacVim.app/Contents/MacOS/Vim"

    export PATH="/usr/local/bin:$PATH"  # for homebrew
    export PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:$PATH"

    [[ -s "$(brew --prefix)/etc/bash_completion" ]] && source "$(brew --prefix)/etc/bash_completion"
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
alias pb_list="pythonbrew venv list"
alias pb_use="pythonbrew venv use"


##### HOST SPECIFIC SETTINGS #####
[[ -s $HOME/.hostrc ]] && source $HOME/.hostrc
