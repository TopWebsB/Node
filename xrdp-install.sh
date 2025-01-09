#!/bin/bash

# Define color variables
GREEN="\033[0;32m"     # Green
YELLOW="\033[1;33m"    # Bright Yellow
NC="\033[0m"           # No Color

# Display social details and channel information
echo "==================================="
echo -e "${YELLOW}		TopWebs		${NC}"
echo "==================================="
echo -e "${YELLOW}Telegram: https://t.me/+3eooZdz9J1kwYTBl ${NC}"
echo -e "${YELLOW}YouTube: https://www.youtube.com/@TopWebsIT ${NC}"
echo "==================================="

# update
sudo apt update && sudo apt upgrade -y

# root
if [ "$(id -u)" != "0" ]; then
    echo "${GREEN}This script must be run as root or using sudo.${NC}"
    exit 1
fi

# port
echo "${YELLOW}Opening the required ports...${NC}"
sudo ufw allow 22 comment 'Allow SSH'
sudo ufw allow 3389 comment 'Allow RDP'
sudo ufw reload
echo "${GREEN}Port 22 remains open for SSH. Port 3389 is opened for RDP.${NC}"

# xfce
echo "${YELLOW}Installing XFCE...${NC}"
sudo apt update
sudo apt install xfce4 xfce4-goodies -y
if [ $? -eq 0 ]; then
    echo "${GREEN}XFCE installed successfully.${NC}"
else
    echo "${YELLOW}Failed to install XFCE. Check internet connection or repos.${NC}"
    exit 1
fi

# ldm
echo "${YELLOW}Installing LightDM...${NC}"
sudo apt install lightdm -y
if [ $? -eq 0 ]; then
    echo "${GREEN}LightDM was successfully installed.${NC}"
else
    echo "${YELLOW}Failed to install LightDM. Check your internet connection or repo.${NC}"
    exit 1
fi

echo "${YELLOW}Setting LightDM as default display manager...${NC}"
sudo systemctl enable lightdm
sudo systemctl start lightdm

# xrdp
echo "${YELLOW}Installing XRDP for Remote Desktop access...${NC}"
sudo apt install xrdp -y
if [ $? -eq 0 ]; then
    echo "${GREEN}XRDP installed successfully.${NC}"
else
    echo "${YELLOW}Failed to install XRDP. Check your internet connection or repo.${NC}"
    exit 1
fi

echo "${YELLOW}Configuring XRDP to use XFCE...${NC}"
echo xfce4-session >~/.xsession
sudo systemctl enable xrdp
sudo systemctl restart xrdp
sudo adduser xrdp ssl-cert
echo "${GREEN}Status XRDP:${NC}"
sudo systemctl status xrdp --no-pager

# firewall
echo "${YELLOW}Displays firewall status...${NC}"
sudo ufw status verbose

echo "${YELLOW}Setup is complete! You can now access the server via Remote Desktop Connection using this server IP.${NC}"

# Thank you message
echo "==================================="
echo -e "${YELLOW}           TopWebs       ${NC}"
echo "==================================="
echo -e "${GREEN}    Thanks for using this script!${NC}"
echo "==================================="
echo -e "${YELLOW}Telegram: https://t.me/+3eooZdz9J1kwYTBl ${NC}"
echo -e "${YELLOW}YouTube: https://www.youtube.com/@TopWebsIT ${NC}"
echo "======================================================================"
