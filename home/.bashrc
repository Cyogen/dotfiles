#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
export PATH="$HOME/.local/bin:$PATH"

# ── dircolors ─────────────────────────────────────────────
[ -f ~/.dircolors ] && eval "$(dircolors ~/.dircolors)" || eval "$(dircolors -b)"

# ── Cyberpunk PS1 ─────────────────────────────────────────
_cyber_prompt() {
    local exit_code=$?

    local reset='\[\e[0m\]'
    local bold='\[\e[1m\]'

    local cyan='\[\e[38;5;67m\]'
    local magenta='\[\e[38;5;165m\]'
    local yellow='\[\e[38;5;136m\]'
    local green='\[\e[38;5;82m\]'
    local red='\[\e[38;5;196m\]'
    local orange='\[\e[38;5;208m\]'
    local pink='\[\e[38;5;213m\]'
    local dark='\[\e[38;5;240m\]'
    local darkred='\[\e[38;5;88m\]'

    local symbol
    if [ $exit_code -eq 0 ]; then
        symbol="${darkred}❯${reset}"
    else
        symbol="${red}❯${reset}"
    fi

    local git_branch=""
    if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
        local branch
        branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
        git_branch=" ${dark}⎇ ${reset}${green}${branch}${reset}"
    fi

    PS1="${darkred}┌─${reset}${bold}${cyan}\u${reset}${darkred}@${reset}${yellow}\h${reset} ${darkred}❬${reset}${magenta}\W${darkred}❭${reset}${git_branch}\n${darkred}└─❯${reset} "
}
PROMPT_COMMAND='_cyber_prompt'

fastfetch
