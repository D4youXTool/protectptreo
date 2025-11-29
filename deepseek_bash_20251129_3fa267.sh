#!/bin/bash

# =============================================
# XNoctra Pterodactyl Protection System
# Author: XNoctra
# Telegram: t.me/XNoctra
# Version: 2.0
# =============================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Animation
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Banner
show_banner() {
    clear
    echo -e "${PURPLE}"
    echo " ██╗  ██╗███╗   ██╗ ██████╗ ██████╗████████╗██████╗  █████╗ "
    echo " ╚██╗██╔╝████╗  ██║██╔═══██╗██╔════╝╚══██╔══╝██╔══██╗██╔══██╗"
    echo "  ╚███╔╝ ██╔██╗ ██║██║   ██║██║        ██║   ██████╔╝███████║"
    echo "  ██╔██╗ ██║╚██╗██║██║   ██║██║        ██║   ██╔══██╗██╔══██║"
    echo " ██╔╝ ██╗██║ ╚████║╚██████╔╝╚██████╗   ██║   ██║  ██║██║  ██║"
    echo " ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝  ╚═════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝"
    echo -e "${NC}"
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              Pterodactyl Protection System v2.0          ║${NC}"
    echo -e "${CYAN}║                 Created by XNoctra                       ║${NC}"
    echo -e "${CYAN}║           Telegram: t.me/XNoctra                         ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Check root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}❌ Error: Do not run as root user!${NC}"
        echo -e "${YELLOW}💡 Use: sudo -u pterodactyl bash $0${NC}"
        exit 1
    fi
}

# Check Pterodactyl
check_pterodactyl() {
    echo -e "${YELLOW}🔍 Checking Pterodactyl installation...${NC}"
    
    if [ ! -d "/var/www/pterodactyl" ]; then
        echo -e "${RED}❌ Pterodactyl not found in /var/www/pterodactyl${NC}"
        exit 1
    fi
    
    if [ ! -f "/var/www/pterodactyl/artisan" ]; then
        echo -e "${RED}❌ Artisan file not found${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Pterodactyl detected${NC}"
}

# Check dependencies
check_dependencies() {
    echo -e "${YELLOW}📦 Checking dependencies...${NC}"
    
    local missing=()
    
    if ! command -v curl &> /dev/null; then
        missing+=("curl")
    fi
    
    if ! command -v php &> /dev/null; then
        missing+=("php")
    fi
    
    if ! command -v mysql &> /dev/null; then
        missing+=("mysql")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚠️ Installing missing dependencies: ${missing[*]}${NC}"
        sudo apt update
        sudo apt install -y "${missing[@]}"
    fi
    
    echo -e "${GREEN}✅ Dependencies satisfied${NC}"
}

# Download protection scripts
download_scripts() {
    echo -e "${YELLOW}📥 Downloading protection scripts...${NC}"
    
    # Base URL
    BASE_URL="https://raw.githubusercontent.com/XNoctra/pterodactyl-protections/main"
    
    # Create temp directory
    TEMP_DIR="/tmp/xnoctra-protections"
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    # Script list
    local scripts=(
        "installprotect1.sh" "installprotect2.sh" "installprotect3.sh"
        "installprotect4.sh" "installprotect5.sh" "installprotect6.sh"
        "installprotect7.sh" "installprotect8.sh" "installprotect9.sh"
        "uninstallprotect1.sh" "uninstallprotect2.sh" "uninstallprotect3.sh"
        "uninstallprotect4.sh" "uninstallprotect5.sh" "uninstallprotect6.sh"
        "uninstallprotect7.sh" "uninstallprotect8.sh" "uninstallprotect9.sh"
        "protect-manager.sh" "installprotectall.sh" "uninstallprotectall.sh"
    )
    
    # Download all scripts
    for script in "${scripts[@]}"; do
        echo -e "${BLUE}📥 Downloading $script...${NC}"
        if curl -s -O "$BASE_URL/$script"; then
            chmod +x "$script"
            echo -e "${GREEN}✅ $script downloaded${NC}"
        else
            echo -e "${RED}❌ Failed to download $script${NC}"
            return 1
        fi
    done
    
    echo -e "${GREEN}✅ All scripts downloaded successfully${NC}"
    return 0
}

# Show main menu
show_main_menu() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                      MAIN MENU                           ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}🚀 Installation Options:${NC}"
    echo -e "  ${YELLOW}1${NC}. 🛡️  Install All Protections"
    echo -e "  ${YELLOW}2${NC}. 🔧 Install Individual Protection"
    echo -e ""
    echo -e "${RED}🗑️  Removal Options:${NC}"
    echo -e "  ${YELLOW}3${NC}. 🗑️  Uninstall All Protections"
    echo -e "  ${YELLOW}4${NC}. 🛠️  Uninstall Individual Protection"
    echo -e ""
    echo -e "${BLUE}🔧 Management Options:${NC}"
    echo -e "  ${YELLOW}5${NC}. 📊 Protection Status"
    echo -e "  ${YELLOW}6${NC}. 🎨 Advanced Manager"
    echo -e "  ${YELLOW}7${NC}. 🔄 Update Scripts"
    echo -e "  ${YELLOW}8${NC}. ℹ️  System Information"
    echo -e ""
    echo -e "${PURPLE}   ${YELLOW}0${NC}. ❌ Exit"
    echo ""
}

# Install all protections
install_all() {
    echo -e "${YELLOW}🚀 Installing all protections...${NC}"
    
    if [ -f "installprotectall.sh" ]; then
        bash installprotectall.sh
    else
        echo -e "${RED}❌ installprotectall.sh not found${NC}"
        return 1
    fi
}

# Install individual
install_individual() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                  INDIVIDUAL INSTALLATION                 ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}📋 Available Protections:${NC}"
    echo -e "  ${YELLOW}1${NC}. 🛡️  Anti Delete Server"
    echo -e "  ${YELLOW}2${NC}. 👥 Anti Delete/Edit User"
    echo -e "  ${YELLOW}3${NC}. 📍 Anti Location Access"
    echo -e "  ${YELLOW}4${NC}. 🖥️  Anti Node Access"
    echo -e "  ${YELLOW}5${NC}. 🐣 Anti Nest Access"
    echo -e "  ${YELLOW}6${NC}. ⚙️  Anti Settings Access"
    echo -e "  ${YELLOW}7${NC}. 📁 Anti File Access"
    echo -e "  ${YELLOW}8${NC}. 🎮 Anti Server Controller Access"
    echo -e "  ${YELLOW}9${NC}. ✏️  Anti Server Modification"
    echo ""
    
    read -p "Select protection to install [1-9]: " choice
    
    if [[ $choice =~ ^[1-9]$ ]]; then
        if [ -f "installprotect$choice.sh" ]; then
            bash "installprotect$choice.sh"
        else
            echo -e "${RED}❌ installprotect$choice.sh not found${NC}"
        fi
    else
        echo -e "${RED}❌ Invalid selection!${NC}"
    fi
}

# Uninstall all
uninstall_all() {
    echo -e "${YELLOW}🗑️  Uninstalling all protections...${NC}"
    
    if [ -f "uninstallprotectall.sh" ]; then
        bash uninstallprotectall.sh
    else
        echo -e "${RED}❌ uninstallprotectall.sh not found${NC}"
        return 1
    fi
}

# Uninstall individual
uninstall_individual() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                 INDIVIDUAL UNINSTALLATION                ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}📋 Available Protections:${NC}"
    echo -e "  ${YELLOW}1${NC}. 🛡️  Anti Delete Server"
    echo -e "  ${YELLOW}2${NC}. 👥 Anti Delete/Edit User"
    echo -e "  ${YELLOW}3${NC}. 📍 Anti Location Access"
    echo -e "  ${YELLOW}4${NC}. 🖥️  Anti Node Access"
    echo -e "  ${YELLOW}5${NC}. 🐣 Anti Nest Access"
    echo -e "  ${YELLOW}6${NC}. ⚙️  Anti Settings Access"
    echo -e "  ${YELLOW}7${NC}. 📁 Anti File Access"
    echo -e "  ${YELLOW}8${NC}. 🎮 Anti Server Controller Access"
    echo -e "  ${YELLOW}9${NC}. ✏️  Anti Server Modification"
    echo ""
    
    read -p "Select protection to uninstall [1-9]: " choice
    
    if [[ $choice =~ ^[1-9]$ ]]; then
        if [ -f "uninstallprotect$choice.sh" ]; then
            bash "uninstallprotect$choice.sh"
        else
            echo -e "${RED}❌ uninstallprotect$choice.sh not found${NC}"
        fi
    else
        echo -e "${RED}❌ Invalid selection!${NC}"
    fi
}

# Show status
show_status() {
    echo -e "${YELLOW}📊 Checking protection status...${NC}"
    
    if [ -f "protect-manager.sh" ]; then
        bash protect-manager.sh --status
    else
        # Manual status check
        declare -A protections=(
            ["Anti Delete Server"]="/var/www/pterodactyl/app/Services/Servers/ServerDeletionService.php"
            ["Anti Delete/Edit User"]="/var/www/pterodactyl/app/Http/Controllers/Admin/UserController.php"
            ["Anti Location Access"]="/var/www/pterodactyl/app/Http/Controllers/Admin/LocationController.php"
            ["Anti Node Access"]="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeController.php"
            ["Anti Nest Access"]="/var/www/pterodactyl/app/Http/Controllers/Admin/Nests/NestController.php"
            ["Anti Settings Access"]="/var/www/pterodactyl/app/Http/Controllers/Admin/Settings/IndexController.php"
            ["Anti File Access"]="/var/www/pterodactyl/app/Http/Controllers/Api/Client/Servers/FileController.php"
            ["Anti Server Controller Access"]="/var/www/pterodactyl/app/Http/Controllers/Api/Client/Servers/ServerController.php"
            ["Anti Server Modification"]="/var/www/pterodactyl/app/Services/Servers/DetailsModificationService.php"
        )
        
        echo ""
        echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║                     PROTECTION STATUS                    ║${NC}"
        echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
        echo ""
        
        local active=0
        local total=0
        
        for protection in "${!protections[@]}"; do
            file="${protections[$protection]}"
            ((total++))
            
            if [ -f "$file" ]; then
                if grep -q "XNoctra\|PROTECT" "$file" 2>/dev/null; then
                    echo -e "  ${GREEN}✅${NC} $protection ${GREEN}(ACTIVE)${NC}"
                    ((active++))
                else
                    echo -e "  ${YELLOW}⚠️${NC} $protection ${YELLOW}(FILE EXISTS)${NC}"
                fi
            else
                echo -e "  ${RED}❌${NC} $protection ${RED}(NOT INSTALLED)${NC}"
            fi
        done
        
        echo ""
        echo -e "${BLUE}📈 Summary: $active/$total protections active${NC}"
    fi
}

# Run advanced manager
run_manager() {
    echo -e "${YELLOW}🎨 Starting Protection Manager...${NC}"
    
    if [ -f "protect-manager.sh" ]; then
        bash protect-manager.sh
    else
        echo -e "${RED}❌ protect-manager.sh not found${NC}"
    fi
}

# Update scripts
update_scripts() {
    echo -e "${YELLOW}🔄 Updating protection scripts...${NC}"
    
    # Remove old scripts
    rm -f *.sh
    
    # Download fresh scripts
    if download_scripts; then
        echo -e "${GREEN}✅ Scripts updated successfully${NC}"
    else
        echo -e "${RED}❌ Failed to update scripts${NC}"
    fi
}

# System information
system_info() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    SYSTEM INFORMATION                    ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Pterodactyl info
    echo -e "${GREEN}🦋 Pterodactyl Panel:${NC}"
    if [ -f "/var/www/pterodactyl/composer.json" ]; then
        version=$(grep -oP '"version": "\K[^"]+' /var/www/pterodactyl/composer.json)
        echo -e "   ${BLUE}Version:${NC} $version"
    else
        echo -e "   ${RED}Not detected${NC}"
    fi
    
    # System info
    echo -e "${GREEN}💻 System:${NC}"
    echo -e "   ${BLUE}OS:${NC} $(lsb_release -d | cut -f2)"
    echo -e "   ${BLUE}Kernel:${NC} $(uname -r)"
    echo -e "   ${BLUE}Architecture:${NC} $(uname -m)"
    
    # Resource info
    echo -e "${GREEN}📊 Resources:${NC}"
    echo -e "   ${BLUE}RAM:${NC} $(free -h | awk '/^Mem:/ {print $2}')"
    echo -e "   ${BLUE}Disk:${NC} $(df -h / | awk 'NR==2 {print $2}')"
    
    # Protection info
    echo -e "${GREEN}🛡️  Protection System:${NC}"
    echo -e "   ${BLUE}Developer:${NC} XNoctra"
    echo -e "   ${BLUE}Telegram:${NC} t.me/XNoctra"
    echo -e "   ${BLUE}Version:${NC} 2.0"
    echo -e "   ${BLUE}Protections:${NC} 9 Layers"
}

# Main function
main() {
    show_banner
    
    # Initial checks
    check_root
    check_pterodactyl
    check_dependencies
    
    # Download scripts
    if ! download_scripts; then
        echo -e "${RED}❌ Failed to download protection scripts${NC}"
        exit 1
    fi
    
    # Main menu loop
    while true; do
        show_main_menu
        read -p "Select option [0-8]: " choice
        
        case $choice in
            1) install_all ;;
            2) install_individual ;;
            3) uninstall_all ;;
            4) uninstall_individual ;;
            5) show_status ;;
            6) run_manager ;;
            7) update_scripts ;;
            8) system_info ;;
            0)
                echo ""
                echo -e "${GREEN}👋 Thank you for using XNoctra Protection System!${NC}"
                echo -e "${YELLOW}📞 Telegram: t.me/XNoctra${NC}"
                echo ""
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Invalid option!${NC}"
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
        show_banner
    done
}

# Run main function
main "$@"