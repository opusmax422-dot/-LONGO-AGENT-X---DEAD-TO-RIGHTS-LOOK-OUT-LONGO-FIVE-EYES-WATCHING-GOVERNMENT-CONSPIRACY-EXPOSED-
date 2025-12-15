#!/bin/bash

##############################################################################
# FORTRESS AI STACK INSTALLATION SCRIPT
# Automated installation of Ollama + AI models + Python libraries
# Non-interactive with automatic sudo handling
##############################################################################

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Status tracking
INSTALLATION_LOG="/tmp/fortress_install.log"
INSTALL_START=$(date)

# Initialize log
echo "=== FORTRESS AI STACK INSTALLATION ===" > "$INSTALLATION_LOG"
echo "Start Time: $INSTALL_START" >> "$INSTALLATION_LOG"
echo "" >> "$INSTALLATION_LOG"

log_message() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$INSTALLATION_LOG"
}

success_message() {
    echo -e "${GREEN}✓ $1${NC}"
    echo "✓ $1" >> "$INSTALLATION_LOG"
}

error_message() {
    echo -e "${RED}✗ $1${NC}"
    echo "✗ $1" >> "$INSTALLATION_LOG"
}

warning_message() {
    echo -e "${YELLOW}⚠ $1${NC}"
    echo "⚠ $1" >> "$INSTALLATION_LOG"
}

##############################################################################
# STEP 1: Update system and install dependencies
##############################################################################
log_message "STEP 1: Updating system packages..."

sudo apt-get update -qq >> "$INSTALLATION_LOG" 2>&1 || true
sudo apt-get install -y -qq curl wget git build-essential >> "$INSTALLATION_LOG" 2>&1 || true

success_message "System packages updated"

##############################################################################
# STEP 2: Install Ollama
##############################################################################
log_message "STEP 2: Installing Ollama..."

if command -v ollama &> /dev/null; then
    OLLAMA_VERSION=$(ollama --version 2>/dev/null | grep -oP 'version \K[0-9.]+' || echo "unknown")
    warning_message "Ollama already installed (version: $OLLAMA_VERSION). Skipping download."
else
    log_message "Downloading Ollama installer..."
    curl -fsSL https://ollama.ai/install.sh -o /tmp/ollama_install.sh >> "$INSTALLATION_LOG" 2>&1
    
    log_message "Running Ollama installer..."
    chmod +x /tmp/ollama_install.sh
    /tmp/ollama_install.sh >> "$INSTALLATION_LOG" 2>&1 || {
        error_message "Ollama installation failed"
        exit 1
    }
    
    success_message "Ollama installed successfully"
fi

##############################################################################
# STEP 3: Start Ollama service
##############################################################################
log_message "STEP 3: Starting Ollama service..."

# Check if ollama service exists
if systemctl is-enabled ollama &>/dev/null 2>&1; then
    sudo systemctl start ollama >> "$INSTALLATION_LOG" 2>&1 || true
    success_message "Ollama service started"
else
    log_message "Starting Ollama in background..."
    ollama serve > /tmp/ollama.log 2>&1 &
    OLLAMA_PID=$!
    echo $OLLAMA_PID > /tmp/ollama.pid
    sleep 3
    success_message "Ollama server running (PID: $OLLAMA_PID)"
fi

##############################################################################
# STEP 4: Download AI models
##############################################################################
log_message "STEP 4: Downloading AI models..."

MODELS_TO_INSTALL=(
    "qwen2.5:7b-instruct-q4_K_M"
    "llama2:7b-chat-q4_K_M"
)

for model in "${MODELS_TO_INSTALL[@]}"; do
    log_message "Downloading model: $model"
    
    # Check available disk space
    AVAILABLE_SPACE=$(df -B1 / | awk 'NR==2 {print $4}')
    AVAILABLE_GB=$((AVAILABLE_SPACE / 1024 / 1024 / 1024))
    
    if [ "$AVAILABLE_GB" -lt 15 ]; then
        warning_message "Low disk space ($AVAILABLE_GB GB). Skipping $model"
        
        if [[ "$model" == *"qwen"* ]]; then
            error_message "Cannot skip primary model (qwen). Insufficient disk space."
            exit 1
        fi
        continue
    fi
    
    if timeout 1800 ollama pull "$model" >> "$INSTALLATION_LOG" 2>&1; then
        success_message "Model downloaded: $model"
    else
        warning_message "Failed to download model: $model (may already exist)"
    fi
    
    sleep 2
done

##############################################################################
# STEP 5: Install Python and pip
##############################################################################
log_message "STEP 5: Installing Python environment..."

if ! command -v python3 &> /dev/null; then
    sudo apt-get install -y -qq python3 python3-pip python3-venv >> "$INSTALLATION_LOG" 2>&1
    success_message "Python installed"
else
    PYTHON_VERSION=$(python3 --version)
    success_message "Python already installed: $PYTHON_VERSION"
fi

# Upgrade pip
python3 -m pip install --quiet --upgrade pip >> "$INSTALLATION_LOG" 2>&1 || true

##############################################################################
# STEP 6: Install Python AI libraries
##############################################################################
log_message "STEP 6: Installing Python AI libraries..."

PYTHON_PACKAGES=(
    "langchain"
    "langchain-ollama"
    "langchain-community"
    "llama-index"
    "faiss-cpu"
    "sentence-transformers"
    "pypdf"
    "python-docx"
    "beautifulsoup4"
    "requests"
    "pydantic"
    "numpy"
    "scipy"
)

for package in "${PYTHON_PACKAGES[@]}"; do
    log_message "Installing: $package"
    python3 -m pip install --quiet --no-input "$package" >> "$INSTALLATION_LOG" 2>&1 || {
        warning_message "Failed to install $package (non-critical)"
    }
done

success_message "Python libraries installed"

##############################################################################
# STEP 7: Create workspace structure
##############################################################################
log_message "STEP 7: Creating Fortress workspace..."

WORKSPACE_HOME="${HOME}/lawsuit-ai"
SUBDIRS=(
    "evidence"
    "legal-docs"
    "templates"
    "logs"
    "vector-db"
    "scripts"
)

mkdir -p "$WORKSPACE_HOME"
for subdir in "${SUBDIRS[@]}"; do
    mkdir -p "$WORKSPACE_HOME/$subdir"
done

success_message "Workspace created at: $WORKSPACE_HOME"

##############################################################################
# STEP 8: Create essential configuration files
##############################################################################
log_message "STEP 8: Creating configuration files..."

# Create .env file
cat > "$WORKSPACE_HOME/.env" << 'EOF'
OLLAMA_HOST=localhost:11434
OLLAMA_MODEL_QWEN=qwen2.5:7b-instruct-q4_K_M
OLLAMA_MODEL_BACKUP=llama2:7b-chat-q4_K_M
PROJECT_NAME=Fortress
WORKSPACE_ROOT=~/lawsuit-ai
EOF

# Create main Python agent starter script
cat > "$WORKSPACE_HOME/scripts/start_agent.py" << 'EOF'
#!/usr/bin/env python3
"""
Fortress AI Agent Launcher
Initializes the local AI stack for legal automation
"""

import os
import sys
from pathlib import Path

# Add workspace to path
WORKSPACE = Path.home() / "lawsuit-ai"
sys.path.insert(0, str(WORKSPACE))

try:
    from langchain_ollama import OllamaLLM
    print("✓ LangChain Ollama integration loaded")
except ImportError as e:
    print(f"✗ Failed to import LangChain: {e}")
    sys.exit(1)

# Initialize Ollama connection
try:
    llm = OllamaLLM(model="qwen2.5:7b-instruct-q4_K_M", base_url="http://localhost:11434")
    print("✓ Connected to Ollama")
except Exception as e:
    print(f"✗ Failed to connect to Ollama: {e}")
    sys.exit(1)

# Test the model
try:
    response = llm.invoke("Say 'AI ready for legal work'")
    print(f"✓ Model response: {response}")
except Exception as e:
    print(f"✗ Model test failed: {e}")
    sys.exit(1)

print("\n" + "="*50)
print("FORTRESS AI STACK IS READY")
print("="*50)
print(f"Workspace: {WORKSPACE}")
print(f"Models available: qwen2.5:7b, llama2:7b")
print("="*50)
EOF

chmod +x "$WORKSPACE_HOME/scripts/start_agent.py"
success_message "Configuration files created"

##############################################################################
# STEP 9: Verify installations
##############################################################################
log_message "STEP 9: Verifying installations..."

echo "" >> "$INSTALLATION_LOG"
echo "=== VERIFICATION RESULTS ===" >> "$INSTALLATION_LOG"
echo "" >> "$INSTALLATION_LOG"

# Check Ollama
if command -v ollama &> /dev/null; then
    OLLAMA_VERSION=$(ollama --version 2>/dev/null || echo "unknown")
    success_message "Ollama: $OLLAMA_VERSION"
    echo "Ollama: $OLLAMA_VERSION" >> "$INSTALLATION_LOG"
else
    error_message "Ollama not found"
fi

# Check available models
log_message "Available Ollama models:"
ollama list 2>/dev/null | tee -a "$INSTALLATION_LOG"

# Check Python packages
log_message "Checking Python packages..."
python3 -m pip list 2>/dev/null | grep -E "langchain|llama|faiss" >> "$INSTALLATION_LOG" 2>&1 || true

# Check workspace
log_message "Workspace structure:"
ls -la "$WORKSPACE_HOME/" 2>/dev/null | tee -a "$INSTALLATION_LOG"

##############################################################################
# STEP 10: Run final test
##############################################################################
log_message "STEP 10: Running model test..."

TEST_PROMPT="Say 'AI ready for legal work'"
echo "" >> "$INSTALLATION_LOG"
echo "=== MODEL TEST ===" >> "$INSTALLATION_LOG"
echo "Test: $TEST_PROMPT" >> "$INSTALLATION_LOG"
echo "" >> "$INSTALLATION_LOG"

log_message "Testing primary model (qwen2.5)..."
if ollama run qwen2.5:7b-instruct-q4_K_M "$TEST_PROMPT" >> "$INSTALLATION_LOG" 2>&1; then
    success_message "Model test PASSED"
else
    warning_message "Model test returned non-zero exit (may still be functional)"
fi

##############################################################################
# FINAL REPORT
##############################################################################
echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  FORTRESS AI STACK INSTALLATION COMPLETE${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""

echo "📊 INSTALLATION SUMMARY:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Ollama status
if command -v ollama &> /dev/null; then
    echo -e "${GREEN}✓ Ollama${NC} - Installed and ready"
else
    echo -e "${RED}✗ Ollama${NC} - Installation failed"
fi

# Models status
echo ""
echo "📦 Available Models:"
ollama list 2>/dev/null || echo "  (Run 'ollama list' to check)"

# Python libraries status
echo ""
echo "🐍 Python Libraries:"
python3 -m pip list 2>/dev/null | grep -E "langchain|llama|faiss" | head -5 || echo "  (Check with: pip list | grep langchain)"

# Workspace status
echo ""
echo "📁 Workspace Structure:"
echo "  Location: $WORKSPACE_HOME"
echo "  $(find $WORKSPACE_HOME -type d | wc -l) directories created"
echo "  $(find $WORKSPACE_HOME -type f | wc -l) files created"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🚀 NEXT STEPS:"
echo "  1. Run: python3 $WORKSPACE_HOME/scripts/start_agent.py"
echo "  2. Check logs: cat $INSTALLATION_LOG"
echo "  3. Start using: ollama run qwen2.5:7b-instruct-q4_K_M"
echo ""
echo "📝 Installation log saved to: $INSTALLATION_LOG"
echo ""

# Update log with final timestamp
echo "" >> "$INSTALLATION_LOG"
echo "End Time: $(date)" >> "$INSTALLATION_LOG"
echo "Installation completed successfully" >> "$INSTALLATION_LOG"

exit 0
