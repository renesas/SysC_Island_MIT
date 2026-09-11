#!/bin/bash

# Standard Colors (30-37)
export BLACK='\033[30m'
export RED='\033[31m'
export GREEN='\033[32m'
export YELLOW='\033[33m'
export BLUE='\033[34m'
export MAGENTA='\033[35m'
export CYAN='\033[36m'
export WHITE='\033[37m'

# Bright/Bold Colors (1;30-1;37)
export BRIGHT_BLACK='\033[1;30m'     # Dark Gray
export BRIGHT_RED='\033[1;31m'
export BRIGHT_GREEN='\033[1;32m'
export BRIGHT_YELLOW='\033[1;33m'
export BRIGHT_BLUE='\033[1;34m'
export BRIGHT_MAGENTA='\033[1;35m'
export BRIGHT_CYAN='\033[1;36m'
export BRIGHT_WHITE='\033[1;37m'

# High Intensity Colors (90-97)
export GRAY='\033[90m'               # Dark Gray
export LIGHT_RED='\033[91m'
export LIGHT_GREEN='\033[92m'
export LIGHT_YELLOW='\033[93m'
export LIGHT_BLUE='\033[94m'
export LIGHT_MAGENTA='\033[95m'
export LIGHT_CYAN='\033[96m'
export LIGHT_WHITE='\033[97m'

# Background Colors (40-47)
export BG_BLACK='\033[40m'
export BG_RED='\033[41m'
export BG_GREEN='\033[42m'
export BG_YELLOW='\033[43m'
export BG_BLUE='\033[44m'
export BG_MAGENTA='\033[45m'
export BG_CYAN='\033[46m'
export BG_WHITE='\033[47m'

# High Intensity Background Colors (100-107)
export BG_GRAY='\033[100m'
export BG_LIGHT_RED='\033[101m'
export BG_LIGHT_GREEN='\033[102m'
export BG_LIGHT_YELLOW='\033[103m'
export BG_LIGHT_BLUE='\033[104m'
export BG_LIGHT_MAGENTA='\033[105m'
export BG_LIGHT_CYAN='\033[106m'
export BG_LIGHT_WHITE='\033[107m'

# Text Formatting
export BOLD='\033[1m'
export DIM='\033[2m'
export ITALIC='\033[3m'
export UNDERLINE='\033[4m'
export BLINK='\033[5m'
export REVERSE='\033[7m'
export STRIKETHROUGH='\033[9m'

# Reset and Control
export RESET='\033[0m'
export RESET_BOLD='\033[21m'
export RESET_DIM='\033[22m'
export RESET_ITALIC='\033[23m'
export RESET_UNDERLINE='\033[24m'
export RESET_BLINK='\033[25m'
export RESET_REVERSE='\033[27m'
export RESET_STRIKETHROUGH='\033[29m'

# Cursor Control
export CURSOR_UP='\033[A'
export CURSOR_DOWN='\033[B'
export CURSOR_RIGHT='\033[C'
export CURSOR_LEFT='\033[D'
export CURSOR_HOME='\033[H'
export CLEAR_SCREEN='\033[2J'
export CLEAR_LINE='\033[K'

# Common Color Combinations (for convenience)
export ERROR="${BRIGHT_RED}${BOLD}"
export SUCCESS="${BRIGHT_GREEN}${BOLD}"
export WARNING="${BRIGHT_YELLOW}${BOLD}"
export INFO="${BRIGHT_BLUE}${BOLD}"
export DEBUG="${GRAY}"

# Function to print color palette (for testing)
print_color_palette() {
    echo -e "${BOLD}Standard Colors:${RESET}"
    echo -e "${BLACK}BLACK${RESET} ${RED}RED${RESET} ${GREEN}GREEN${RESET} ${YELLOW}YELLOW${RESET} ${BLUE}BLUE${RESET} ${MAGENTA}MAGENTA${RESET} ${CYAN}CYAN${RESET} ${WHITE}WHITE${RESET}"
    
    echo -e "\n${BOLD}Bright Colors:${RESET}"
    echo -e "${BRIGHT_BLACK}BRIGHT_BLACK${RESET} ${BRIGHT_RED}BRIGHT_RED${RESET} ${BRIGHT_GREEN}BRIGHT_GREEN${RESET} ${BRIGHT_YELLOW}BRIGHT_YELLOW${RESET} ${BRIGHT_BLUE}BRIGHT_BLUE${RESET} ${BRIGHT_MAGENTA}BRIGHT_MAGENTA${RESET} ${BRIGHT_CYAN}BRIGHT_CYAN${RESET} ${BRIGHT_WHITE}BRIGHT_WHITE${RESET}"
    
    echo -e "\n${BOLD}Light Colors:${RESET}"
    echo -e "${LIGHT_RED}LIGHT_RED${RESET} ${LIGHT_GREEN}LIGHT_GREEN${RESET} ${LIGHT_YELLOW}LIGHT_YELLOW${RESET} ${LIGHT_BLUE}LIGHT_BLUE${RESET} ${LIGHT_MAGENTA}LIGHT_MAGENTA${RESET} ${LIGHT_CYAN}LIGHT_CYAN${RESET} ${LIGHT_WHITE}LIGHT_WHITE${RESET}"
    
    echo -e "\n${BOLD}Text Formatting:${RESET}"
    echo -e "${BOLD}BOLD${RESET} ${DIM}DIM${RESET} ${ITALIC}ITALIC${RESET} ${UNDERLINE}UNDERLINE${RESET} ${STRIKETHROUGH}STRIKETHROUGH${RESET}"
    
    echo -e "\n${BOLD}Common Combinations:${RESET}"
    echo -e "${ERROR}ERROR${RESET} ${SUCCESS}SUCCESS${RESET} ${WARNING}WARNING${RESET} ${INFO}INFO${RESET} ${DEBUG}DEBUG${RESET}"
}

# Color printing function - takes color and message
cprint() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${RESET}"
}

# Multi-color printing function - takes multiple color-message pairs
mprint() {
    local output=""
    while [[ $# -gt 0 ]]; do
        local color="$1"
        local message="$2"
        output+="${color}${message}${RESET}"
        shift 2
    done
    echo -e "$output"
}

# Convenience functions for common use cases
print_error() {
    cprint "$ERROR" "[error] $1"
}

print_success() {
    cprint "$SUCCESS" "[ok] $1"
}

print_warning() {
    cprint "$WARNING" "[warn] $1"
}

print_info() {
    cprint "$INFO" "[info] $1"
}

print_debug() {
    cprint "$DEBUG" "[dbg] $1"
}

# Usage examples and initialization
# cprint "$SUCCESS" "Colors loaded successfully!"
# cprint "$INFO" "Use 'print_color_palette' to see all available colors."
# echo ""
# cprint "$BOLD" "Usage examples:"
# echo "  cprint \"\$RED\" \"This is red text\""
# echo "  print_error \"Something went wrong!\""
# echo "  mprint \"\$BOLD\" \"Bold text \" \"\$RED\" \"followed by red text\""