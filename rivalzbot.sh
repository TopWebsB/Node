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

# Update package list
sudo apt update

#Create Screen Session for Rivalz
screen -S rivalz

# Check if the directory exists
if [ -d "rivalz-docker" ]; then
  echo "Directory rivalz-docker already exists."
else
  # Create the directory
  mkdir rivalz-docker
  echo "Directory rivalz-docker created."
fi

# Navigate into the directory
cd rivalz-docker

# Fetch the latest version of rivalz-node-cli
version=$(curl -s https://be.rivalz.ai/api-v1/system/rnode-cli-version | jq -r '.data')

# Set latest version if version retrieval fails
if [ -z "$version" ]; then
    version="latest"
    echo "Could not fetch the version. Defaulting to latest."
fi

# Create or replace the Dockerfile with the specified content
cat <<EOL > Dockerfile
FROM ubuntu:latest
# Disable interactive configuration
ENV DEBIAN_FRONTEND=noninteractive

# Update and upgrade the system
RUN apt-get update && apt-get install -y curl jq nano

# Install Node.js from NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \\
    apt-get install -y nodejs

RUN npm install -g npm

# Install the rivalz-node-cli package globally using npm
RUN npm install -g rivalz-node-cli@$version

EOL

# Add the common CMD instruction for all cases
cat <<EOL >> Dockerfile
# Run the rivalz command and then open a shell
CMD ["bash", "-c", "cd /usr/lib/node_modules/rivalz-node-cli && npm install && rivalz run; exec /bin/bash"]
EOL

# Detect existing rivalz-docker instances and find the highest instance number
existing_instances=$(docker ps -a --filter "name=rivalz-docker-" --format "{{.Names}}" | grep -Eo 'rivalz-docker-[0-9]+' | grep -Eo '[0-9]+' | sort -n | tail -1)

# Set the instance number
if [ -z "$existing_instances" ]; then
  instance_number=1
else
  instance_number=$((existing_instances + 1))
fi

# Set the container name
container_name="rivalz-docker-$instance_number"

# Build the Docker image with the specified name
docker build -t $container_name .

# Display the completion message
echo -e "\e[32mSetup is complete. To run the Docker container, use the following command:\e[0m"
echo "docker run -it --name $container_name $container_name"

# Thank you message
echo "==================================="
echo -e "${YELLOW}           TopWebs       ${NC}"
echo "==================================="
echo -e "${GREEN}    Thanks for using this script!${NC}"
echo "==================================="
echo -e "${YELLOW}Telegram: https://t.me/+3eooZdz9J1kwYTBl ${NC}"
echo -e "${YELLOW}YouTube: https://www.youtube.com/@TopWebsIT ${NC}"
echo "======================================================================"
