#!/bin/bash

# Define color codes
INFO='\033[0;36m'  # Cyan
BANNER='\033[0;35m' # Magenta
YELLOW='\033[0;33m' # Yellow
RED='\033[0;31m'    # Red
GREEN='\033[0;32m'  # Green
BLUE='\033[0;34m'   # Blue
NC='\033[0m'        # No Color

# Display social details
clear
echo "========================================"
echo -e "${YELLOW} Script is made by TopWebs ${NC}"
echo "-------------------------------------"
echo "======================================================="
echo "==================================="
echo -e "${YELLOW}           TopWebs       ${NC}"
echo "==================================="
echo -e "${GREEN}    Thanks for using this script!${NC}"
echo "==================================="
echo -e "${YELLOW}Telegram: https://t.me/+3eooZdz9J1kwYTBl ${NC}"
echo -e "${YELLOW}YouTube: https://www.youtube.com/@TopWebsIT ${NC}"
echo "======================================================="

# Update system packages
echo -e "${YELLOW}Updating and upgrading system packages...${NC}"
sudo apt update -y && sudo apt upgrade -y

# Install necessary dependencies
for pkg in screen docker docker-compose; do
    if ! command -v $pkg &> /dev/null; then
        echo -e "${YELLOW}Installing $pkg...${NC}"
        sudo apt install -y $pkg
    else
        echo -e "${GREEN}$pkg is already installed. Skipping installation.${NC}"
    fi
done

# Ensure user is in Docker group
if ! groups $USER | grep -q '\bdocker\b'; then
    echo "Adding user to Docker group..."
    sudo groupadd docker
    sudo usermod -aG docker $USER
    echo -e "${YELLOW}Please restart your session for the changes to take effect.${NC}"
fi

# Remove existing Titan Edge containers
existing_containers=$(docker ps -a --filter "ancestor=topwebs/titan-edge" --format "{{.ID}}")
if [ -n "$existing_containers" ]; then
    echo -e "${YELLOW}\nStopping and removing existing containers using the image topwebs/titan-edge...${NC}"
    docker stop $existing_containers
    docker rm $existing_containers
else
    echo -e "${RED}\nNo existing containers found for the image topwebs/titan-edge.${NC}"
fi

# Get user input
read -p "$(echo -e "${YELLOW}Enter your identity code: ${NC}")" id
read -p "$(echo -e "${YELLOW}Please enter the number of nodes you want to create (max 5 per IP): ${NC}")" container_count
read -p "$(echo -e "${YELLOW}Please enter the hard disk size limit for each node (in GB): ${NC}")" disk_size_gb

# Validate inputs
if [[ ! "$container_count" =~ ^[1-5]$ ]]; then
    echo -e "${RED}Invalid number of nodes. Please enter a number between 1 and 5.${NC}"
    exit 1
fi

if [[ ! "$disk_size_gb" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid disk size. Please enter a numeric value.${NC}"
    exit 1
fi

# Default storage directory
volume_dir="/mnt/docker_volumes"
mkdir -p $volume_dir

echo -e "${YELLOW}Pulling the latest Titan Edge image...${NC}"
docker pull topwebs/titan-edge

# Loop to create multiple containers
for i in $(seq 1 $container_count); do
    disk_size_mb=$((disk_size_gb * 1024))
    volume_path="$volume_dir/volume_$i.img"
    mount_point="/mnt/my_volume_$i"
    
    echo -e "${YELLOW}Creating storage volume for node $i...${NC}"
    sudo dd if=/dev/zero of=$volume_path bs=1M count=$disk_size_mb
    sudo mkfs.ext4 $volume_path
    mkdir -p $mount_point
    sudo mount -o loop $volume_path $mount_point
    echo "$volume_path $mount_point ext4 loop,defaults 0 0" | sudo tee -a /etc/fstab
    
    container_id=$(docker run -d --restart always -v $mount_point:/root/.titanedge/storage --name "titan$i" topwebs/titan-edge)
    echo -e "${YELLOW}Titan node $i has started with container ID $container_id${NC}"
    sleep 30
    docker exec -it $container_id bash -c "titan-edge bind --hash=$id https://api-test1.container1.titannet.io/api/v2/device/binding"
done

# Completion message
echo -e "${GREEN}All nodes have been successfully created!${NC}"
echo -e "${YELLOW}To check the container status, use:${NC}"
echo -e "${GREEN}docker ps -a${NC}"

echo "==================================="
echo -e "${YELLOW}           TopWebs       ${NC}"
echo "==================================="
echo -e "${GREEN}    Thanks for using this script!${NC}"
echo "==================================="
echo -e "${YELLOW}Telegram: https://t.me/+3eooZdz9J1kwYTBl ${NC}"
echo -e "${YELLOW}YouTube: https://www.youtube.com/@TopWebsIT ${NC}"
echo "======================================================================"
