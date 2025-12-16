#!/bin/bash
################################################################################
# AGENT X - COMPREHENSIVE SYSTEM STATUS CHECKER
# Validates all components are installed and operational
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
FORTRESS_DIR="$HOME/fortress-ai"
OLLAMA_BIN="$FORTRESS_DIR/bin/ollama"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REQUIRED_MODEL="qwen2.5:7b-instruct-q4_K_M"

# Status counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
WARNINGS=0
FAILURES=0

# Function to print section header
print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to check status
check_status() {
    local check_name=$1
    local status=$2
    local message=$3
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ "$status" = "pass" ]; then
        echo -e "${GREEN}✓${NC} $check_name: $message"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    elif [ "$status" = "warn" ]; then
        echo -e "${YELLOW}⚠${NC} $check_name: $message"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "${RED}✗${NC} $check_name: $message"
        FAILURES=$((FAILURES + 1))
    fi
}

################################################################################
# MAIN STATUS REPORT
################################################################################

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  🏰 AGENT X - SYSTEM STATUS REPORT${NC}"
echo -e "${CYAN}  Comprehensive Component Validation${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Report generated: $(date)"
echo "Repository: $REPO_DIR"
echo ""

################################################################################
# 1. SYSTEM REQUIREMENTS
################################################################################
print_header "1. SYSTEM REQUIREMENTS"

# Check OS
if [ -f /etc/os-release ]; then
    OS_INFO=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)
    check_status "Operating System" "pass" "$OS_INFO"
else
    check_status "Operating System" "warn" "Unknown OS"
fi

# Check Python version
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    check_status "Python 3" "pass" "Version $PYTHON_VERSION"
else
    check_status "Python 3" "fail" "Not installed"
fi

# Check available memory
if command -v free &> /dev/null; then
    TOTAL_MEM=$(free -h | grep Mem | awk '{print $2}')
    AVAIL_MEM=$(free -h | grep Mem | awk '{print $7}')
    check_status "System Memory" "pass" "Total: $TOTAL_MEM, Available: $AVAIL_MEM"
else
    check_status "System Memory" "warn" "Unable to check"
fi

# Check disk space
DISK_SPACE=$(df -h "$HOME" | tail -1 | awk '{print "Used: " $3 " / " $2 " (" $5 ")"}')
check_status "Disk Space" "pass" "$DISK_SPACE"

################################################################################
# 2. OLLAMA INSTALLATION
################################################################################
print_header "2. OLLAMA AI ENGINE"

# Check if Ollama binary exists
if [ -f "$OLLAMA_BIN" ]; then
    check_status "Ollama Binary" "pass" "Found at $OLLAMA_BIN"
    OLLAMA_CMD="$OLLAMA_BIN"
elif command -v ollama &> /dev/null; then
    OLLAMA_CMD=$(which ollama)
    check_status "Ollama Binary" "pass" "Found at $OLLAMA_CMD (system-wide)"
else
    check_status "Ollama Binary" "fail" "Not found - install from https://ollama.com"
    OLLAMA_CMD=""
fi

# Check if Ollama server is running
if [ -n "$OLLAMA_CMD" ]; then
    if pgrep -x "ollama" > /dev/null 2>&1; then
        OLLAMA_PID=$(pgrep -x "ollama")
        check_status "Ollama Server" "pass" "Running (PID: $OLLAMA_PID)"
    else
        check_status "Ollama Server" "warn" "Not running - start with: ollama serve"
    fi
    
    # Check Ollama version
    if [ -x "$OLLAMA_CMD" ]; then
        OLLAMA_VERSION=$($OLLAMA_CMD --version 2>/dev/null | head -1 || echo "Unknown")
        check_status "Ollama Version" "pass" "$OLLAMA_VERSION"
    fi
fi

################################################################################
# 3. AI MODELS
################################################################################
print_header "3. AI MODELS"

if [ -n "$OLLAMA_CMD" ] && [ -x "$OLLAMA_CMD" ]; then
    # Check if required model is downloaded
    if $OLLAMA_CMD list 2>/dev/null | grep -q "$REQUIRED_MODEL"; then
        MODEL_SIZE=$($OLLAMA_CMD list 2>/dev/null | grep "$REQUIRED_MODEL" | awk '{print $2}')
        check_status "Qwen 2.5:7B Model" "pass" "Installed ($MODEL_SIZE)"
    else
        check_status "Qwen 2.5:7B Model" "fail" "Not found - pull with: ollama pull $REQUIRED_MODEL"
    fi
    
    # List all available models
    echo ""
    echo "  Available Models:"
    $OLLAMA_CMD list 2>/dev/null | tail -n +2 | while read -r line; do
        echo "    • $line"
    done || echo "    (None)"
else
    check_status "Model Check" "fail" "Cannot check - Ollama not available"
fi

################################################################################
# 4. PYTHON DEPENDENCIES
################################################################################
print_header "4. PYTHON DEPENDENCIES"

# Required packages
declare -a REQUIRED_PACKAGES=(
    "flask:Flask"
    "langchain:LangChain"
    "langchain_community:LangChain Community"
    "faiss:FAISS (Vector DB)"
    "sentence_transformers:Sentence Transformers"
    "pymupdf:PyMuPDF (fitz)"
)

for pkg_pair in "${REQUIRED_PACKAGES[@]}"; do
    IFS=':' read -r pkg_name pkg_label <<< "$pkg_pair"
    if python3 -c "import $pkg_name" 2>/dev/null; then
        VERSION=$(python3 -c "import $pkg_name; print(getattr($pkg_name, '__version__', 'installed'))" 2>/dev/null || echo "installed")
        check_status "$pkg_label" "pass" "Version $VERSION"
    else
        check_status "$pkg_label" "fail" "Not installed - install with: pip3 install ${pkg_name//_/-}"
    fi
done

################################################################################
# 5. REPOSITORY STRUCTURE
################################################################################
print_header "5. REPOSITORY STRUCTURE"

# Check critical files and directories
declare -A CRITICAL_PATHS=(
    ["web/app.py"]="Flask Backend"
    ["web/templates/index.html"]="Web UI Template"
    ["web/static/style.css"]="Web UI Styles"
    ["start-agent-x.sh"]="Startup Script"
    ["scripts/install_agent.sh"]="Installation Script"
    ["DEPLOYMENT-READY.md"]="Deployment Documentation"
)

for path in "${!CRITICAL_PATHS[@]}"; do
    if [ -e "$REPO_DIR/$path" ]; then
        check_status "${CRITICAL_PATHS[$path]}" "pass" "$path exists"
    else
        check_status "${CRITICAL_PATHS[$path]}" "fail" "$path missing"
    fi
done

################################################################################
# 6. FORTRESS AI WORKSPACE
################################################################################
print_header "6. FORTRESS AI WORKSPACE"

# Check workspace directories
declare -a WORKSPACE_DIRS=(
    "$FORTRESS_DIR"
    "$FORTRESS_DIR/logs"
    "$FORTRESS_DIR/logs/conversations"
    "$FORTRESS_DIR/evidence"
    "$FORTRESS_DIR/evidence/uploads"
    "$FORTRESS_DIR/vector_db"
)

for dir in "${WORKSPACE_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        FILE_COUNT=$(find "$dir" -type f 2>/dev/null | wc -l)
        check_status "Directory: $(basename $dir)" "pass" "$dir ($FILE_COUNT files)"
    else
        check_status "Directory: $(basename $dir)" "warn" "Not created yet - will be created on first run"
    fi
done

################################################################################
# 7. RAG SYSTEM
################################################################################
print_header "7. RAG (Document Search) SYSTEM"

# Check vector database
if [ -d "$FORTRESS_DIR/vector_db" ] && [ -f "$FORTRESS_DIR/vector_db/index.faiss" ]; then
    DB_SIZE=$(du -sh "$FORTRESS_DIR/vector_db" 2>/dev/null | cut -f1)
    check_status "Vector Database" "pass" "Indexed ($DB_SIZE)"
else
    check_status "Vector Database" "warn" "Not initialized - upload documents to create"
fi

# Check evidence documents
if [ -d "$FORTRESS_DIR/evidence" ]; then
    DOC_COUNT=$(find "$FORTRESS_DIR/evidence" -type f \( -name "*.pdf" -o -name "*.txt" -o -name "*.md" \) 2>/dev/null | wc -l)
    if [ "$DOC_COUNT" -gt 0 ]; then
        check_status "Evidence Documents" "pass" "$DOC_COUNT documents found"
    else
        check_status "Evidence Documents" "warn" "No documents uploaded yet"
    fi
else
    check_status "Evidence Documents" "warn" "Evidence directory not created"
fi

# Check embedding model
if python3 -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('all-MiniLM-L6-v2')" 2>/dev/null; then
    check_status "Embedding Model" "pass" "all-MiniLM-L6-v2 ready"
else
    check_status "Embedding Model" "warn" "Not downloaded - will download on first use"
fi

################################################################################
# 8. WEB INTERFACE
################################################################################
print_header "8. WEB INTERFACE"

# Check if port 8080 is available
if ! lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1; then
    check_status "Port 8080" "pass" "Available for use"
else
    check_status "Port 8080" "warn" "Already in use by PID $(lsof -t -i:8080)"
fi

# Check Flask installation
if python3 -c "from flask import Flask" 2>/dev/null; then
    check_status "Flask Framework" "pass" "Installed and importable"
else
    check_status "Flask Framework" "fail" "Not installed"
fi

################################################################################
# 9. FUNCTIONAL TESTS
################################################################################
print_header "9. FUNCTIONAL TESTS"

# Test Python imports
if python3 -c "
import sys
sys.path.insert(0, '$REPO_DIR/web')
try:
    import app
    print('SUCCESS')
except Exception as e:
    print(f'ERROR: {e}')
" 2>&1 | grep -q "SUCCESS"; then
    check_status "Flask App Import" "pass" "app.py loads successfully"
else
    check_status "Flask App Import" "warn" "app.py may have import issues"
fi

# Test Ollama API (if running)
if [ -n "$OLLAMA_CMD" ] && pgrep -x "ollama" > /dev/null 2>&1; then
    if timeout 5 $OLLAMA_CMD list >/dev/null 2>&1; then
        check_status "Ollama API" "pass" "Responding to requests"
    else
        check_status "Ollama API" "warn" "Not responding (may be starting up)"
    fi
fi

################################################################################
# FINAL SUMMARY
################################################################################
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  📊 FINAL SUMMARY${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Calculate percentages
if [ $TOTAL_CHECKS -gt 0 ]; then
    SUCCESS_RATE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
else
    SUCCESS_RATE=0
fi

echo "Total Checks:    $TOTAL_CHECKS"
echo -e "${GREEN}Passed:          $PASSED_CHECKS${NC}"
echo -e "${YELLOW}Warnings:        $WARNINGS${NC}"
echo -e "${RED}Failures:        $FAILURES${NC}"
echo ""
echo -e "Success Rate:    ${GREEN}${SUCCESS_RATE}%${NC}"
echo ""

# Overall status
if [ $FAILURES -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}🎉 SYSTEM STATUS: EXCELLENT${NC}"
    echo -e "${GREEN}All components are installed and operational!${NC}"
    EXIT_CODE=0
elif [ $FAILURES -eq 0 ]; then
    echo -e "${YELLOW}✓ SYSTEM STATUS: GOOD${NC}"
    echo -e "${YELLOW}System is operational with minor warnings.${NC}"
    EXIT_CODE=0
elif [ $PASSED_CHECKS -gt $FAILURES ]; then
    echo -e "${YELLOW}⚠ SYSTEM STATUS: PARTIAL${NC}"
    echo -e "${YELLOW}Some components need attention before full deployment.${NC}"
    EXIT_CODE=1
else
    echo -e "${RED}✗ SYSTEM STATUS: INCOMPLETE${NC}"
    echo -e "${RED}Critical components are missing. Review failures above.${NC}"
    EXIT_CODE=2
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}🚀 READY TO START: bash start-agent-x.sh${NC}"
else
    echo -e "${YELLOW}📋 NEXT STEPS:${NC}"
    echo "  1. Review failures and warnings above"
    echo "  2. Install missing components"
    echo "  3. Run this script again to verify"
    echo "  4. Once all checks pass, start with: bash start-agent-x.sh"
fi

echo ""

exit $EXIT_CODE
