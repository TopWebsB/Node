#!/bin/bash

# Define color codes
INFO='\033[0;36m'  # Cyan
BANNER='\033[0;35m' # Magenta
YELLOW='\033[0;33m' # Yellow
RED='\033[0;31m'    # Red
GREEN='\033[0;32m'  # Green
NC='\033[0m'        # No Color

# Display script banner
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
echo -e "${YELLOW}Installing required dependencies...${NC}"
sudo apt install -y screen curl wget tar apt-transport-https ca-certificates lsb-release gnupg2 software-properties-common libgomp1

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Installing Docker...${NC}"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update -y
    sudo apt install -y docker-ce docker-ce-cli containerd.io
else
    echo -e "${GREEN}Docker is already installed. Skipping installation.${NC}"
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}Installing Docker Compose...${NC}"
    VER=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
    sudo curl -L "https://github.com/docker/compose/releases/download/$VER/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
else
    echo -e "${GREEN}Docker Compose is already installed. Skipping installation.${NC}"
fi

# Ensure user is in the Docker group
if ! groups $USER | grep -q '\bdocker\b'; then
    echo -e "${YELLOW}Adding user to Docker group...${NC}"
    sudo groupadd docker
    sudo usermod -aG docker $USER
    echo -e "${YELLOW}Please log out and log back in for group changes to take effect.${NC}"
fi

# Download & install Titan Edge
echo -e "${INFO}Downloading Titan Edge...${NC}"
TITAN_VERSION="v0.1.20"
TITAN_URL="https://github.com/Titannet-dao/titan-node/releases/download/${TITAN_VERSION}/titan-edge_${TITAN_VERSION}_246b9dd_linux-amd64.tar.gz"
TITAN_ARCHIVE="titan-edge.tar.gz"
INSTALL_DIR="/usr/local/bin"

wget -O "$TITAN_ARCHIVE" "$TITAN_URL"

# Verify download
if [ ! -f "$TITAN_ARCHIVE" ]; then
    echo -e "${RED}Download failed! Exiting...${NC}"
    exit 1
fi

# Extract Titan Edge
echo -e "${INFO}Extracting Titan Edge...${NC}"
tar -xzf "$TITAN_ARCHIVE" || { echo -e "${RED}Extraction failed!${NC}"; exit 1; }

# Find the extracted binary
TITAN_BINARY=$(find . -type f -name "titan-edge" | head -n 1)

if [ -z "$TITAN_BINARY" ]; then
    echo -e "${RED}Titan Edge binary not found after extraction!${NC}"
    exit 1
fi

# Make binary executable
chmod +x "$TITAN_BINARY"
sudo mv "$TITAN_BINARY" "$INSTALL_DIR/titan-edge"

# Fix missing library issue
echo -e "${INFO}Fixing shared library paths...${NC}"
sudo ldconfig

# Verify installation
echo -e "${INFO}Verifying Titan Edge installation...${NC}"
if ! command -v titan-edge &> /dev/null; then
    echo -e "${RED}Titan Edge installation failed.${NC}"
    exit 1
fi

# Ask user for input
read -p "$(echo -e "${YELLOW}Enter your identity code: ${NC}")" id
read -p "$(echo -e "${YELLOW}Please enter the number of nodes you want to create (max 5 per IP): ${NC}")" container_count
read -p "$(echo -e "${YELLOW}Please enter the hard disk size limit for each node (in GB): ${NC}")" disk_size_gb

# Default storage directory
volume_dir="/mnt/docker_volumes"
mkdir -p $volume_dir

# Loop to create nodes
for i in $(seq 1 $container_count); do
    echo -e "${YELLOW}Creating storage volume for node $i...${NC}"
    
    disk_size_mb=$((disk_size_gb * 1024))
    volume_path="$volume_dir/volume_$i.img"
    
    # Create storage file
    sudo dd if=/dev/zero of=$volume_path bs=1M count=$disk_size_mb
    sudo mkfs.ext4 $volume_path
    
    mount_point="/mnt/my_volume_$i"
    mkdir -p $mount_point
    sudo mount -o loop $volume_path $mount_point
    
    echo -e "${YELLOW}$volume_path $mount_point ext4 loop,defaults 0 0${NC}" | sudo tee -a /etc/fstab
    
    # Run Titan Edge
    container_id=$(docker run -d --restart always -v $mount_point:/root/.titanedge/storage --name "titan$i" topwebs/titan-edge)
    
    echo -e "${GREEN}Titan node $i has started with container ID $container_id${NC}"
    
    sleep 30
    docker exec -it $container_id bash -c "titan-edge bind --hash=$id https://api-test1.container1.titannet.io/api/v2/device/binding"
done

# Start Titan Edge
echo -e "${GREEN}Titan Edge installed successfully! Starting...${NC}"
titan-edge --version || { echo -e "${RED}Titan Edge failed to start.${NC}"; exit 1; }

echo -e "${GREEN}All nodes created successfully!${NC}"
echo -e "${YELLOW}To check container status, run: docker ps -a${NC}"

# Display thank you message
echo "==================================="
echo -e "${YELLOW}           TopWebs       ${NC}"
echo "==================================="
echo -e "${GREEN}    Thanks for using this script!${NC}"
echo "==================================="
echo -e "${YELLOW}Telegram: https://t.me/+3eooZdz9J1kwYTBl ${NC}"
echo -e "${YELLOW}YouTube: https://www.youtube.com/@TopWebsIT ${NC}"
echo "======================================================================"
