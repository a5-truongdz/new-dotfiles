zmodload zsh/datetime
autoload -Uz add-zsh-hook
setopt PROMPT_SUBST

typeset -gF 6 _cmd_start=0
typeset -g    _cmd_duration=''
typeset -g    _git_branch=''
typeset -g    _clear_newline=''

_cmdtime_preexec() {
    _cmd_start=$EPOCHREALTIME
}

_cmdtime_precmd() {
    _cmd_duration=''
    (( _cmd_start > 0 )) || return

    local -F 6 elapsed
    elapsed=$(( EPOCHREALTIME - _cmd_start ))
    _cmd_start=0

    (( elapsed >= 5 )) || return

    local -i total=${elapsed%.*}
    local -i h=$(( total / 3600 ))
    local -i m=$(( total % 3600 / 60 ))
    local -i s=$(( total % 60 ))

    (( h > 0 )) && _cmd_duration+="${h}h"
    (( m > 0 )) && _cmd_duration+="${m}m"
    (( s > 0 )) && _cmd_duration+="${s}s"
    _cmd_duration+=' '
}

_git_precmd() {
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        _git_branch="$(git branch --show-current 2>/dev/null)%f "
        if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
            _git_branch="%F{yellow}${_git_branch}"
        else
            _git_branch="%F{green}${_git_branch}"
        fi
    else
        _git_branch=''
    fi
}

_clear_preexec() {
    local -a args=(${(z)1})
    if [[ "${args[1]}" == 'clear' ]]; then
        _clear_newline=''
    else
        _clear_newline=$'\n'
    fi
}

add-zsh-hook preexec _clear_preexec
add-zsh-hook preexec _cmdtime_preexec
add-zsh-hook precmd  _cmdtime_precmd
add-zsh-hook precmd  _git_precmd

PROMPT=$'${_clear_newline}󰣇 %F{cyan}%n%f@%F{green}%M %F{blue}%~ %F{green}$\n%(?..%F{red})->%f '
RPROMPT=$'%{\e[1A%}%(?..%F{red}%? )%F{yellow}${_cmd_duration}${_git_branch}%f%D{%H:%M:%S}%{\e[1B%}'
