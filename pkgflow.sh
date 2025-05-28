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

# Default settings
SKIP_VERIFICATION=true  # Fast mode enabled by default
TARGET="/"

# Function to show help
show_help() {
    echo -e "${BLUE}PKGFlow - macOS Package Installer${NC}"
    echo
    echo "Usage:"
    echo "  pkgflow [options] [file.pkg|file.dmg|folder]"
    echo
    echo "Options:"
    echo "  --install              Install pkgflow globally"
    echo "  --uninstall            Remove pkgflow from system"
    echo "  --verify, -v           Enable package verification (disabled by default)"
    echo "  --target <path>        Set custom install target (default: /)"
    echo "  --help, -h             Show this help message"
    echo
    echo "Examples:"
    echo "  pkgflow                           # Interactive mode for all packages in current directory"
    echo "  pkgflow MyApp.pkg                 # Install specific package"
    echo "  pkgflow MyApp.dmg                 # Install package from DMG"
    echo "  pkgflow /path/to/folder           # Interactive mode for all packages in folder"
    echo "  pkgflow --verify MyApp.dmg        # Install from DMG with verification"
    echo "  pkgflow --target /tmp MyApp.pkg   # Install to custom location"
    echo
    exit 0
}

# Parse command line arguments
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        --install)
            INSTALL_MODE=true
            shift
            ;;
        --uninstall)
            UNINSTALL_MODE=true
            shift
            ;;
        --verify|-v)
            SKIP_VERIFICATION=false
            shift
            ;;
        --target)
            TARGET="$2"
            shift 2
            ;;
        --help|-h)
            show_help
            ;;
        -*)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

# Check if script is being run with install flag
if [ "$INSTALL_MODE" = true ]; then
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
    
    # Install Quick Action
    echo -e "\n${BLUE}Installing Quick Action...${NC}"
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    WORKFLOW_PATH="$SCRIPT_DIR/PKGFlow.workflow"
    SERVICES_DIR="$HOME/Library/Services"
    
    if [ -d "$WORKFLOW_PATH" ]; then
        mkdir -p "$SERVICES_DIR"
        cp -R "$WORKFLOW_PATH" "$SERVICES_DIR/"
        echo -e "${GREEN}✓ Quick Action installed${NC}"
        echo -e "${BLUE}You can now right-click .pkg or .dmg files and select 'Install with PKGFlow'${NC}"
        echo -e "${YELLOW}Note: You may need to enable the service in System Preferences > Extensions > Finder${NC}"
    else
        echo -e "${YELLOW}Quick Action workflow not found in script directory${NC}"
    fi
    
    exit 0
fi

# Check if script is being run with uninstall flag
if [ "$UNINSTALL_MODE" = true ]; then
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
    
    # Remove Quick Action
    SERVICES_DIR="$HOME/Library/Services"
    WORKFLOW_PATH="$SERVICES_DIR/PKGFlow.workflow"
    
    if [ -d "$WORKFLOW_PATH" ]; then
        rm -rf "$WORKFLOW_PATH"
        echo -e "${GREEN}✓ Quick Action removed${NC}"
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

# Handle single file or folder installation
if [ ${#POSITIONAL_ARGS[@]} -gt 0 ]; then
    TARGET_PATH="${POSITIONAL_ARGS[0]}"
    
    # Check if it's a directory
    if [ -d "$TARGET_PATH" ]; then
        # Process folder - switch to interactive mode for that folder
        cd "$TARGET_PATH" || exit 1
        # Continue to interactive mode below
    elif [ -f "$TARGET_PATH" ]; then
        # Single file mode
        TARGET_FILE="$TARGET_PATH"
        
        # Check file extension
        if [[ "$TARGET_FILE" != *.pkg && "$TARGET_FILE" != *.dmg ]]; then
            echo -e "${RED}Error: File must be a .pkg or .dmg file${NC}"
            exit 1
        fi
        
        echo -e "${BLUE}Installing package: $(basename "$TARGET_FILE")${NC}"
        echo "Target: $TARGET"
        
        if [ "$SKIP_VERIFICATION" = false ]; then
            echo -ne "Verifying package... "
            if pkgutil --check-signature "$TARGET_FILE" &>/dev/null; then
                echo -e "${GREEN}✓ Valid${NC}"
            else
                echo -e "${RED}✗ Invalid or unsigned${NC}"
                read -p "Continue anyway? (y/N): " confirm
                if [[ ! $confirm =~ ^[Yy]$ ]]; then
                    exit 1
                fi
            fi
        fi
        
        # Handle DMG files
        if [[ "$TARGET_FILE" == *.dmg ]]; then
            TEMP_DIR=$(mktemp -d)
            trap "rm -rf \"$TEMP_DIR\"" EXIT
            
            mount_point=$(mktemp -d)
            echo -ne "Mounting DMG... "
            
            if hdiutil attach "$TARGET_FILE" -mountpoint "$mount_point" -nobrowse -noautoopen &>/dev/null; then
                echo -e "${GREEN}✓${NC}"
                
                # Find PKG files in the mounted DMG
                found_pkgs=()
                while IFS= read -r -d '' pkg; do
                    found_pkgs+=("$pkg")
                done < <(find "$mount_point" -name "*.pkg" -print0 2>/dev/null)
                
                if [ ${#found_pkgs[@]} -eq 0 ]; then
                    echo -e "${RED}No .pkg files found in DMG${NC}"
                    hdiutil detach "$mount_point" &>/dev/null
                    rmdir "$mount_point"
                    exit 1
                elif [ ${#found_pkgs[@]} -eq 1 ]; then
                    # Single package found, install it
                    pkg="${found_pkgs[0]}"
                    echo -e "${GREEN}Installing: $(basename "$pkg")${NC}"
                    if sudo installer -pkg "$pkg" -target "$TARGET"; then
                        echo -e "${GREEN}✓ Successfully installed $(basename "$pkg")${NC}"
                    else
                        echo -e "${RED}✗ Failed to install $(basename "$pkg")${NC}"
                        hdiutil detach "$mount_point" &>/dev/null
                        rmdir "$mount_point"
                        exit 1
                    fi
                else
                    # Multiple packages found, let user choose
                    echo -e "${YELLOW}Multiple packages found in DMG:${NC}"
                    for i in "${!found_pkgs[@]}"; do
                        echo "$((i+1)). $(basename "${found_pkgs[$i]}")"
                    done
                    read -p "Select package to install (1-${#found_pkgs[@]}): " choice
                    
                    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#found_pkgs[@]} ]; then
                        pkg="${found_pkgs[$((choice-1))]}"
                        echo -e "${GREEN}Installing: $(basename "$pkg")${NC}"
                        if sudo installer -pkg "$pkg" -target "$TARGET"; then
                            echo -e "${GREEN}✓ Successfully installed $(basename "$pkg")${NC}"
                        else
                            echo -e "${RED}✗ Failed to install $(basename "$pkg")${NC}"
                        fi
                    else
                        echo -e "${RED}Invalid selection${NC}"
                    fi
                fi
                
                hdiutil detach "$mount_point" &>/dev/null
                rmdir "$mount_point"
            else
                echo -e "${RED}✗ Failed to mount DMG${NC}"
                exit 1
            fi
        else
            # Direct PKG installation
            echo -e "${GREEN}Installing package...${NC}"
            if sudo installer -pkg "$TARGET_FILE" -target "$TARGET"; then
                echo -e "${GREEN}✓ Successfully installed $(basename "$TARGET_FILE")${NC}"
            else
                echo -e "${RED}✗ Failed to install $(basename "$TARGET_FILE")${NC}"
                exit 1
            fi
        fi
        
        exit 0
    else
        echo -e "${RED}Error: Path not found: $TARGET_PATH${NC}"
        exit 1
    fi
fi

# Interactive mode - process all packages in directory
# Clear screen
clear

echo -e "${BLUE}Package Installer Script${NC}"
echo "========================="
echo "Target: $TARGET"
if [ "$SKIP_VERIFICATION" = true ]; then
    echo -e "${YELLOW}Fast mode: Package verification disabled${NC}"
else
    echo -e "${GREEN}Package verification enabled${NC}"
fi
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

# Verify all packages (only if verification is enabled)
if [ "$SKIP_VERIFICATION" = false ]; then
    echo -e "${YELLOW}Verifying packages...${NC}"
    echo
    for i in "${!final_pkgs[@]}"; do
        verify_package "${final_pkgs[$i]}" $i
    done
    echo
fi

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
                        if sudo installer -pkg "${final_pkgs[$i]}" -target "$TARGET"; then
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