#!/bin/bash
# install_agent_x.sh - Agent X Fortress Production Installer
set -e

RED='\033[0;31m'
GREEN='\033[0;32m' 
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "${CYAN}[$(date +'%H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}✅${NC} $1"; }
error() { echo -e "${RED}❌${NC} $1" >&2; }

INSTALL_DIR="/home/francesco/agent_x"
REPO="opusmax422-dot/-LONGO-AGENT-X---DEAD-TO-RIGHTS-LOOK-OUT-LONGO-FIVE-EYES-WATCHING-GOVERNMENT-CONSPIRACY-EXPOSED-"
BASE_URL="https://raw.githubusercontent.com/${REPO}/main"

echo -e "${CYAN}🏰 Agent X Fortress Installer${NC}"

# Check Python3
if ! command -v python3 &> /dev/null; then
    error "Python3 required: sudo apt install python3"
    exit 1
fi

log "Creating directories..."
mkdir -p "$INSTALL_DIR"/{bin,data/{charts,templates,evidence,social},config,logs,output}

log "Downloading Agent X application..."
wget -q "${BASE_URL}/bin/agent_x_launcher.py" -O "$INSTALL_DIR/bin/agent_x_launcher.py" || {
    error "Download failed"
    exit 1
}

log "Downloading TradingView library (offline mode)..."
wget -q "https://unpkg.com/lightweight-charts/dist/lightweight-charts.standalone.production.js" \
     -O "$INSTALL_DIR/data/charts/lightweight-charts.standalone.production.js"

chmod +x "$INSTALL_DIR/bin/agent_x_launcher.py"

cat > "$INSTALL_DIR/start_agent_x.sh" << 'EOF'
#!/bin/bash
echo "🚀 Starting Agent X Fortress..."
cd /home/francesco/agent_x
python3 bin/agent_x_launcher.py
EOF

chmod +x "$INSTALL_DIR/start_agent_x.sh"
ln -sf "$INSTALL_DIR/start_agent_x.sh" "$HOME/start_agent_x.sh" 2>/dev/null || true

success "Agent X Fortress installed successfully!"
echo "Run: ./start_agent_x.sh"