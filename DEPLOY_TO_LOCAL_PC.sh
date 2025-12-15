#!/bin/bash
################################################################################
# DEPLOY AGENT X TO LOCAL PC
# Run this script on your Windows PC in WSL2 Ubuntu
################################################################################

cd ~

echo "=================================================="
echo "  DEPLOYING AGENT X TO LOCAL FORTRESS"
echo "=================================================="
echo ""

REPO_DIR="-LONGO-AGENT-X---DEAD-TO-RIGHTS-LOOK-OUT-LONGO-FIVE-EYES-WATCHING-GOVERNMENT-CONSPIRACY-EXPOSED-"

# Clone/update the repository
if [ -d "$REPO_DIR" ]; then
    echo "📂 Repository exists - updating..."
    cd "$REPO_DIR"
    git pull origin main
else
    echo "📥 Cloning repository..."
    git clone https://github.com/opusmax422-dot/-LONGO-AGENT-X---DEAD-TO-RIGHTS-LOOK-OUT-LONGO-FIVE-EYES-WATCHING-GOVERNMENT-CONSPIRACY-EXPOSED-.git
    cd "$REPO_DIR"
fi

echo ""
echo "📋 Files downloaded:"
ls -lh web/ start-agent-x.sh README-AGENT-X.md 2>/dev/null || ls -lh

echo ""
echo "🔍 Checking for Agent X files..."
if [ -f "start-agent-x.sh" ]; then
    echo "✅ Found startup script: start-agent-x.sh"
    chmod +x start-agent-x.sh
else
    echo "❌ Startup script not found!"
    echo "Looking for shell scripts:"
    find . -name "*.sh" -type f
    exit 1
fi

if [ -d "web" ]; then
    echo "✅ Found web interface: web/"
else
    echo "❌ Web directory not found!"
    exit 1
fi

echo ""
echo "🔧 Checking dependencies..."

# Check Python
if command -v python3 &> /dev/null; then
    echo "✅ Python 3: $(python3 --version)"
else
    echo "❌ Python 3 not found"
    exit 1
fi

# Check Flask
if python3 -c "import flask" 2>/dev/null; then
    echo "✅ Flask already installed"
else
    echo "⚠️  Flask not installed - installing now..."
    pip3 install flask
    if [ $? -eq 0 ]; then
        echo "✅ Flask installed successfully"
    else
        echo "❌ Failed to install Flask"
        exit 1
    fi
fi

# Check Ollama
if command -v ollama &> /dev/null; then
    echo "✅ Ollama found: $(which ollama)"
else
    echo "❌ Ollama not installed!"
    echo ""
    echo "Install with:"
    echo "  curl -fsSL https://ollama.com/install.sh | sh"
    echo "  ollama pull qwen2.5:7b-instruct-q4_K_M"
    exit 1
fi

# Check if Ollama model is available
if ollama list | grep -q "qwen2.5:7b-instruct-q4_K_M"; then
    echo "✅ Qwen 2.5:7B model available"
else
    echo "⚠️  Qwen 2.5:7B model not found"
    echo ""
    echo "Download with:"
    echo "  ollama pull qwen2.5:7b-instruct-q4_K_M"
    echo "  (This takes 10-15 minutes - 4.7 GB download)"
    echo ""
    read -p "Download now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ollama pull qwen2.5:7b-instruct-q4_K_M
    else
        echo "⏭️  Skipping model download"
    fi
fi

echo ""
echo "=================================================="
echo "  ✅ AGENT X READY TO LAUNCH"
echo "=================================================="
echo ""
echo "Start Agent X with:"
echo ""
echo "  bash start-agent-x.sh"
echo ""
echo "This will:"
echo "  • Check/start Ollama server"
echo "  • Launch Flask web interface"
echo "  • Open http://localhost:8080 in browser"
echo ""
echo "Windows Speech Input:"
echo "  • Press Windows Key + H"
echo "  • Speak your question"
echo "  • AI will respond"
echo ""
echo "=================================================="
