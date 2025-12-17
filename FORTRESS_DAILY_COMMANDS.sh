#!/bin/bash
# FORTRESS_DAILY_COMMANDS.sh
# Francesco's Daily Trading Workflow - WSL Automation Script

set -e  # Exit on error

# Configuration
FORTRESS_DIR="$HOME/FORTRESS_AGENT_X"
OUTPUT_DIR="$HOME/FORTRESS_OUTPUT"
DESKTOP_DIR="/mnt/c/Users/bob/Desktop"
DATE_STR=$(date +%Y%m%d)

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔒 FORTRESS AGENT X - DAILY WORKFLOW${NC}"
echo "=========================================="
echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Step 1: Surveillance Check
echo -e "${YELLOW}[1/5] Checking for surveillance processes...${NC}"
if ps aux | grep -i "AQAUserPS" | grep -v grep > /dev/null; then
    echo -e "${RED}⚠️  WARNING: AQAUserPS detected!${NC}"
    echo "   Surveillance process is running. Recommend offline mode."
else
    echo -e "${GREEN}✓ No known surveillance processes detected${NC}"
fi
echo ""

# Step 2: Generate Daily Chart
echo -e "${YELLOW}[2/5] Generating full-day trading chart...${NC}"
if [ -f "$FORTRESS_DIR/francesco_full_day_chart_generator.py" ]; then
    cd "$FORTRESS_DIR"
    python3 francesco_full_day_chart_generator.py
    echo -e "${GREEN}✓ Chart generated successfully${NC}"
else
    echo -e "${RED}✗ Chart generator not found. Using offline version...${NC}"
    if [ -f "$FORTRESS_DIR/AGENT_X_COMPLETE_OFFLINE.py" ]; then
        python3 "$FORTRESS_DIR/AGENT_X_COMPLETE_OFFLINE.py"
        echo -e "${GREEN}✓ Offline chart generated${NC}"
    else
        echo -e "${RED}✗ ERROR: No chart generator available${NC}"
        exit 1
    fi
fi
echo ""

# Step 3: Create Evidence Package
echo -e "${YELLOW}[3/5] Creating evidence package...${NC}"
mkdir -p "$OUTPUT_DIR"
if [ -d "$FORTRESS_DIR/logs" ]; then
    tar -czf "$OUTPUT_DIR/fortress_evidence_${DATE_STR}.tar.gz" \
        "$FORTRESS_DIR/logs/" \
        "$FORTRESS_DIR/"*.png 2>/dev/null || true
    echo -e "${GREEN}✓ Evidence package created${NC}"
else
    echo -e "${YELLOW}⚠️  No logs directory found (first run?)${NC}"
fi
echo ""

# Step 4: Generate Hash
echo -e "${YELLOW}[4/5] Generating evidence hash...${NC}"
if [ -f "$OUTPUT_DIR/fortress_evidence_${DATE_STR}.tar.gz" ]; then
    sha256sum "$OUTPUT_DIR/fortress_evidence_${DATE_STR}.tar.gz" > "$OUTPUT_DIR/HASH_${DATE_STR}.txt"
    echo -e "${GREEN}✓ Hash generated:${NC}"
    cat "$OUTPUT_DIR/HASH_${DATE_STR}.txt"
else
    echo -e "${YELLOW}⚠️  No evidence package to hash${NC}"
fi
echo ""

# Step 5: Copy to Desktop
echo -e "${YELLOW}[5/5] Copying hash to Desktop...${NC}"
if [ -f "$OUTPUT_DIR/HASH_${DATE_STR}.txt" ]; then
    cp "$OUTPUT_DIR/HASH_${DATE_STR}.txt" "$DESKTOP_DIR/"
    ls -lh "$DESKTOP_DIR/HASH_${DATE_STR}.txt"
    echo -e "${GREEN}✓ Hash copied to Desktop${NC}"
else
    echo -e "${YELLOW}⚠️  No hash file to copy${NC}"
fi
echo ""

# Summary
echo "=========================================="
echo -e "${GREEN}✅ FORTRESS DAILY WORKFLOW COMPLETE${NC}"
echo ""
echo "📊 View chart: $FORTRESS_DIR/*.png"
echo "📦 Evidence: $OUTPUT_DIR/fortress_evidence_${DATE_STR}.tar.gz"
echo "🔐 Hash: $DESKTOP_DIR/HASH_${DATE_STR}.txt"
echo ""
echo "⚠️  Remember: Monitor for surveillance & back up algorithm"