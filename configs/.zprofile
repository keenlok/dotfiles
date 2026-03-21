# Customize to your needs...

setopt prompt_subst
autoload -U colors && colors
autoload -Uz vcs_info
zstyle ':vcs_info:*' actionformats \
    '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats       \
    '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'

zstyle ':vcs_info:*' enable git cvs svn hg

# or use pre_cmd, see man zshcontrib
vcs_info_wrapper() {
    vcs_info
    if [ -n "$vcs_info_msg_0_" ]; then
        echo "%{$fg[grey]%}${vcs_info_msg_0_}%{$reset_color%}"
    fi
}

docker_machine_info_wrapper() {
    if [ -n "$DOCKER_MACHINE_NAME" ]; then
        echo "%{$fg[blue]%}docker::${DOCKER_MACHINE_NAME}%{$reset_color%} "
    else
        echo "%{$fg[blue]%}docker::local%{$reset_color%} "
    fi
}

# Build the prompt
PROMPT=""
PROMPT+=$'$(vcs_info_wrapper)'  # Version Control
PROMPT+=$'$(docker_machine_info_wrapper)'
PROMPT+="%{$fg[red]%}%m %l%{$reset_color%}"  # Host
PROMPT+="%{$fg[yellow]%} %D{%a %f %b}%{$reset_color%}"  # Date
PROMPT+="%{$fg[cyan]%} %T%{$reset_color%}"  # Time
PROMPT+="%{$fg[green]%} | %~ |%{$reset_color%}" # Working directory
PROMPT+="
" # Newline
PROMPT+="%n %# "  # Username and prompt
