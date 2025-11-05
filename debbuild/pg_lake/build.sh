#!/bin/bash
# pg_lake DEB package build script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building pg_lake DEB packages...${NC}"

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

# Check if required tools are installed
for tool in cmake ninja-build git pkg-config debuild; do
    if ! command -v $tool &> /dev/null; then
        echo -e "${RED}Error: $tool is not installed${NC}"
        echo "Please install with: apt-get install build-essential cmake ninja-build git pkg-config devscripts"
        exit 1
    fi
done

# Download source if not exists
if [ ! -f "pg_lake-3.0.0.tar.gz" ]; then
    echo -e "${YELLOW}Downloading pg_lake source...${NC}"
    wget https://github.com/Snowflake-Labs/pg_lake/archive/refs/tags/v3.0.0.tar.gz -O pg_lake-3.0.0.tar.gz
fi

# Extract source
echo -e "${YELLOW}Extracting source...${NC}"
tar -xzf pg_lake-3.0.0.tar.gz
cd pg_lake-3.0.0

# Copy debian directory
cp -r ../debian .

# Build packages
echo -e "${YELLOW}Building DEB packages...${NC}"
debuild -us -uc -b

echo -e "${GREEN}Build complete! Packages are in the parent directory.${NC}"
echo "To install:"
echo "  sudo dpkg -i ../postgresql-*-pg-lake_*.deb"