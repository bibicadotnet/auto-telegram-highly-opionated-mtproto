#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
AUTO_MODE=false
DEFAULT_PORT=$((RANDOM%20000+10000))
DOMAIN_LIST=("google.com" "youtube.com" "facebook.com" "twitter.com" "instagram.com" "wikipedia.org" "reddit.com" "amazon.com" "microsoft.com" "apple.com")

# Check for --auto flag
if [[ $1 == "--auto" ]]; then
    AUTO_MODE=true
fi

echo ""
echo -e "${GREEN}############################################################################${NC}"
echo -e "${GREEN}#     		 TELEGRAM MTPROTO Proxy Installer (Manual/Auto Mode)       #${NC}"
echo -e "${GREEN}############################################################################${NC}"
echo ""

# Disable firewall
# apt remove iptables-persistent -y >/dev/null 2>&1
# ufw disable >/dev/null 2>&1
# iptables -F >/dev/null 2>&1

# Create working directory
WORKDIR="$HOME/telegram-mtproto"
mkdir -p "$WORKDIR"
cd "$WORKDIR" || exit

# Check and install Docker
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com | sh >/dev/null 2>&1
    systemctl enable --now docker >/dev/null 2>&1
fi

# Get server IP
ip=$(curl -4 -s ip.sb)

# Set port and domain based on mode
if $AUTO_MODE; then
    port=$DEFAULT_PORT
    domain=${DOMAIN_LIST[$RANDOM % ${#DOMAIN_LIST[@]}]}
    echo -e "${YELLOW}Auto mode enabled${NC}"
    echo -e "Port: ${BLUE}$port${NC} (random)"
    echo -e "Domain: ${BLUE}$domain${NC} (random)"
else
    read -p "Enter port [1-65535] (random default): " port
    port=${port:-$DEFAULT_PORT}
    read -p "Enter fake domain (default google.com): " domain
    domain=${domain:-"google.com"}
fi

# Generate secret key
echo "Generating secret key..."
secret=$(docker run --rm nineseconds/mtg:master generate-secret "$domain" | head -n 1 | awk '{print $NF}')

# Remove old files if exist
rm -f compose.yml mtg.toml mtp.txt

# Create compose.yml
cat > compose.yml <<EOF
services:
  mtg:
    image: nineseconds/mtg:master
    container_name: mtg
    restart: unless-stopped
    ports:
      - "$port:3128"
    volumes:
      - $WORKDIR/mtg.toml:/config.toml
EOF

# Create config file
cat > mtg.toml <<EOF
secret = "$secret"
bind-to = "0.0.0.0:3128"
EOF

# Stop and remove old container
docker compose down >/dev/null 2>&1

# Start service
echo "Starting service..."
docker compose up -d --build --remove-orphans --force-recreate >/dev/null 2>&1

# Display results
echo ""
echo -e "${YELLOW}================================================================================================${NC}"
echo -e ""
echo -e "${GREEN}                TELEGRAM PROXY LINK                ${NC}"
echo -e ""
echo -e "        ${BLUE}tg://proxy?server=$ip&port=$port&secret=$secret${NC}"
echo -e ""
echo -e "${YELLOW}================================================================================================${NC}"
echo ""
echo -e "Configuration directory: ${YELLOW}$WORKDIR${NC}"
echo -e "Link saved to: ${YELLOW}$WORKDIR/mtp.txt${NC}"
echo "tg://proxy?server=$ip&port=$port&secret=$secret" > mtp.txt
