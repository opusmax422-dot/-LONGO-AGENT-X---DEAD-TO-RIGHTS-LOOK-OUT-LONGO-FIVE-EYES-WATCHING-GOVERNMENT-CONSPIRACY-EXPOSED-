#!/bin/bash
################################################################################
# 🏰 AGENT X - ONE-COMMAND WEB INTERFACE LAUNCHER
# 
# This script does EVERYTHING needed to get the web interface running:
# ✅ Checks all dependencies (Python, pip, Ollama)
# ✅ Auto-installs missing Python packages
# ✅ Verifies Ollama is running
# ✅ Creates all necessary directories
# ✅ Fixes port conflicts (kills processes on port 8080)
# ✅ Starts the web server automatically
# ✅ Opens browser automatically
# ✅ Provides clear success/error messages
#
# USAGE: bash LAUNCH_WEB_INTERFACE.sh
################################################################################

set -e  # Exit on error

# Colors for beautiful output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
FORTRESS_DIR="$HOME/fortress-ai"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_DIR="$REPO_DIR/web"
PORT=8080
OLLAMA_HOST="127.0.0.1:11434"

# Print banner
clear
echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}  🏰 AGENT X - ONE-COMMAND WEB INTERFACE LAUNCHER${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Early validation: Check if we're in the correct repository
if [ ! -f "$REPO_DIR/LAUNCH_WEB_INTERFACE.sh" ]; then
    echo -e "${RED}❌ ERROR: Script location cannot be determined.${NC}"
    echo ""
    echo "This usually means the script was run in an unusual way."
    echo "Please run the script from the repository directory:"
    echo ""
    echo "  cd /path/to/repository"
    echo "  bash LAUNCH_WEB_INTERFACE.sh"
    echo ""
    exit 1
fi

if [ ! -d "$WEB_DIR" ]; then
    echo -e "${RED}❌ ERROR: Web directory not found!${NC}"
    echo ""
    echo "Expected to find: $WEB_DIR"
    echo "Current directory: $(pwd)"
    echo ""
    echo "This means you're not running the script from the repository root."
    echo ""
    echo "To fix this:"
    echo "  1. Find your repository: find ~ -name 'LAUNCH_WEB_INTERFACE.sh' 2>/dev/null"
    echo "  2. Navigate there: cd /path/shown/above/.."
    echo "  3. Run: bash LAUNCH_WEB_INTERFACE.sh"
    echo ""
    echo "Or see QUICK_START_INSTRUCTIONS.md for detailed help."
    echo ""
    exit 1
fi

# Function to print status messages
print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Step 1: Check Operating System
print_step "Checking operating system..."
if [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "linux"* ]]; then
    print_success "Running on Linux/WSL"
    # Check if WSL
    if grep -qi microsoft /proc/version 2>/dev/null; then
        print_info "WSL detected - browser auto-open will use Windows"
        IS_WSL=true
    else
        IS_WSL=false
    fi
else
    print_warning "Not running on Linux - some features may not work"
    IS_WSL=false
fi
echo ""

# Step 2: Check Python
print_step "Checking Python installation..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    print_success "Python $PYTHON_VERSION found"
    
    # Check if Python version is 3.8 or higher
    PYTHON_MAJOR=$(echo "$PYTHON_VERSION" | cut -d. -f1)
    PYTHON_MINOR=$(echo "$PYTHON_VERSION" | cut -d. -f2)
    if [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -ge 8 ]; then
        print_success "Python version is compatible (3.8+)"
    elif [ "$PYTHON_MAJOR" -gt 3 ]; then
        print_success "Python version is compatible (3.8+)"
    else
        print_error "Python 3.8 or higher required. Found: $PYTHON_VERSION"
        exit 1
    fi
else
    print_error "Python 3 not found. Please install Python 3.8 or higher"
    echo ""
    echo "Installation commands:"
    echo "  Ubuntu/Debian: sudo apt update && sudo apt install python3 python3-pip"
    echo "  Fedora/RHEL:   sudo dnf install python3 python3-pip"
    exit 1
fi

# Check pip
if command -v pip3 &> /dev/null; then
    print_success "pip3 found"
else
    print_error "pip3 not found. Please install pip3"
    echo "  Ubuntu/Debian: sudo apt install python3-pip"
    exit 1
fi
echo ""

# Step 3: Check Ollama
print_step "Checking Ollama installation..."
OLLAMA_BIN=""

# Check system-wide Ollama
if command -v ollama &> /dev/null; then
    OLLAMA_BIN=$(which ollama)
    print_success "Ollama found at: $OLLAMA_BIN"
elif [ -f "$FORTRESS_DIR/bin/ollama" ]; then
    OLLAMA_BIN="$FORTRESS_DIR/bin/ollama"
    print_success "Ollama found at: $OLLAMA_BIN"
else
    print_error "Ollama not found!"
    echo ""
    echo "📥 Please install Ollama first:"
    echo ""
    echo "   Linux/WSL:  curl -fsSL https://ollama.com/install.sh | sh"
    echo "   Manual:     https://ollama.com/download"
    echo ""
    exit 1
fi

# Check if Ollama is running
print_step "Checking if Ollama is running..."
if curl -s http://$OLLAMA_HOST/api/tags >/dev/null 2>&1; then
    print_success "Ollama server is running at $OLLAMA_HOST"
else
    print_warning "Ollama server not running - attempting to start..."
    
    # Start Ollama in background
    nohup "$OLLAMA_BIN" serve > /tmp/ollama-server.log 2>&1 &
    OLLAMA_PID=$!
    
    # Wait for Ollama to start (max 15 seconds)
    WAIT_COUNT=0
    while [ $WAIT_COUNT -lt 15 ]; do
        if curl -s http://$OLLAMA_HOST/api/tags >/dev/null 2>&1; then
            print_success "Ollama server started (PID: $OLLAMA_PID)"
            break
        fi
        sleep 1
        WAIT_COUNT=$((WAIT_COUNT + 1))
    done
    
    if [ $WAIT_COUNT -eq 15 ]; then
        print_error "Failed to start Ollama server after 15 seconds"
        echo ""
        echo "Please start Ollama manually:"
        echo "  $OLLAMA_BIN serve"
        echo ""
        echo "Then re-run this script."
        exit 1
    fi
fi

# Check if Qwen model is available
print_step "Checking AI model..."
if "$OLLAMA_BIN" list 2>/dev/null | grep -q "qwen2.5:7b"; then
    print_success "Qwen 2.5:7B model is available"
elif "$OLLAMA_BIN" list 2>/dev/null | grep -q "qwen2.5"; then
    print_success "Qwen 2.5 model is available"
else
    print_warning "Qwen 2.5:7B model not found"
    echo ""
    echo "📥 Downloading AI model (this will take 5-15 minutes)..."
    echo ""
    "$OLLAMA_BIN" pull qwen2.5:7b-instruct-q4_K_M || {
        print_error "Failed to download model"
        echo ""
        echo "Please download manually:"
        echo "  $OLLAMA_BIN pull qwen2.5:7b-instruct-q4_K_M"
        exit 1
    }
    print_success "Model downloaded successfully"
fi
echo ""

# Step 4: Create directory structure
print_step "Creating directory structure..."
mkdir -p "$FORTRESS_DIR"/{evidence,evidence/uploads,logs,logs/conversations,vector_db,bin,models}
print_success "Directories created:"
echo "   • $FORTRESS_DIR/evidence"
echo "   • $FORTRESS_DIR/evidence/uploads"
echo "   • $FORTRESS_DIR/logs/conversations"
echo "   • $FORTRESS_DIR/vector_db"
echo ""

# Step 5: Check Python dependencies
print_step "Checking Python dependencies..."
MISSING_DEPS=()

# Check each required package
REQUIRED_PACKAGES=("flask" "langchain" "langchain_community" "faiss" "sentence_transformers" "fitz" "docx" "bs4" "requests")
PACKAGE_NAMES=("flask" "langchain" "langchain-community" "faiss-cpu" "sentence-transformers" "pymupdf" "python-docx" "beautifulsoup4" "requests")

for i in "${!REQUIRED_PACKAGES[@]}"; do
    IMPORT_NAME="${REQUIRED_PACKAGES[$i]}"
    PACKAGE_NAME="${PACKAGE_NAMES[$i]}"
    
    # Use a safe way to check imports - pass as string to Python
    if ! python3 -c "import sys; import_name = sys.argv[1]; __import__(import_name)" "$IMPORT_NAME" 2>/dev/null; then
        MISSING_DEPS+=("$PACKAGE_NAME")
    fi
done

if [ ${#MISSING_DEPS[@]} -eq 0 ]; then
    print_success "All Python dependencies are installed"
else
    print_warning "Missing Python packages: ${MISSING_DEPS[*]}"
    echo ""
    print_step "Installing missing dependencies..."
    
    # Check if requirements.txt exists
    if [ -f "$REPO_DIR/requirements.txt" ]; then
        print_info "Installing from requirements.txt..."
        pip3 install -r "$REPO_DIR/requirements.txt" --quiet --disable-pip-version-check || {
            print_error "Failed to install dependencies from requirements.txt"
            echo ""
            echo "Try manual installation:"
            echo "  pip3 install ${MISSING_DEPS[*]}"
            exit 1
        }
    else
        # Install packages individually
        for pkg in "${MISSING_DEPS[@]}"; do
            print_info "Installing $pkg..."
            pip3 install "$pkg" --quiet --disable-pip-version-check || {
                print_error "Failed to install $pkg"
                exit 1
            }
        done
    fi
    
    print_success "All dependencies installed successfully"
fi
echo ""

# Step 6: Check port availability
print_step "Checking port $PORT availability..."
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
    print_warning "Port $PORT is already in use"
    
    # Get process info
    PORT_PID=$(lsof -t -i:$PORT 2>/dev/null)
    if [ -n "$PORT_PID" ]; then
        PORT_PROCESS=$(ps -p $PORT_PID -o comm= 2>/dev/null || echo "unknown")
        echo ""
        echo "   Process using port $PORT:"
        echo "   • PID: $PORT_PID"
        echo "   • Process: $PORT_PROCESS"
        echo ""
        
        # Ask user if they want to kill the process
        read -p "   Kill this process and continue? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            kill $PORT_PID 2>/dev/null || {
                print_error "Failed to kill process $PORT_PID"
                echo "   Try manually: sudo kill $PORT_PID"
                exit 1
            }
            sleep 2
            print_success "Process killed, port $PORT is now available"
        else
            print_error "Cannot start web interface while port $PORT is in use"
            echo ""
            echo "Kill the process manually:"
            echo "  kill $PORT_PID"
            exit 1
        fi
    fi
else
    print_success "Port $PORT is available"
fi
echo ""

# Step 7: Validate web directory
print_step "Validating web interface files..."
if [ ! -d "$WEB_DIR" ]; then
    print_error "Web directory not found: $WEB_DIR"
    echo "   Please ensure you're running this script from the repository root."
    exit 1
fi

if [ ! -f "$WEB_DIR/app.py" ]; then
    print_error "app.py not found in $WEB_DIR"
    exit 1
fi

if [ ! -d "$WEB_DIR/templates" ] || [ ! -f "$WEB_DIR/templates/index.html" ]; then
    print_error "Web templates not found"
    exit 1
fi

print_success "Web interface files validated"
echo ""

# Step 8: Set environment variables
export FORTRESS_DIR
export OLLAMA_BIN

# Step 9: Show launch info
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  🚀 STARTING AGENT X WEB INTERFACE${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BOLD}Access URL:${NC}     ${MAGENTA}http://localhost:$PORT${NC}"
echo -e "${BOLD}Fortress Dir:${NC}   $FORTRESS_DIR"
echo -e "${BOLD}Evidence Dir:${NC}   $FORTRESS_DIR/evidence"
echo -e "${BOLD}Logs Dir:${NC}       $FORTRESS_DIR/logs"
echo -e "${BOLD}AI Model:${NC}       Qwen 2.5:7B (4-bit quantized)"
echo ""
echo -e "${YELLOW}💡 USAGE TIPS:${NC}"
echo -e "   • Use ${BOLD}Windows Key + H${NC} for speech input (WSL/Windows)"
echo -e "   • Drag & drop files into browser to upload evidence"
echo -e "   • Press ${BOLD}Enter${NC} to send messages (Shift+Enter for new line)"
echo -e "   • Press ${BOLD}Ctrl+C${NC} to stop the server"
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Step 10: Open browser (WSL-aware)
print_step "Opening browser..."
sleep 1

# Validate PORT is a number
if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
    print_error "Invalid port number: $PORT"
    exit 1
fi

# Build safe URL
BROWSER_URL="http://localhost:${PORT}"

if [ "$IS_WSL" = true ] && command -v powershell.exe &> /dev/null; then
    # WSL - use Windows browser
    powershell.exe -Command "Start-Process '${BROWSER_URL}'" 2>/dev/null &
    print_success "Browser opened (Windows)"
elif command -v xdg-open &> /dev/null; then
    # Linux with X server
    xdg-open "${BROWSER_URL}" 2>/dev/null &
    print_success "Browser opened (Linux)"
elif command -v firefox &> /dev/null; then
    firefox "${BROWSER_URL}" 2>/dev/null &
    print_success "Browser opened (Firefox)"
elif command -v chromium &> /dev/null; then
    chromium "${BROWSER_URL}" 2>/dev/null &
    print_success "Browser opened (Chromium)"
else
    print_warning "Could not auto-open browser"
    echo ""
    echo "   Please open manually: ${MAGENTA}${BROWSER_URL}${NC}"
fi

sleep 2
echo ""

# Step 11: Start Flask app
print_step "Starting Flask web server..."
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}"
echo ""

cd "$WEB_DIR"

# Set trap to handle Ctrl+C gracefully
trap 'echo -e "\n${YELLOW}Shutting down Agent X...${NC}"; exit 0' INT TERM

# Start the Flask app
python3 app.py

# If we reach here, Flask has exited
echo ""
echo -e "${YELLOW}Agent X web interface stopped.${NC}"
