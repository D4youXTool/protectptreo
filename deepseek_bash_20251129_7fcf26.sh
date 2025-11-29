#!/bin/bash

# =============================================
# XNoctra - Install All Protections
# One-click installation of all 9 protections
# =============================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║               XNOCTRA - INSTALL ALL PROTECTIONS          ║"
echo "║                  Telegram: t.me/XNoctra                  ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if all install scripts exist
MISSING_SCRIPTS=()
for i in {1..9}; do
    if [ ! -f "installprotect$i.sh" ]; then
        MISSING_SCRIPTS+=("installprotect$i.sh")
    fi
done

if [ ${#MISSING_SCRIPTS[@]} -gt 0 ]; then
    echo -e "${RED}❌ Missing installation scripts:${NC}"
    for script in "${MISSING_SCRIPTS[@]}"; do
        echo "   - $script"
    done
    echo -e "${YELLOW}Please download all protection scripts first${NC}"
    exit 1
fi

# Confirm installation
echo -e "${YELLOW}⚠️  This will install ALL 9 XNoctra protections${NC}"
echo -e "${YELLOW}📋 Protections to be installed:${NC}"
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

read -p "Are you sure you want to continue? (y/N): " confirm

if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Installation cancelled${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}🚀 Starting installation of all protections...${NC}"
echo ""

# Install all protections
SUCCESS_COUNT=0
for i in {1..9}; do
    echo -e "${BLUE}══════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Installing protection $i/9...${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════════════════${NC}"
    
    if bash "installprotect$i.sh"; then
        echo -e "${GREEN}✅ Protection $i installed successfully${NC}"
        ((SUCCESS_COUNT++))
    else
        echo -e "${RED}❌ Failed to install protection $i${NC}"
    fi
    echo ""
done

# Clear cache
echo -e "${YELLOW}🧹 Optimizing Pterodactyl...${NC}"
cd /var/www/pterodactyl
php artisan config:cache > /dev/null 2>&1
php artisan view:cache > /dev/null 2>&1
php artisan route:cache > /dev/null 2>&1

echo ""
echo -e "${BLUE}══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🎉 INSTALLATION COMPLETED!${NC}"
echo -e "${BLUE}══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ $SUCCESS_COUNT/9 protections installed successfully${NC}"
echo ""
echo -e "${YELLOW}📋 Installation Summary:${NC}"
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
echo -e "${GREEN}🔒 Your Pterodactyl panel is now protected by XNoctra!${NC}"
echo -e "${YELLOW}📞 Need help? Telegram: t.me/XNoctra${NC}"
echo -e "${BLUE}══════════════════════════════════════════════════════════${NC}"