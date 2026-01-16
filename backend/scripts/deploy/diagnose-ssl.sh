#!/bin/bash

################################################################################
# SSL Setup Diagnostic Script
# Helps identify why SSL certificate setup is failing
################################################################################

set +e  # Don't exit on errors

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOMAIN="api.muscleup.fitness"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  SSL Setup Diagnostics${NC}"
echo -e "${BLUE}  Domain: $DOMAIN${NC}"
echo -e "${BLUE}========================================${NC}"

# 1. DNS Check
echo -e "\n${YELLOW}[1/8] DNS Resolution:${NC}"
RESOLVED_IP=$(dig +short $DOMAIN | tail -n1)
if [ -n "$RESOLVED_IP" ]; then
    echo -e "${GREEN}✓ $DOMAIN resolves to: $RESOLVED_IP${NC}"
else
    echo -e "${RED}✗ DNS resolution failed${NC}"
fi

# Get server's public IP
SERVER_IP=$(curl -s ifconfig.me)
echo -e "Server's public IP: $SERVER_IP"

if [ "$RESOLVED_IP" = "$SERVER_IP" ]; then
    echo -e "${GREEN}✓ DNS points to this server${NC}"
else
    echo -e "${RED}⚠ DNS IP ($RESOLVED_IP) doesn't match server IP ($SERVER_IP)${NC}"
fi

# 2. Firewall Check
echo -e "\n${YELLOW}[2/8] Firewall Status:${NC}"
if command -v ufw &> /dev/null; then
    UFW_STATUS=$(ufw status | grep -i status | awk '{print $2}')
    echo "UFW Status: $UFW_STATUS"
    if [ "$UFW_STATUS" = "active" ]; then
        ufw status | grep -E "80|443"
    fi
else
    echo "UFW not installed"
fi

# 3. Port 80 Check
echo -e "\n${YELLOW}[3/8] Port 80 Availability:${NC}"
PORT_80=$(ss -tulpn | grep ':80 ')
if [ -n "$PORT_80" ]; then
    echo -e "${YELLOW}Port 80 is in use:${NC}"
    echo "$PORT_80"
else
    echo -e "${GREEN}✓ Port 80 is available${NC}"
fi

# 4. Port 443 Check
echo -e "\n${YELLOW}[4/8] Port 443 Availability:${NC}"
PORT_443=$(ss -tulpn | grep ':443 ')
if [ -n "$PORT_443" ]; then
    echo -e "${YELLOW}Port 443 is in use:${NC}"
    echo "$PORT_443"
else
    echo -e "${GREEN}✓ Port 443 is available${NC}"
fi

# 5. Docker Containers
echo -e "\n${YELLOW}[5/8] Docker Containers:${NC}"
if command -v docker &> /dev/null; then
    DOCKER_CONTAINERS=$(docker ps --format "table {{.Names}}\t{{.Ports}}" 2>/dev/null)
    if [ -n "$DOCKER_CONTAINERS" ]; then
        echo "$DOCKER_CONTAINERS"
    else
        echo "No running containers"
    fi
else
    echo "Docker not installed"
fi

# 6. Nginx Status
echo -e "\n${YELLOW}[6/8] Nginx Status:${NC}"
if systemctl is-active --quiet nginx; then
    echo -e "${GREEN}✓ Nginx is running${NC}"
    echo "Active sites:"
    ls -la /etc/nginx/sites-enabled/ 2>/dev/null || echo "No sites enabled"
else
    echo "Nginx is stopped"
fi

# 7. External Access Test
echo -e "\n${YELLOW}[7/8] External HTTP Access Test:${NC}"
echo "Testing http://$DOMAIN"
HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://$DOMAIN 2>/dev/null || echo "000")
echo "HTTP Response Code: $HTTP_RESPONSE"

if [ "$HTTP_RESPONSE" = "503" ]; then
    echo -e "${RED}✗ Getting 503 - Service Unavailable${NC}"
    echo "This means Nginx is running but backend is not responding"
elif [ "$HTTP_RESPONSE" = "000" ]; then
    echo -e "${RED}✗ Cannot connect to server${NC}"
elif [ "$HTTP_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✓ Server responding with 200 OK${NC}"
else
    echo -e "${YELLOW}Response code: $HTTP_RESPONSE${NC}"
fi

# 8. Test direct IP access
echo -e "\n${YELLOW}[8/8] Direct IP Access Test:${NC}"
echo "Testing http://$SERVER_IP"
IP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://$SERVER_IP 2>/dev/null || echo "000")
echo "HTTP Response Code: $IP_RESPONSE"

# Summary and Recommendations
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}  Diagnostics Summary${NC}"
echo -e "${BLUE}========================================${NC}"

ISSUES_FOUND=0

if [ "$RESOLVED_IP" != "$SERVER_IP" ]; then
    echo -e "${RED}❌ DNS Configuration Issue:${NC}"
    echo "   DNS points to: $RESOLVED_IP"
    echo "   Server IP is:  $SERVER_IP"
    echo "   → Update your DNS A record to point to $SERVER_IP"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

if [ "$HTTP_RESPONSE" = "503" ] || [ "$IP_RESPONSE" = "503" ]; then
    echo -e "${RED}❌ Backend Not Running:${NC}"
    echo "   Server returns 503 - backend application not responding"
    echo "   → This will cause SSL verification to fail"
    echo "   → Options:"
    echo "     1. Start your backend application first"
    echo "     2. Use certbot standalone mode (requires stopping Nginx)"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

if [ -n "$PORT_80" ] && [[ ! "$PORT_80" =~ "certbot" ]]; then
    echo -e "${YELLOW}⚠ Port 80 is occupied:${NC}"
    echo "   For standalone mode, port 80 must be free"
    echo "   → Stop Nginx: sudo systemctl stop nginx"
    echo "   → Or use nginx plugin: certbot --nginx"
fi

if [ "$UFW_STATUS" = "active" ]; then
    UFW_80=$(ufw status | grep "80/tcp")
    UFW_443=$(ufw status | grep "443/tcp")
    if [ -z "$UFW_80" ] || [ -z "$UFW_443" ]; then
        echo -e "${YELLOW}⚠ Firewall may be blocking ports:${NC}"
        echo "   → Allow ports: sudo ufw allow 80/tcp && sudo ufw allow 443/tcp"
    fi
fi

if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "\n${GREEN}✓ No critical issues found!${NC}"
    echo -e "You should be able to obtain SSL certificate."
    echo -e "\nRecommended next steps:"
    echo -e "1. If backend is running on port 8001:"
    echo -e "   sudo bash scripts/deploy/setup-ssl.sh"
    echo -e ""
    echo -e "2. If backend is NOT running:"
    echo -e "   sudo systemctl stop nginx"
    echo -e "   sudo bash scripts/deploy/setup-ssl-simple.sh"
else
    echo -e "\n${YELLOW}Found $ISSUES_FOUND issue(s) - please fix them before obtaining SSL${NC}"
fi

echo -e "\n${BLUE}========================================${NC}"
