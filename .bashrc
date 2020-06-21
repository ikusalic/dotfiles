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

    source ~/.git-prompt.sh
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

export BASH_SILENCE_DEPRECATION_WARNING=1

export PROMPT_COMMAND=set_bash_prompt

export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export EDITOR=vim

export HISTTIMEFORMAT="%F %T "
export HISTCONTROL=ignoredups:ignorespace
export HISTIGNORE="pwd:ls:dir:ls -al:ls -l:h:history"
export HISTFILESIZE=1000000
export HISTSIZE=1000000
export HISTCONTROL=ignoredups:ignorespace
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S> "


shopt -s checkwinsize
shopt -s extglob
shopt -s histappend
shopt -s hostcomplete

alias a="ack"
alias ai="ack -i"
alias af="ack --files-with-matches"
alias aj="ack --scala --java --ignore-dir='target' --ignore-dir='.idea'"
alias ajt="ack --scala --java --ignore-dir='target' --ignore-dir='.idea' --ignore-dir='test'"
alias as="ack --scala --ignore-dir='target' --ignore-dir='.idea'"
alias ast="ack --scala --ignore-dir='target' --ignore-dir='.idea' --ignore-dir='test'"
alias ap="ack --python"
alias ar="ack --ruby"
alias art="ack --ruby --ignore-dir='spec'"
alias d="diff -y --suppress-common-lines"
alias g="grep -v grep | grep -i"
alias l="ls -ahl"
alias ll="ls -ahl"
alias lr="less -r"
alias ls="ls -FGh"
alias lsd="find . -type d -maxdepth 1 -exec basename {} \;"
alias lt="ls -hlrt"
alias pg="ps -ef | grep"
alias t="tree -C --matchdirs -I target"
alias t2="tree -C --matchdirs -I target -f -L 2"
alias tarc="tar -cvzf"
alias tard="tar -xvzf"
alias tf="tree -C --matchdirs -I target -f"
alias tfg="tree -C --matchdirs -I target -f | grep -i"
alias tg="tree -C --matchdirs -I target -f | grep -i"
alias w="watch -n 0.5"

alias nosleep="pmset noidle"
#alias vim="/Applications/MacVim.app/Contents/MacOS/Vim"

##### HOST SPECIFIC SETTINGS #####
# use .hostrc for additional customization
[[ -s $HOME/.hostrc ]] && source $HOME/.hostrc || true
