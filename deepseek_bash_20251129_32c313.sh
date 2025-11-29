#!/bin/bash

# =============================================
# XNoctra - Uninstall All Protections
# Remove all XNoctra protections from Pterodactyl
# =============================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║              XNOCTRA - UNINSTALL ALL PROTECTIONS         ║"
echo "║                  Telegram: t.me/XNoctra                  ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if all uninstall scripts exist
MISSING_SCRIPTS=()
for i in {1..9}; do
    if [ ! -f "uninstallprotect$i.sh" ]; then
        MISSING_SCRIPTS+=("uninstallprotect$i.sh")
    fi
done

if [ ${#MISSING_SCRIPTS[@]} -gt 0 ]; then
    echo -e "${RED}❌ Missing uninstall scripts:${NC}"
    for script in "${MISSING_SCRIPTS[@]}"; do
        echo "   - $script"
    done
    echo -e "${YELLOW}Please download all protection scripts first${NC}"
    exit 1
fi

# Warning message
echo -e "${RED}🚨 WARNING: This will remove ALL XNoctra protections!${NC}"
echo -e "${YELLOW}📋 Protections to be removed:${NC}"
echo "   1. 🛡️  Anti Delete Server"
echo "   2. 👥 Anti Delete/Edit User" 
echo "   3. 📍 Anti Location Access"
echo "   4. 🖥️  Anti Node Access"
echo "   5. 🐣 Anti Nest Access"
echo "   6. ⚙️  Anti Settings Access"
echo "   7. 📁 Anti File Access"
echo "   8. 🎮 Anti Server Controller Access"
echo "   9. ✏️  Anti Server Modification"
echo ""
echo -e "${RED}⚠️  This action cannot be undone!${NC}"
echo ""

read -p "Are you ABSOLUTELY sure you want to continue? (type 'YES' to confirm): " confirm

if [[ "$confirm" != "YES" ]]; then
    echo -e "${YELLOW}Uninstallation cancelled${NC}"
    exit 0
fi

echo ""
echo -e "${RED}🗑️  Removing all protections...${NC}"
echo ""

# Remove all protections
SUCCESS_COUNT=0
for i in {1..9}; do
    echo -e "${BLUE}══════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Removing protection $i/9...${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════════════════${NC}"
    
    if bash "uninstallprotect$i.sh"; then
        echo -e "${GREEN}✅ Protection $i removed successfully${NC}"
        ((SUCCESS_COUNT++))
    else
        echo -e "${RED}❌ Failed to remove protection $i${NC}"
    fi
    echo ""
done

# Clear cache
echo -e "${YELLOW}🧹 Cleaning up...${NC}"
cd /var/www/pterodactyl
php artisan config:cache > /dev/null 2>&1
php artisan view:cache > /dev/null 2>&1
php artisan route:cache > /dev/null 2>&1

echo ""
echo -e "${BLUE}══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🎉 UNINSTALLATION COMPLETED!${NC}"
echo -e "${BLUE}══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ $SUCCESS_COUNT/9 protections removed successfully${NC}"
echo ""
echo -e "${YELLOW}📋 Removal Summary:${NC}"
echo "   🛡️  Anti Delete Server - $( [ $SUCCESS_COUNT -ge 1 ] && echo "✅" || echo "❌" )"
echo "   👥 Anti Delete/Edit User - $( [ $SUCCESS_COUNT -ge 2 ] && echo "✅" || echo "❌" )"
echo "   📍 Anti Location Access - $( [ $SUCCESS_COUNT -ge 3 ] && echo "✅" || echo "❌" )"
echo "   🖥️  Anti Node Access - $( [ $SUCCESS_COUNT -ge 4 ] && echo "✅" || echo "❌" )"
echo "   🐣 Anti Nest Access - $( [ $SUCCESS_COUNT -ge 5 ] && echo "✅" || echo "❌" )"
echo "   ⚙️  Anti Settings Access - $( [ $SUCCESS_COUNT -ge 6 ] && echo "✅" || echo "❌" )"
echo "   📁 Anti File Access - $( [ $SUCCESS_COUNT -ge 7 ] && echo "✅" || echo "❌" )"
echo "   🎮 Anti Server Controller Access - $( [ $SUCCESS_COUNT -ge 8 ] && echo "✅" || echo "❌" )"
echo "   ✏️  Anti Server Modification - $( [ $SUCCESS_COUNT -ge 9 ] && echo "✅" || echo "❌" )"
echo ""
echo -e "${RED}⚠️  Your Pterodactyl panel is no longer protected!${NC}"
echo -e "${YELLOW}💡 You can reinstall protections anytime using the installer${NC}"
echo -e "${BLUE}══════════════════════════════════════════════════════════${NC}"