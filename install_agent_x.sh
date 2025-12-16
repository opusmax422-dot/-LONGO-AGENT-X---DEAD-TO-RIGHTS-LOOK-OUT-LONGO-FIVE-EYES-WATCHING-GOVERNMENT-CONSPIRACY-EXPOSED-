#!/bin/bash
###############################################################################
# AGENT X FORTRESS - INSTALLATION SCRIPT
# Automated installation and configuration for Ubuntu/WSL environments
###############################################################################

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Version
VERSION="1.0.0"

# Installation directory (current directory)
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

###############################################################################
# Helper Functions
###############################################################################

print_header() {
    echo -e "${CYAN}============================================================================${NC}"
    echo -e "${BOLD}${BLUE}  🔒 AGENT X FORTRESS - INSTALLATION SCRIPT v${VERSION}${NC}"
    echo -e "${CYAN}============================================================================${NC}"
    echo ""
}

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[i]${NC} $1"
}

###############################################################################
# System Detection
###############################################################################

detect_system() {
    print_info "Detecting system..."
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
        print_status "Detected: $PRETTY_NAME"
    else
        print_error "Cannot detect operating system"
        exit 1
    fi
    
    # Check if running in WSL
    if grep -qi microsoft /proc/version; then
        print_status "Running in WSL (Windows Subsystem for Linux)"
        IS_WSL=true
    else
        IS_WSL=false
    fi
}

###############################################################################
# Python Installation Check
###############################################################################

check_python() {
    print_info "Checking Python installation..."
    
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
        PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d'.' -f1)
        PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d'.' -f2)
        
        print_status "Found Python $PYTHON_VERSION"
        
        # Check if Python 3.8+
        if [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -ge 8 ]; then
            print_status "Python version is compatible (3.8+)"
            return 0
        else
            print_warning "Python version is older than 3.8"
            print_info "Attempting to install Python 3..."
            install_python
        fi
    else
        print_warning "Python3 not found"
        install_python
    fi
}

install_python() {
    print_info "Installing Python3..."
    
    if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        sudo apt-get update
        sudo apt-get install -y python3 python3-pip
        print_status "Python3 installed"
    elif [ "$OS" = "fedora" ] || [ "$OS" = "rhel" ] || [ "$OS" = "centos" ]; then
        sudo dnf install -y python3 python3-pip
        print_status "Python3 installed"
    else
        print_error "Unsupported OS for automatic Python installation"
        print_info "Please install Python 3.8+ manually"
        exit 1
    fi
}

###############################################################################
# Directory Structure Creation
###############################################################################

create_directories() {
    print_info "Creating directory structure..."
    
    local dirs=(
        "$INSTALL_DIR/bin"
        "$INSTALL_DIR/data/charts"
        "$INSTALL_DIR/data/evidence"
        "$INSTALL_DIR/data/social"
        "$INSTALL_DIR/data/templates"
        "$INSTALL_DIR/config"
        "$INSTALL_DIR/logs"
        "$INSTALL_DIR/output"
    )
    
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            print_status "Created: $dir"
        else
            print_info "Already exists: $dir"
        fi
    done
    
    print_status "Directory structure created"
}

###############################################################################
# TradingView Library Download
###############################################################################

download_tradingview_library() {
    print_info "Checking TradingView Lightweight Charts library..."
    
    local lib_file="$INSTALL_DIR/data/charts/lightweight-charts.standalone.production.js"
    
    # Check if library already exists and is not just a placeholder
    if [ -f "$lib_file" ]; then
        local file_size=$(stat -f%z "$lib_file" 2>/dev/null || stat -c%s "$lib_file" 2>/dev/null)
        if [ "$file_size" -gt 10000 ]; then
            print_status "TradingView library already exists (${file_size} bytes)"
            return 0
        fi
    fi
    
    print_info "Downloading TradingView Lightweight Charts library..."
    
    # Try to download the library
    local url="https://unpkg.com/lightweight-charts@4.1.3/dist/lightweight-charts.standalone.production.js"
    
    if command -v curl &> /dev/null; then
        if curl -L -o "$lib_file" "$url" 2>/dev/null; then
            print_status "Library downloaded successfully"
            return 0
        fi
    elif command -v wget &> /dev/null; then
        if wget -O "$lib_file" "$url" 2>/dev/null; then
            print_status "Library downloaded successfully"
            return 0
        fi
    fi
    
    # If download failed, try npm if available
    print_warning "Direct download failed, trying npm..."
    
    if command -v npm &> /dev/null; then
        print_info "Installing via npm..."
        local temp_dir=$(mktemp -d)
        cd "$temp_dir"
        npm install lightweight-charts@4.1.3 --no-save 2>/dev/null
        
        if [ -f "node_modules/lightweight-charts/dist/lightweight-charts.standalone.production.js" ]; then
            cp "node_modules/lightweight-charts/dist/lightweight-charts.standalone.production.js" "$lib_file"
            cd "$INSTALL_DIR"
            rm -rf "$temp_dir"
            print_status "Library installed via npm"
            return 0
        fi
        
        cd "$INSTALL_DIR"
        rm -rf "$temp_dir"
    fi
    
    print_warning "Could not download TradingView library automatically"
    print_info "You can manually download from: $url"
    print_info "And save to: $lib_file"
    print_info "The application will still work, but charts will need the library to function"
}

###############################################################################
# Set Permissions
###############################################################################

set_permissions() {
    print_info "Setting file permissions..."
    
    # Make Python scripts executable
    if [ -f "$INSTALL_DIR/bin/agent_x_launcher.py" ]; then
        chmod +x "$INSTALL_DIR/bin/agent_x_launcher.py"
        print_status "agent_x_launcher.py is executable"
    fi
    
    # Make shell scripts executable
    local scripts=(
        "$INSTALL_DIR/start-agent-x.sh"
        "$INSTALL_DIR/install_agent_x.sh"
        "$INSTALL_DIR/DEPLOY_TO_LOCAL_PC.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            chmod +x "$script"
            print_status "$(basename $script) is executable"
        fi
    done
    
    print_status "Permissions set"
}

###############################################################################
# Create Symbolic Links
###############################################################################

create_symlinks() {
    print_info "Creating symbolic links for easy access..."
    
    local bin_dir="$HOME/.local/bin"
    
    # Create user bin directory if it doesn't exist
    if [ ! -d "$bin_dir" ]; then
        mkdir -p "$bin_dir"
        print_status "Created: $bin_dir"
    fi
    
    # Create symlink to agent_x_launcher.py
    local launcher="$INSTALL_DIR/bin/agent_x_launcher.py"
    local link_name="$bin_dir/agent-x"
    
    if [ -f "$launcher" ]; then
        if [ -L "$link_name" ]; then
            rm "$link_name"
        fi
        
        ln -s "$launcher" "$link_name"
        print_status "Created symlink: agent-x -> $launcher"
        
        # Check if ~/.local/bin is in PATH
        if [[ ":$PATH:" != *":$bin_dir:"* ]]; then
            print_warning "~/.local/bin is not in your PATH"
            print_info "Add this line to your ~/.bashrc or ~/.zshrc:"
            echo -e "${YELLOW}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
        fi
    else
        print_warning "agent_x_launcher.py not found, skipping symlink creation"
    fi
}

###############################################################################
# Verify Installation
###############################################################################

verify_installation() {
    print_info "Verifying installation..."
    
    local all_good=true
    
    # Check Python
    if command -v python3 &> /dev/null; then
        print_status "Python3: OK"
    else
        print_error "Python3: NOT FOUND"
        all_good=false
    fi
    
    # Check main application
    if [ -f "$INSTALL_DIR/bin/agent_x_launcher.py" ]; then
        print_status "Main application: OK"
    else
        print_error "Main application: NOT FOUND"
        all_good=false
    fi
    
    # Check chart template
    if [ -f "$INSTALL_DIR/data/charts/chart_template.html" ]; then
        print_status "Chart template: OK"
    else
        print_error "Chart template: NOT FOUND"
        all_good=false
    fi
    
    # Check directories
    local required_dirs=(
        "$INSTALL_DIR/bin"
        "$INSTALL_DIR/data"
        "$INSTALL_DIR/output"
        "$INSTALL_DIR/logs"
    )
    
    local dir_ok=true
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            dir_ok=false
            break
        fi
    done
    
    if $dir_ok; then
        print_status "Directory structure: OK"
    else
        print_error "Directory structure: INCOMPLETE"
        all_good=false
    fi
    
    if $all_good; then
        print_status "Installation verification: PASSED"
        return 0
    else
        print_error "Installation verification: FAILED"
        return 1
    fi
}

###############################################################################
# Display Next Steps
###############################################################################

display_next_steps() {
    echo ""
    echo -e "${CYAN}============================================================================${NC}"
    echo -e "${BOLD}${GREEN}  ✅ INSTALLATION COMPLETE!${NC}"
    echo -e "${CYAN}============================================================================${NC}"
    echo ""
    echo -e "${BOLD}Next Steps:${NC}"
    echo ""
    echo -e "1. Run the application:"
    echo -e "   ${YELLOW}cd $INSTALL_DIR${NC}"
    echo -e "   ${YELLOW}./bin/agent_x_launcher.py${NC}"
    echo ""
    echo -e "   Or if symlink was created:"
    echo -e "   ${YELLOW}agent-x${NC}"
    echo ""
    echo -e "2. Open the chart interface in your browser:"
    echo -e "   ${YELLOW}$INSTALL_DIR/data/charts/chart_template.html${NC}"
    echo ""
    echo -e "3. Check the documentation:"
    echo -e "   ${YELLOW}$INSTALL_DIR/README.md${NC}"
    echo ""
    echo -e "${BOLD}Application Features:${NC}"
    echo -e "  • Form 7A Statement of Claim Generator"
    echo -e "  • Motion to Dismiss Generator"
    echo -e "  • Evidence Timeline Analysis"
    echo -e "  • Social Media Content Generator"
    echo -e "  • Chart System (Ready for Francesco's Algorithm)"
    echo ""
    echo -e "${BOLD}All 4 Critical Fixes Implemented:${NC}"
    echo -e "  ${GREEN}✅${NC} Offline Compatibility - Local chart library"
    echo -e "  ${GREEN}✅${NC} Correct Method Naming - generate_motion_to_dismiss()"
    echo -e "  ${GREEN}✅${NC} Robust Error Handling - safe_save_file()"
    echo -e "  ${GREEN}✅${NC} Path Validation - All file operations validated"
    echo ""
    echo -e "${CYAN}============================================================================${NC}"
    echo ""
}

###############################################################################
# Main Installation Flow
###############################################################################

main() {
    print_header
    
    # System detection
    detect_system
    echo ""
    
    # Check Python
    check_python
    echo ""
    
    # Create directories
    create_directories
    echo ""
    
    # Download TradingView library
    download_tradingview_library
    echo ""
    
    # Set permissions
    set_permissions
    echo ""
    
    # Create symlinks
    create_symlinks
    echo ""
    
    # Verify installation
    if verify_installation; then
        echo ""
        display_next_steps
        exit 0
    else
        echo ""
        print_error "Installation completed with errors"
        print_info "Please check the output above and resolve any issues"
        exit 1
    fi
}

# Run main installation
main "$@"
