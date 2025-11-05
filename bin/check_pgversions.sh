#!/bin/bash
#==============================================================#
# File      :   check_pgversions.sh
# Desc      :   Check pgversions files format
# Ctime     :   2025-11-05
# Path      :   debbuild/check_pgversions.sh
# Author    :   Ruohang Feng (rh@vonng.com)
# License   :   Apache-2.0
#==============================================================#

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Checking pgversions files in debbuild..."
echo ""

error_count=0
total_count=0

# Find all pgversions files
while IFS= read -r file; do
    ((total_count++))

    # Check if file ends with newline
    if [ -s "$file" ]; then
        # Get the last byte of the file
        last_char=$(tail -c 1 "$file")

        if [ -z "$last_char" ]; then
            echo -e "${GREEN}✓${NC} $file"
        else
            echo -e "${RED}✗${NC} $file - missing newline at end of file"
            ((error_count++))
        fi
    else
        echo -e "${YELLOW}⚠${NC} $file - empty file"
    fi
done < <(find . -type f -path "*/debian/pgversions" | sort)

echo ""
echo "================================"
if [ $error_count -eq 0 ]; then
    echo -e "${GREEN}All $total_count pgversions files are valid!${NC}"
    exit 0
else
    echo -e "${RED}Found $error_count invalid file(s) out of $total_count total${NC}"
    exit 1
fi
