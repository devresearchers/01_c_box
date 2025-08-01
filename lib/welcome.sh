#!/usr/bin/env bash
# Welcome screens and first-run experience

# Show welcome screen for first-time users
show_welcome_screen() {
    clear
    echo
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                               ║${NC}"
    echo -e "${CYAN}║${NC}  ${WHITE}█▀▀ █   ▄▀█ █ █ █▀▄ █▀▀ █▄▄ █▀█ ▀▄▀${NC}   ${CYAN}Docker Environment for Claude CLI${NC}  ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${WHITE}█▄▄ █▄▄ █▀█ █▄█ █▄▀ ██▄ █▄█ █▄█ █ █${NC}   ${DIM}Isolated • Secure • Powerful${NC}      ${CYAN}║${NC}"
    echo -e "${CYAN}║                                                                               ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    echo -e "${WHITE}  🎉 Welcome to ClaudeBox!${NC}"
    echo
    echo -e "${DIM}  ClaudeBox provides a secure, containerized environment for running Claude CLI${NC}"
    echo -e "${DIM}  with full development tooling and network isolation.${NC}"
    echo
    
    echo -e "${WHITE}  ✨ KEY FEATURES${NC}"
    echo -e "${DIM}  ────────────────────────────────────────────────────────────────────────────${NC}"
    echo
    echo -e "     ${GREEN}•${NC} ${WHITE}Isolated Environment${NC}     Each project runs in its own Docker container"
    echo -e "     ${GREEN}•${NC} ${WHITE}Multi-Profile Support${NC}    20+ language stacks (Python, Rust, Go, etc.)"
    echo -e "     ${GREEN}•${NC} ${WHITE}Network Security${NC}         Firewall with customizable denylist"
    echo -e "     ${GREEN}•${NC} ${WHITE}Multi-Slot System${NC}        Run multiple Claude instances per project"
    echo -e "     ${GREEN}•${NC} ${WHITE}Persistent Storage${NC}       Your work is saved between sessions"
    echo
    
    echo -e "${WHITE}  🚀 QUICK START${NC}"
    echo -e "${DIM}  ────────────────────────────────────────────────────────────────────────────${NC}"
    echo
    echo -e "     ${WHITE}1.${NC} We'll build a Docker image for this project ${DIM}(one-time setup)${NC}"
    echo -e "     ${WHITE}2.${NC} Create an authenticated container slot"
    echo -e "     ${WHITE}3.${NC} Start using Claude CLI in a secure environment"
    echo
    
    echo -e "${DIM}  ────────────────────────────────────────────────────────────────────────────${NC}"
    echo -e "${YELLOW}  Press Enter to continue...${NC}"
    read -r
}

# Show image building screen
show_building_screen() {
    echo
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                          ${WHITE}Building ClaudeBox Image${NC}                            ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${WHITE}  📦 Setting up your development environment...${NC}"
    echo
    echo -e "${DIM}  This process will:${NC}"
    echo -e "${DIM}    • Install Claude CLI and dependencies${NC}"
    echo -e "${DIM}    • Configure development profiles${NC}"
    echo -e "${DIM}    • Set up security features${NC}"
    echo -e "${DIM}    • Prepare the container environment${NC}"
    echo
    echo -e "${YELLOW}  ⏱️  This may take a few minutes on first run...${NC}"
    echo
}

# Show post-build next steps
show_next_steps() {
    echo
    echo -e "${GREEN}  ✅ Docker image built successfully!${NC}"
    echo
    echo -e "${WHITE}  NEXT STEPS${NC}"
    echo -e "${DIM}  ────────────────────────────────────────────────────────────────────────────${NC}"
    echo
    echo -e "     ${WHITE}1.${NC} Create an authenticated slot:"
    echo -e "        ${GREEN}claudebox create${NC}"
    echo
    echo -e "     ${WHITE}2.${NC} Or explore available options:"
    echo -e "        ${GREEN}claudebox help${NC}"
    echo
    echo -e "${DIM}  For more information, visit: https://github.com/RchGrav/claudebox${NC}"
    echo
}

# Export functions
export -f show_welcome_screen show_building_screen show_next_steps