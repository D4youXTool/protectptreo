#!/bin/bash

# =============================================
# XNoctra Protection Manager
# Advanced protection management system
# Author: XNoctra
# Version: 2.0
# =============================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
BASE_DIR="/var/www/pterodactyl"
BACKUP_DIR="/var/www/pterodactyl/backups/xnoctra"
LOG_FILE="/var/log/xnoctra-protections.log"

# Protection files configuration
declare -A PROTECTION_FILES=(
    ["1"]="/var/www/pterodactyl/app/Services/Servers/ServerDeletionService.php"
    ["2"]="/var/www/pterodactyl/app/Http/Controllers/Admin/UserController.php"
    ["3"]="/var/www/pterodactyl/app/Http/Controllers/Admin/LocationController.php"
    ["4"]="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeController.php"
    ["5"]="/var/www/pterodactyl/app/Http/Controllers/Admin/Nests/NestController.php"
    ["6"]="/var/www/pterodactyl/app/Http/Controllers/Admin/Settings/IndexController.php"
    ["7"]="/var/www/pterodactyl/app/Http/Controllers/Api/Client/Servers/FileController.php"
    ["8"]="/var/www/pterodactyl/app/Http/Controllers/Api/Client/Servers/ServerController.php"
    ["9"]="/var/www/pterodactyl/app/Services/Servers/DetailsModificationService.php"
)

declare -A PROTECTION_NAMES=(
    ["1"]="Anti Delete Server"
    ["2"]="Anti Delete/Edit User"
    ["3"]="Anti Location Access"
    ["4"]="Anti Node Access"
    ["5"]="Anti Nest Access"
    ["6"]="Anti Settings Access"
    ["7"]="Anti File Access"
    ["8"]="Anti Server Controller Access"
    ["9"]="Anti Server Modification"
)

# Logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Banner
show_banner() {
    echo -e "${PURPLE}"
    echo " ██████╗ ██████╗ ██████╗ ███████╗██████╗ ████████╗"
    echo "██╔════╝██╔═══██╗██╔══██╗██╔════╝██╔══██╗╚══██╔══╝"
    echo "██║     ██║   ██║██████╔╝█████╗  ██████╔╝   ██║   "
    echo "██║     ██║   ██║██╔══██╗██╔══╝  ██╔══██╗   ██║   "
    echo "╚██████╗╚██████╔╝██║  ██║███████╗██║  ██║   ██║   "
    echo " ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝   "
    echo -e "${NC}"
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                  PROTECTION MANAGER v2.0                 ║${NC}"
    echo -e "${CYAN}║                     By XNoctra                           ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Create backup
create_backup() {
    local file=$1
    local timestamp=$(date -u +"%Y%m%d_%H%M%S")
    local backup_file="$BACKUP_DIR/$(basename "$file").backup_$timestamp"
    
    mkdir -p "$BACKUP_DIR"
    
    if [ -f "$file" ]; then
        cp "$file" "$backup_file"
        echo -e "${GREEN}✅ Backup created: $backup_file${NC}"
        log "Backup created: $backup_file"
        return 0
    else
        echo -e "${YELLOW}⚠️  File not found: $file${NC}"
        return 1
    fi
}

# Restore backup
restore_backup() {
    local protection_id=$1
    local file="${PROTECTION_FILES[$protection_id]}"
    
    local backups=($(ls -1t "$BACKUP_DIR/$(basename "$file").backup_"* 2>/dev/null))
    
    if [ ${#backups[@]} -eq 0 ]; then
        echo -e "${RED}❌ No backups found for ${PROTECTION_NAMES[$protection_id]}${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}📋 Available backups:${NC}"
    for i in "${!backups[@]}"; do
        echo -e "  ${YELLOW}$((i+1))${NC}. ${backups[$i]}"
    done
    
    read -p "Select backup to restore [1-${#backups[@]}]: " choice
    
    if [[ $choice =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#backups[@]}" ]; then
        local selected_backup="${backups[$((choice-1))]}"
        cp "$selected_backup" "$file"
        echo -e "${GREEN}✅ Backup restored: $selected_backup${NC}"
        log "Backup restored: $selected_backup"
        return 0
    else
        echo -e "${RED}❌ Invalid selection${NC}"
        return 1
    fi
}

# Check protection status
check_protection_status() {
    echo -e "${YELLOW}🔍 Checking protection status...${NC}"
    echo ""
    
    local active_count=0
    local total_count=0
    
    echo -e "${CYAN}┌──────────────────────────────────────────┬─────────────┐${NC}"
    echo -e "${CYAN}│ Protection Name                         │ Status      │${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────┼─────────────┤${NC}"
    
    for id in "${!PROTECTION_FILES[@]}"; do
        local file="${PROTECTION_FILES[$id]}"
        local name="${PROTECTION_NAMES[$id]}"
        ((total_count++))
        
        if [ -f "$file" ]; then
            if grep -q "XNoctra\|PROTECT" "$file" 2>/dev/null; then
                echo -e "${CYAN}│ ${GREEN}%-40s${CYAN} │ ${GREEN}%-11s${CYAN} │${NC}" "$name" "ACTIVE"
                ((active_count++))
            else
                echo -e "${CYAN}│ ${YELLOW}%-40s${CYAN} │ ${YELLOW}%-11s${CYAN} │${NC}" "$name" "INACTIVE"
            fi
        else
            echo -e "${CYAN}│ ${RED}%-40s${CYAN} │ ${RED}%-11s${CYAN} │${NC}" "$name" "MISSING"
        fi
    done
    
    echo -e "${CYAN}└──────────────────────────────────────────┴─────────────┘${NC}"
    echo ""
    echo -e "${BLUE}📊 Summary: ${GREEN}$active_count/${total_count} protections active${NC}"
}

# Clear cache
clear_cache() {
    echo -e "${YELLOW}🧹 Clearing Pterodactyl cache...${NC}"
    
    cd "$BASE_DIR"
    
    php artisan config:clear
    php artisan view:clear
    php artisan cache:clear
    php artisan route:clear
    
    echo -e "${GREEN}✅ Cache cleared successfully${NC}"
    log "Cache cleared"
}

# Show protection info
show_protection_info() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                   PROTECTION INFORMATION                 ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    for id in "${!PROTECTION_NAMES[@]}"; do
        echo -e "${GREEN}${id}. ${PROTECTION_NAMES[$id]}${NC}"
        echo -e "   ${BLUE}File:${NC} ${PROTECTION_FILES[$id]}"
        echo ""
    done
}

# Main menu
show_menu() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                     MANAGER MENU                         ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}🔍 Status & Info:${NC}"
    echo -e "  ${YELLOW}1${NC}. 📊 Check Protection Status"
    echo -e "  ${YELLOW}2${NC}. ℹ️  Show Protection Information"
    echo -e ""
    echo -e "${BLUE}🛠️  Maintenance:${NC}"
    echo -e "  ${YELLOW}3${NC}. 💾 Create Backup"
    echo -e "  ${YELLOW}4${NC}. 🔄 Restore Backup"
    echo -e "  ${YELLOW}5${NC}. 🧹 Clear Cache"
    echo -e "  ${YELLOW}6${NC}. 📋 View Logs"
    echo -e ""
    echo -e "${PURPLE}   ${YELLOW}0${NC}. ❌ Exit to Main Menu"
    echo ""
}

# Main function
main() {
    show_banner
    
    while true; do
        show_menu
        read -p "Select option [0-6]: " choice
        
        case $choice in
            1)
                check_protection_status
                ;;
            2)
                show_protection_info
                ;;
            3)
                echo ""
                echo -e "${YELLOW}Select protection to backup:${NC}"
                for id in "${!PROTECTION_NAMES[@]}"; do
                    echo -e "  ${YELLOW}$id${NC}. ${PROTECTION_NAMES[$id]}"
                done
                read -p "Enter protection number [1-9]: " protect_id
                if [[ $protect_id =~ ^[1-9]$ ]]; then
                    create_backup "${PROTECTION_FILES[$protect_id]}"
                else
                    echo -e "${RED}❌ Invalid protection number${NC}"
                fi
                ;;
            4)
                echo ""
                echo -e "${YELLOW}Select protection to restore:${NC}"
                for id in "${!PROTECTION_NAMES[@]}"; do
                    echo -e "  ${YELLOW}$id${NC}. ${PROTECTION_NAMES[$id]}"
                done
                read -p "Enter protection number [1-9]: " protect_id
                if [[ $protect_id =~ ^[1-9]$ ]]; then
                    restore_backup "$protect_id"
                else
                    echo -e "${RED}❌ Invalid protection number${NC}"
                fi
                ;;
            5)
                clear_cache
                ;;
            6)
                echo -e "${YELLOW}📋 Protection Logs:${NC}"
                if [ -f "$LOG_FILE" ]; then
                    tail -20 "$LOG_FILE"
                else
                    echo -e "${YELLOW}No logs found${NC}"
                fi
                ;;
            0)
                echo -e "${GREEN}👋 Returning to main menu...${NC}"
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

# Handle command line arguments
case "${1:-}" in
    "--status"|"-s")
        check_protection_status
        ;;
    "--help"|"-h")
        echo "XNoctra Protection Manager"
        echo "Usage: $0 [OPTION]"
        echo ""
        echo "Options:"
        echo "  -s, --status    Check protection status"
        echo "  -h, --help      Show this help message"
        echo ""
        ;;
    *)
        main
        ;;
esac