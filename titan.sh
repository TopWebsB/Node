#!/bin/bash

# Define color codes
INFO='\033[0;36m'  # Cyan
BANNER='\033[0;35m' # Magenta
YELLOW='\033[0;33m' # Yellow
RED='\033[0;31m'    # Red
GREEN='\033[0;32m'  # Green
NC='\033[0m'        # No Color

# Display script information
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
sudo apt update -y

# Install required dependencies
for pkg in screen curl tar; do
    if ! dpkg -s $pkg &> /dev/null; then
        echo -e "${YELLOW}Installing $pkg...${NC}"
        sudo apt install -y $pkg
    else
        echo -e "${YELLOW}$pkg is already installed, skipping installation.${NC}"
    fi
done

# Set variables
TITAN_VERSION="v0.1.20"
TITAN_URL="https://github.com/Titannet-dao/titan-node/releases/download/${TITAN_VERSION}/titan-edge_${TITAN_VERSION}_246b9dd_linux-amd64.tar.gz"

# Download Titan Edge
echo "Downloading Titan Edge..."
wget -O titan-edge.tar.gz "$TITAN_URL"

# Verify download success
if [ ! -f "titan-edge.tar.gz" ]; then
    echo "Download failed! Exiting..."
    exit 1
fi

# Extract files
echo "Extracting Titan Edge..."
tar -xzf titan-edge.tar.gz

# Locate the extracted binary
TITAN_BINARY=$(find . -type f -name "titan-edge" | head -n 1)

if [ -z "$TITAN_BINARY" ]; then
    echo "Extraction failed! Titan Edge binary not found."
    exit 1
fi

# Move to a global location
chmod +x "$TITAN_BINARY"
sudo mv "$TITAN_BINARY" /usr/local/bin/titan-edge

echo "Titan Edge installed successfully!"
titan-edge --version

echo -e "${YELLOW}Extracting Titan Edge...${NC}"
tar -xzf titan-edge.tar.gz
chmod +x titan-edge

# Move binary to /usr/local/bin for global access
sudo mv titan-edge /usr/local/bin/

# Ask for user inputs
read -p "$(echo -e "${YELLOW}Enter your identity code: ${NC}")" id
read -p "$(echo -e "${YELLOW}Please enter the number of nodes you want to create (max 5 per IP): ${NC}")" container_count
read -p "$(echo -e "${YELLOW}Please enter the hard disk size limit for each node (in GB): ${NC}")" disk_size_gb

# Create and configure storage for each node
volume_dir="/mnt/titan_volumes"
mkdir -p $volume_dir

for i in $(seq 1 $container_count); do
    disk_size_mb=$((disk_size_gb * 1024))
    volume_path="$volume_dir/volume_$i.img"
    mount_point="/mnt/titan_storage_$i"

    echo -e "${YELLOW}Creating storage volume for node $i...${NC}"
    sudo dd if=/dev/zero of=$volume_path bs=1M count=$disk_size_mb status=progress
    sudo mkfs.ext4 $volume_path
    mkdir -p $mount_point
    sudo mount -o loop $volume_path $mount_point
    echo "$volume_path $mount_point ext4 loop,defaults 0 0" | sudo tee -a /etc/fstab

    # Start Titan Edge node in a new screen session
    screen -dmS titan_node_$i bash -c "titan-edge --storage-dir=$mount_point &"
    echo -e "${GREEN}Titan node $i started in screen session 'titan_node_$i'${NC}"
    sleep 5

    # Bind the node
    titan-edge bind --hash=$id https://api-test1.container1.titannet.io/api/v2/device/binding
done

echo -e "${YELLOW}All nodes have been created successfully.${NC}"
echo -e "${GREEN}To check node status, run: screen -ls${NC}"

# Display closing message
echo "==================================="
echo -e "${YELLOW}           TopWebs       ${NC}"
echo "==================================="
echo -e "${GREEN}    Thanks for using this script!${NC}"
echo "==================================="
echo -e "${YELLOW}Telegram: https://t.me/+3eooZdz9J1kwYTBl ${NC}"
echo -e "${YELLOW}YouTube: https://www.youtube.com/@TopWebsIT ${NC}"
echo "======================================================================"
