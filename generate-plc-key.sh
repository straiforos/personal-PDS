#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}Error: $1 is not installed${NC}"
        echo "Please install it using one of the following commands:"
        echo -e "${YELLOW}Ubuntu/Debian:${NC} sudo apt-get install $2"
        echo -e "${YELLOW}CentOS/RHEL:${NC} sudo yum install $2"
        echo -e "${YELLOW}Fedora:${NC} sudo dnf install $2"
        echo -e "${YELLOW}macOS:${NC} brew install $2"
        return 1
    fi
    return 0
}

# Check for required commands
echo "Checking required dependencies..."
check_command "openssl" "openssl" || exit 1
check_command "xxd" "vim-common" || exit 1
check_command "base64" "coreutils" || exit 1

echo -e "${GREEN}All dependencies are installed.${NC}"

# Create a temporary directory with secure permissions
TEMP_DIR=$(mktemp -d)
chmod 700 "$TEMP_DIR"

# Cleanup function
cleanup() {
    rm -rf "$TEMP_DIR"
}

# Set trap for cleanup
trap cleanup EXIT

echo "Generating PLC rotation key..."

# Generate key with error handling
if ! KEY=$(openssl ecparam -name secp256k1 -genkey -noout 2>"$TEMP_DIR/error.log"); then
    echo -e "${RED}Error generating key:${NC}"
    cat "$TEMP_DIR/error.log"
    exit 1
fi

# Process the key with error handling
if ! PROCESSED_KEY=$(echo "$KEY" | \
    openssl ec -text -noout 2>"$TEMP_DIR/error.log" | \
    grep priv -A 3 | \
    tail -n +2 | \
    tr -d '\n[:space:]:'); then
    echo -e "${RED}Error processing key:${NC}"
    cat "$TEMP_DIR/error.log"
    exit 1
fi

if [ -z "$PROCESSED_KEY" ]; then
    echo -e "${RED}Error: Generated key is empty${NC}"
    exit 1
fi

echo -e "${GREEN}Successfully generated PLC rotation key!${NC}"
echo
echo "Generated key (hex format): $PROCESSED_KEY"
echo
echo -e "${YELLOW}Please add this key to your .env file as:${NC}"
echo "PLC_ROTATION_KEY=$PROCESSED_KEY"

# Optionally update .env file directly
if [ -f .env ]; then
    echo
    read -p "Would you like to update the .env file automatically? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Check if PLC_ROTATION_KEY already exists
        if grep -q "^PLC_ROTATION_KEY=" .env; then
            # Replace existing key
            sed -i.bak "s|^PLC_ROTATION_KEY=.*|PLC_ROTATION_KEY=$PROCESSED_KEY|" .env
        else
            # Add new key
            echo "PLC_ROTATION_KEY=$PROCESSED_KEY" >> .env
        fi
        echo -e "${GREEN}Updated .env file successfully!${NC}"
    fi
fi 