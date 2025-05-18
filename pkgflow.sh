#!/bin/bash
#
# PKGFlow
# Author: madebycm, 2025
#

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if script is being run with install flag
if [ "$1" = "--install" ]; then
    echo -e "${BLUE}Installing PKGFlow...${NC}"
    
    # Create local bin directory if it doesn't exist
    LOCAL_BIN="$HOME/.local/bin"
    mkdir -p "$LOCAL_BIN"
    
    # Copy script to local bin (always overwrites to ensure latest version)
    SCRIPT_PATH="$LOCAL_BIN/pkgflow"
    cp -f "$0" "$SCRIPT_PATH"
    chmod +x "$SCRIPT_PATH"
    echo -e "${GREEN}✓ Installed latest version to $SCRIPT_PATH${NC}"
    
    # Add to PATH if not already present
    if [[ ! "$PATH" == *"$LOCAL_BIN"* ]]; then
        # Detect which shell config file to use
        if [ -f "$HOME/.zshrc" ]; then
            SHELL_CONFIG="$HOME/.zshrc"
        elif [ -f "$HOME/.bashrc" ]; then
            SHELL_CONFIG="$HOME/.bashrc"
        elif [ -f "$HOME/.bash_profile" ]; then
            SHELL_CONFIG="$HOME/.bash_profile"
        else
            SHELL_CONFIG="$HOME/.profile"
        fi
        
        echo "" >> "$SHELL_CONFIG"
        echo "# Add PKGFlow to PATH" >> "$SHELL_CONFIG"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$SHELL_CONFIG"
        
        echo -e "${GREEN}✓ Added $LOCAL_BIN to PATH in $SHELL_CONFIG${NC}"
        echo -e "${YELLOW}Path will be available after restarting your shell${NC}"
        
        # Source the config file for immediate use
        export PATH="$HOME/.local/bin:$PATH"
    else
        echo -e "${GREEN}✓ $LOCAL_BIN is already in PATH${NC}"
    fi
    
    echo -e "${GREEN}✓ Installation complete!${NC}"
    echo -e "${BLUE}You can now use 'pkgflow' from anywhere${NC}"
    
    # Test if pkgflow is accessible
    if command -v pkgflow &> /dev/null; then
        echo -e "${GREEN}✓ pkgflow command is ready to use${NC}"
    else
        echo -e "${YELLOW}Note: You may need to restart your terminal for PATH changes to take effect${NC}"
    fi
    
    exit 0
fi

# Check if script is being run with uninstall flag
if [ "$1" = "--uninstall" ]; then
    echo -e "${YELLOW}Uninstalling PKGFlow...${NC}"
    
    # Remove pkgflow from local bin
    LOCAL_BIN="$HOME/.local/bin"
    SCRIPT_PATH="$LOCAL_BIN/pkgflow"
    
    if [ -f "$SCRIPT_PATH" ]; then
        rm "$SCRIPT_PATH"
        echo -e "${GREEN}✓ Removed pkgflow from $LOCAL_BIN${NC}"
    else
        echo -e "${YELLOW}pkgflow not found in $LOCAL_BIN${NC}"
    fi
    
    # Note about PATH cleanup
    echo -e "${YELLOW}Note: PATH entries in your shell config were not modified${NC}"
    echo -e "${YELLOW}To clean up PATH, manually edit your shell config file${NC}"
    
    # Check if pkgflow is still accessible
    if ! command -v pkgflow &> /dev/null; then
        echo -e "${GREEN}✓ pkgflow command successfully removed${NC}"
    else
        echo -e "${YELLOW}Warning: pkgflow might still be installed elsewhere${NC}"
    fi
    
    echo -e "${GREEN}✓ Uninstallation complete!${NC}"
    exit 0
fi

# Clear screen
clear

echo -e "${BLUE}Package Installer Script${NC}"
echo "========================="
echo

# Create temporary directory for extracted packages
TEMP_DIR=$(mktemp -d)
trap "rm -rf \"$TEMP_DIR\"" EXIT

# Function to extract PKG from DMG
extract_pkg_from_dmg() {
    local dmg_file=$1
    local mount_point=$(mktemp -d)
    
    echo -ne "Mounting $dmg_file... "
    
    # Mount the DMG
    if hdiutil attach "$dmg_file" -mountpoint "$mount_point" -nobrowse -noautoopen &>/dev/null; then
        echo -e "${GREEN}✓${NC}"
        
        # Find PKG files in the mounted DMG
        local found_pkgs=()
        while IFS= read -r -d '' pkg; do
            found_pkgs+=("$pkg")
        done < <(find "$mount_point" -name "*.pkg" -print0 2>/dev/null)
        
        if [ ${#found_pkgs[@]} -gt 0 ]; then
            echo -e "${GREEN}Found ${#found_pkgs[@]} package(s) in DMG:${NC}"
            for pkg in "${found_pkgs[@]}"; do
                local pkg_name=$(basename "$pkg")
                echo "  - $pkg_name"
                # Copy PKG to temp directory with unique name to avoid conflicts
                cp "$pkg" "$TEMP_DIR/$(basename "$dmg_file" .dmg)_$pkg_name"
            done
        else
            echo -e "${YELLOW}No .pkg files found in DMG${NC}"
        fi
        
        # Unmount the DMG
        hdiutil detach "$mount_point" &>/dev/null
        rmdir "$mount_point"
    else
        echo -e "${RED}✗ Failed to mount${NC}"
    fi
    echo
}

# Find all .dmg files and extract PKGs
dmg_files=()
while IFS= read -r -d '' dmg; do
    dmg_files+=("$dmg")
done < <(find . -maxdepth 1 -name "*.dmg" -print0)

if [ ${#dmg_files[@]} -gt 0 ]; then
    echo -e "${YELLOW}Processing DMG files...${NC}"
    echo
    for dmg in "${dmg_files[@]}"; do
        extract_pkg_from_dmg "$dmg"
    done
fi

# Find all .pkg files (original and extracted)
pkg_files=()
while IFS= read -r -d '' pkg; do
    pkg_files+=("$pkg")
done < <(find . -maxdepth 1 -name "*.pkg" -print0)

extracted_pkgs=()
while IFS= read -r -d '' pkg; do
    extracted_pkgs+=("$pkg")
done < <(find "$TEMP_DIR" -name "*.pkg" -print0)

# Combine original and extracted PKGs
all_pkgs=()
if [ ${#pkg_files[@]} -gt 0 ]; then
    all_pkgs+=("${pkg_files[@]}")
fi
if [ ${#extracted_pkgs[@]} -gt 0 ]; then
    all_pkgs+=("${extracted_pkgs[@]}")
fi

# Check if any .pkg files exist
if [ ${#all_pkgs[@]} -eq 0 ]; then
    echo -e "${RED}No .pkg files found in the current directory or DMG files.${NC}"
    exit 1
fi

# Remove duplicates and create final list
final_pkgs=()
declare -a seen_names

for pkg in "${all_pkgs[@]}"; do
    basename_pkg=$(basename "$pkg")
    found=0
    for seen in "${seen_names[@]}"; do
        if [ "$seen" = "$basename_pkg" ]; then
            found=1
            break
        fi
    done
    if [ $found -eq 0 ]; then
        seen_names+=("$basename_pkg")
        final_pkgs+=("$pkg")
    fi
done

echo -e "${GREEN}Found ${#final_pkgs[@]} unique package(s):${NC}"
echo

# Arrays to store selections
declare -a selected_pkgs
declare -a pkg_status
declare -a pkg_sources

# Initialize all packages as selected (enabled by default)
for i in "${!final_pkgs[@]}"; do
    selected_pkgs[$i]=1
    pkg_status[$i]=""
    # Mark source of package
    if [[ "${final_pkgs[$i]}" == "$TEMP_DIR"* ]]; then
        pkg_sources[$i]=" ${BLUE}(from DMG)${NC}"
    else
        pkg_sources[$i]=""
    fi
done

# Function to display package list with selection status
display_packages() {
    echo -e "${YELLOW}Package Selection:${NC}"
    echo "=================="
    for i in "${!final_pkgs[@]}"; do
        if [ ${selected_pkgs[$i]} -eq 1 ]; then
            status="[X]"
            color=$GREEN
        else
            status="[ ]"
            color=$RED
        fi
        local display_name=$(basename "${final_pkgs[$i]}")
        echo -e "$((i+1)). $color$status${NC} $display_name${pkg_sources[$i]} ${pkg_status[$i]}"
    done
    echo
}

# Function to verify a package
verify_package() {
    local pkg=$1
    local index=$2
    local display_name=$(basename "$pkg")
    echo -ne "Verifying $display_name... "
    if pkgutil --check-signature "$pkg" &>/dev/null; then
        echo -e "${GREEN}✓ Valid${NC}"
        pkg_status[$index]="${GREEN}(Verified)${NC}"
        return 0
    else
        echo -e "${RED}✗ Invalid or unsigned${NC}"
        pkg_status[$index]="${RED}(Unverified)${NC}"
        return 1
    fi
}

# Function to get package info
get_package_info() {
    local pkg=$1
    local display_name=$(basename "$pkg")
    echo -e "\n${BLUE}Package Information: $display_name${NC}"
    echo "===================================="
    installer -pkginfo -pkg "$pkg" 2>/dev/null | head -10
    echo
}

# Verify all packages
echo -e "${YELLOW}Verifying packages...${NC}"
echo
for i in "${!final_pkgs[@]}"; do
    verify_package "${final_pkgs[$i]}" $i
done
echo

# Display package information
for i in "${!final_pkgs[@]}"; do
    get_package_info "${final_pkgs[$i]}"
done

# Interactive selection loop
while true; do
    display_packages
    
    echo -e "${YELLOW}Options:${NC}"
    echo "  Enter package number to toggle selection"
    echo "  'a' to select all"
    echo "  'n' to deselect all"
    echo "  'i' to install selected packages"
    echo "  'q' to quit"
    echo
    read -p "Choice: " choice
    
    case $choice in
        [1-9]|[1-9][0-9])
            index=$((choice-1))
            if [ $index -lt ${#final_pkgs[@]} ]; then
                if [ ${selected_pkgs[$index]} -eq 1 ]; then
                    selected_pkgs[$index]=0
                else
                    selected_pkgs[$index]=1
                fi
                clear
            else
                echo -e "${RED}Invalid package number${NC}"
                sleep 1
                clear
            fi
            ;;
        a|A)
            for i in "${!final_pkgs[@]}"; do
                selected_pkgs[$i]=1
            done
            clear
            ;;
        n|N)
            for i in "${!final_pkgs[@]}"; do
                selected_pkgs[$i]=0
            done
            clear
            ;;
        i|I)
            # Count selected packages
            count=0
            for i in "${!final_pkgs[@]}"; do
                if [ ${selected_pkgs[$i]} -eq 1 ]; then
                    ((count++))
                fi
            done
            
            if [ $count -eq 0 ]; then
                echo -e "${RED}No packages selected for installation${NC}"
                sleep 2
                clear
                continue
            fi
            
            echo -e "\n${YELLOW}Selected packages for installation:${NC}"
            for i in "${!final_pkgs[@]}"; do
                if [ ${selected_pkgs[$i]} -eq 1 ]; then
                    display_name=$(basename "${final_pkgs[$i]}")
                    echo "  - $display_name${pkg_sources[$i]}"
                fi
            done
            
            echo
            read -p "Proceed with installation? (y/N): " confirm
            
            if [[ $confirm =~ ^[Yy]$ ]]; then
                echo -e "\n${GREEN}Starting installation...${NC}\n"
                
                for i in "${!final_pkgs[@]}"; do
                    if [ ${selected_pkgs[$i]} -eq 1 ]; then
                        display_name=$(basename "${final_pkgs[$i]}")
                        echo -e "${BLUE}Installing: $display_name${NC}"
                        
                        # Use sudo for installation
                        if sudo installer -pkg "${final_pkgs[$i]}" -target /; then
                            echo -e "${GREEN}✓ Successfully installed $display_name${NC}\n"
                        else
                            echo -e "${RED}✗ Failed to install $display_name${NC}\n"
                        fi
                    fi
                done
                
                echo -e "${GREEN}Installation complete!${NC}"
                exit 0
            else
                clear
            fi
            ;;
        q|Q)
            echo -e "${YELLOW}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            sleep 1
            clear
            ;;
    esac
done