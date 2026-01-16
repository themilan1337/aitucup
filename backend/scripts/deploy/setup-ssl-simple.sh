#!/bin/bash

################################################################################
# Simple SSL Certificate Setup Script
#
# This script uses standalone mode - Nginx must be stopped temporarily
# Usage: sudo bash setup-ssl-simple.sh
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DOMAIN="api.muscleup.fitness"
EMAIL="admin@muscleup.fitness"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  SSL Certificate Setup (Standalone)${NC}"
echo -e "${GREEN}  Domain: $DOMAIN${NC}"
echo -e "${GREEN}  Email: $EMAIL${NC}"
echo -e "${GREEN}========================================${NC}"

# Check if certbot is installed
if ! command -v certbot &> /dev/null; then
    echo -e "${YELLOW}Installing Certbot...${NC}"
    apt-get update
    apt-get install -y certbot
fi

# Check DNS resolution
echo -e "\n${YELLOW}Checking DNS resolution for $DOMAIN...${NC}"
RESOLVED_IP=$(dig +short $DOMAIN | tail -n1)
if [ -z "$RESOLVED_IP" ]; then
    echo -e "${RED}✗ DNS not configured for $DOMAIN${NC}"
    exit 1
fi
echo -e "${GREEN}✓ DNS resolves to: $RESOLVED_IP${NC}"

# Check what's using port 80
echo -e "\n${YELLOW}Checking port 80...${NC}"
PORT_80_PROCESS=$(lsof -ti :80 || true)

if [ -n "$PORT_80_PROCESS" ]; then
    echo -e "${YELLOW}Found processes using port 80:${NC}"
    lsof -i :80 || true

    # Stop Nginx if it's running
    if systemctl is-active --quiet nginx; then
        echo -e "${YELLOW}Stopping Nginx...${NC}"
        systemctl stop nginx
        sleep 2
    fi

    # Check again
    PORT_80_PROCESS=$(lsof -ti :80 || true)
    if [ -n "$PORT_80_PROCESS" ]; then
        echo -e "${YELLOW}Other processes still using port 80:${NC}"
        lsof -i :80 || true
        echo -e "\n${RED}Please stop these processes manually:${NC}"
        echo -e "  sudo kill $PORT_80_PROCESS"
        echo -e "\nOr stop all processes on port 80:"
        echo -e "  sudo fuser -k 80/tcp"
        read -p "Stop all processes on port 80? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            fuser -k 80/tcp || true
            sleep 2
        else
            exit 1
        fi
    fi
else
    # Stop Nginx if it's running
    if systemctl is-active --quiet nginx; then
        echo -e "${YELLOW}Stopping Nginx...${NC}"
        systemctl stop nginx
        sleep 2
    fi
fi

echo -e "${GREEN}✓ Port 80 is now available${NC}"

# Obtain SSL certificate using standalone mode
echo -e "\n${YELLOW}Obtaining SSL certificate from Let's Encrypt...${NC}"
echo -e "${YELLOW}This may take a few moments...${NC}"

certbot certonly \
    --standalone \
    --preferred-challenges http \
    -d $DOMAIN \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    --non-interactive

CERT_STATUS=$?

# Start Nginx again
echo -e "\n${YELLOW}Starting Nginx...${NC}"
systemctl start nginx

if [ $CERT_STATUS -eq 0 ]; then
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}  SSL Certificate Installed!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo -e "Domain: $DOMAIN"
    echo -e "Certificate: /etc/letsencrypt/live/$DOMAIN/fullchain.pem"
    echo -e "Private Key: /etc/letsencrypt/live/$DOMAIN/privkey.pem"
    echo -e ""
    echo -e "Auto-renewal is configured via systemd timer"
    echo -e "Check status: systemctl status certbot.timer"
    echo -e ""
    echo -e "${GREEN}Your API will be accessible at: https://$DOMAIN${NC}"
else
    echo -e "\n${RED}========================================${NC}"
    echo -e "${RED}  SSL Certificate Installation Failed${NC}"
    echo -e "${RED}========================================${NC}"
    exit 1
fi

# Create renewal hook script for Nginx reload
echo -e "\n${YELLOW}Setting up auto-renewal hooks...${NC}"
mkdir -p /etc/letsencrypt/renewal-hooks/deploy
cat > /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh <<'HOOK'
#!/bin/bash
systemctl reload nginx
HOOK

chmod +x /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh

# Update certbot renewal to use standalone with pre/post hooks
mkdir -p /etc/letsencrypt/renewal-hooks/pre
mkdir -p /etc/letsencrypt/renewal-hooks/post

cat > /etc/letsencrypt/renewal-hooks/pre/stop-nginx.sh <<'PREHOOK'
#!/bin/bash
systemctl stop nginx
PREHOOK

cat > /etc/letsencrypt/renewal-hooks/post/start-nginx.sh <<'POSTHOOK'
#!/bin/bash
systemctl start nginx
POSTHOOK

chmod +x /etc/letsencrypt/renewal-hooks/pre/stop-nginx.sh
chmod +x /etc/letsencrypt/renewal-hooks/post/start-nginx.sh

echo -e "${GREEN}✓ Auto-renewal hooks configured${NC}"

# Test renewal (dry-run)
echo -e "\n${YELLOW}Testing renewal process (dry-run)...${NC}"
if certbot renew --dry-run --quiet; then
    echo -e "${GREEN}✓ Auto-renewal test passed${NC}"
else
    echo -e "${YELLOW}⚠ Auto-renewal test had issues, but certificate is installed${NC}"
fi

# Show certificate info
echo -e "\n${YELLOW}Certificate Information:${NC}"
certbot certificates -d $DOMAIN

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e ""
echo -e "Next steps:"
echo -e "1. Deploy your backend with Docker Compose"
echo -e "2. Test your API: curl https://$DOMAIN/health"
echo -e ""
echo -e "Certificate will auto-renew before expiration."
echo -e "Check renewal timer: systemctl status certbot.timer"
echo -e ""
