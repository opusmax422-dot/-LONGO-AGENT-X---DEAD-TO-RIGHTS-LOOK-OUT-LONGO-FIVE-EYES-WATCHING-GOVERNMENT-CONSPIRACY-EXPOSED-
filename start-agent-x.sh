#!/bin/bash
################################################################################
# AGENT X - STARTUP SCRIPT
# One-command launcher for Fortress AI web interface
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
FORTRESS_DIR="$HOME/fortress-ai"
OLLAMA_BIN="$FORTRESS_DIR/bin/ollama"
WEB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/web"
PORT=8080

echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  🏰 AGENT X - FORTRESS AI AUTONOMOUS INTERFACE${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Check if fortress-ai directory exists
if [ ! -d "$FORTRESS_DIR" ]; then
    echo -e "${YELLOW}⚠️  Fortress AI directory not found: $FORTRESS_DIR${NC}"
    echo -e "${YELLOW}   Creating directory...${NC}"
    mkdir -p "$FORTRESS_DIR"/{bin,logs,models}
fi

# Check if web directory exists
if [ ! -d "$WEB_DIR" ]; then
    echo -e "${RED}❌ Web directory not found: $WEB_DIR${NC}"
    echo -e "${RED}   Please run this script from the repository root.${NC}"
    exit 1
fi

# Check Python dependencies
echo -e "${BLUE}📦 Checking Python dependencies...${NC}"
if ! python3 -c "import flask" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Flask not installed. Installing...${NC}"
    pip3 install flask
    echo -e "${GREEN}✅ Flask installed${NC}"
else
    echo -e "${GREEN}✅ Flask already installed${NC}"
fi

# Check if Ollama binary exists
if [ ! -f "$OLLAMA_BIN" ]; then
    # Try system-wide ollama
    if command -v ollama &> /dev/null; then
        OLLAMA_BIN=$(which ollama)
        echo -e "${GREEN}✅ Using system Ollama: $OLLAMA_BIN${NC}"
    else
        echo -e "${YELLOW}⚠️  Ollama not found at $OLLAMA_BIN${NC}"
        echo -e "${YELLOW}   Checking system installation...${NC}"
        
        if command -v ollama &> /dev/null; then
            OLLAMA_BIN=$(which ollama)
            echo -e "${GREEN}✅ Found system Ollama: $OLLAMA_BIN${NC}"
        else
            echo -e "${RED}❌ Ollama not installed${NC}"
            echo -e "${RED}   Please install Ollama first:${NC}"
            echo -e "${RED}   curl -fsSL https://ollama.com/install.sh | sh${NC}"
            exit 1
        fi
    fi
else
    echo -e "${GREEN}✅ Ollama binary found: $OLLAMA_BIN${NC}"
fi

# Check if Ollama is running
echo -e "${BLUE}🔍 Checking Ollama server status...${NC}"
if pgrep -x "ollama" > /dev/null; then
    echo -e "${GREEN}✅ Ollama server is already running (PID: $(pgrep -x ollama))${NC}"
else
    echo -e "${YELLOW}⚠️  Ollama server not running. Starting...${NC}"
    
    # Start Ollama in background
    nohup "$OLLAMA_BIN" serve > "$FORTRESS_DIR/logs/ollama-server.log" 2>&1 &
    sleep 3
    
    if pgrep -x "ollama" > /dev/null; then
        echo -e "${GREEN}✅ Ollama server started (PID: $(pgrep -x ollama))${NC}"
    else
        echo -e "${RED}❌ Failed to start Ollama server${NC}"
        echo -e "${RED}   Check logs: $FORTRESS_DIR/logs/ollama-server.log${NC}"
        exit 1
    fi
fi

# Check if model is downloaded
echo -e "${BLUE}🤖 Checking AI model...${NC}"
if "$OLLAMA_BIN" list | grep -q "qwen2.5:7b-instruct-q4_K_M"; then
    echo -e "${GREEN}✅ Qwen 2.5:7B model is available${NC}"
else
    echo -e "${RED}❌ Qwen 2.5:7B model not found${NC}"
    echo -e "${YELLOW}   Download with: ollama pull qwen2.5:7b-instruct-q4_K_M${NC}"
    echo -e "${YELLOW}   (This will take 10-15 minutes for 4.7 GB download)${NC}"
    exit 1
fi

# Check if port is already in use
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${RED}❌ Port $PORT is already in use${NC}"
    echo -e "${RED}   Kill existing process: kill \$(lsof -t -i:$PORT)${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  🚀 STARTING AGENT X WEB INTERFACE${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}  Access URL: ${BLUE}http://localhost:$PORT${NC}"
echo -e "${GREEN}  Status: Starting Flask server...${NC}"
echo ""
echo -e "${YELLOW}  💡 TIPS:${NC}"
echo -e "${YELLOW}     • Use Windows Key+H for speech input${NC}"
echo -e "${YELLOW}     • Press Enter to send messages${NC}"
echo -e "${YELLOW}     • Conversations auto-save to logs/${NC}"
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Try to open browser (works in WSL2 with browser on Windows)
if command -v powershell.exe &> /dev/null; then
    echo -e "${BLUE}🌐 Opening browser...${NC}"
    powershell.exe -Command "Start-Process 'http://localhost:$PORT'" 2>/dev/null || true
    sleep 2
fi

# Start Flask app
cd "$WEB_DIR"
export FORTRESS_DIR
export OLLAMA_BIN
python3 app.py

# Cleanup on exit
trap "echo -e '\n${YELLOW}Shutting down Agent X...${NC}'" EXIT
