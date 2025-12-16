# 🔍 AGENT X - STATUS & MONITORING GUIDE

Quick reference for checking system health and deployment readiness.

---

## 📊 STATUS CHECKING TOOLS

### 1. System Status Checker (Comprehensive)
**Script**: `./check_system_status.sh`

**What it checks** (30+ validations):
- ✅ Operating System & Python version
- ✅ System memory & disk space
- ✅ Ollama installation & server status
- ✅ AI model availability (Qwen 2.5:7B)
- ✅ Python dependencies (Flask, LangChain, FAISS, etc.)
- ✅ Repository file structure
- ✅ Fortress AI workspace directories
- ✅ RAG system (vector DB, documents, embeddings)
- ✅ Web interface (port availability, Flask)
- ✅ Functional tests (imports, API checks)

**Usage**:
```bash
# Run comprehensive system check
./check_system_status.sh

# Expected output: Color-coded status with ✓ / ⚠ / ✗ indicators
# Exit code: 0 = success, 1 = warnings, 2 = critical failures
```

**When to use**:
- Before first deployment
- After installing dependencies
- When troubleshooting issues
- To verify system readiness

---

### 2. Runtime API Status (While Running)
**Endpoint**: `GET http://localhost:8080/api/status`

**What it returns**:
```json
{
  "status": "healthy|degraded",
  "timestamp": "2025-12-16T03:00:00Z",
  "ollama": {
    "running": true,
    "exists": true,
    "path": "/path/to/ollama",
    "model": "qwen2.5:7b-instruct-q4_K_M"
  },
  "rag": {
    "available": true,
    "document_count": 150,
    "vector_db_size_mb": 2.5
  },
  "conversation": {
    "message_count": 10,
    "turn_count": 5
  },
  "dependencies": {
    "flask": "installed",
    "langchain": "installed",
    "faiss": "installed",
    "sentence_transformers": "installed"
  },
  "system": {
    "python_version": "3.12.3",
    "platform": "Linux-6.5.0-1025-azure",
    "memory_total_gb": 15.0,
    "memory_available_gb": 12.5,
    "cpu_count": 4
  },
  "health_checks": {
    "ollama_running": true,
    "rag_available": true,
    "dependencies_ok": true
  }
}
```

**Usage**:
```bash
# Using curl (while Agent X is running)
curl http://localhost:8080/api/status | jq

# Or in browser
# Navigate to: http://localhost:8080/api/status
```

**When to use**:
- Monitor system while running
- Check if Ollama is still running
- Verify RAG system status
- Get document counts
- Track conversation progress

---

### 3. Quick Health Check Commands

#### Check if Ollama is running:
```bash
pgrep -x ollama && echo "✓ Ollama running" || echo "✗ Ollama not running"
```

#### Check if port 8080 is available:
```bash
lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1 && echo "✗ Port in use" || echo "✓ Port available"
```

#### Check if Python dependencies are installed:
```bash
python3 -c "import flask, langchain, faiss, sentence_transformers" && echo "✓ All deps installed" || echo "✗ Missing deps"
```

#### Check if AI model is downloaded:
```bash
ollama list | grep qwen2.5:7b && echo "✓ Model ready" || echo "✗ Model missing"
```

#### Check vector database:
```bash
[ -f ~/fortress-ai/vector_db/index.faiss ] && echo "✓ Vector DB exists" || echo "⚠ No vector DB yet"
```

---

## 📈 MONITORING DASHBOARD

### System Health Indicators

| Indicator | Meaning | Action |
|-----------|---------|--------|
| 🟢 **Healthy** | All systems operational | Continue normal use |
| 🟡 **Degraded** | Some warnings present | Review warnings, may still work |
| 🔴 **Critical** | Major failures | Install missing components |

### Component Status Levels

| Symbol | Status | Description |
|--------|--------|-------------|
| ✓ | **Pass** | Component working correctly |
| ⚠ | **Warning** | May work, needs attention |
| ✗ | **Failure** | Component missing or broken |

---

## 🔧 TROUBLESHOOTING BY STATUS

### If Ollama shows ✗ (Failed)
```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Start Ollama server
ollama serve &

# Pull AI model
ollama pull qwen2.5:7b-instruct-q4_K_M

# Verify
./check_system_status.sh
```

### If Python Dependencies show ✗ (Failed)
```bash
# Install all at once
pip3 install flask langchain langchain-community faiss-cpu sentence-transformers pymupdf

# Or use the automated script
bash DEPLOY_TO_LOCAL_PC.sh

# Verify
./check_system_status.sh
```

### If RAG shows ⚠ (Warning)
```bash
# This is normal before uploading documents
# Start Agent X and upload at least one document:
bash start-agent-x.sh

# Then in browser:
# 1. Navigate to http://localhost:8080
# 2. Click "Upload Document"
# 3. Select a PDF or TXT file
# 4. Wait for "Document uploaded and indexed" ✅

# RAG will then show ✓ on next check
```

### If Port 8080 shows ⚠ (In Use)
```bash
# Find what's using it
lsof -i :8080

# Kill the process (replace PID with actual process ID)
kill $(lsof -t -i:8080)

# Or change port in start-agent-x.sh (line 20)
PORT=8081  # Use different port
```

---

## 📋 PRE-DEPLOYMENT CHECKLIST

Use this before first deployment:

```bash
# 1. Run system checker
./check_system_status.sh

# 2. Verify these show ✓:
#    - Operating System
#    - Python 3
#    - System Memory
#    - Disk Space
#    - Repository files (all 6)

# 3. Install anything showing ✗:
#    - Ollama binary
#    - AI models
#    - Python dependencies

# 4. Run checker again
./check_system_status.sh

# 5. Verify success rate > 90%

# 6. Start Agent X
bash start-agent-x.sh

# 7. Check runtime status
curl http://localhost:8080/api/status
```

---

## 🎯 SUCCESS CRITERIA

**System is ready when**:
- ✅ System status checker shows 90%+ success rate
- ✅ Ollama server running
- ✅ Qwen 2.5:7B model available
- ✅ All Python dependencies installed
- ✅ Repository structure complete
- ✅ Port 8080 available
- ✅ Flask app starts without errors
- ✅ Browser opens to http://localhost:8080

**Then you can**:
- 💬 Chat with AI
- 📄 Upload documents
- 🔍 Use RAG search
- 📚 Get source citations
- 💾 Save conversations

---

## 🆘 QUICK TROUBLESHOOTING

| Problem | Command to Fix |
|---------|----------------|
| System check fails | `./check_system_status.sh` (review output) |
| Ollama not installed | `curl -fsSL https://ollama.com/install.sh \| sh` |
| Ollama not running | `ollama serve &` |
| Model missing | `ollama pull qwen2.5:7b-instruct-q4_K_M` |
| Python deps missing | `pip3 install flask langchain faiss-cpu` |
| Port in use | `kill $(lsof -t -i:8080)` |
| App won't start | `bash start-agent-x.sh` (review errors) |
| RAG not working | Upload a document first |
| Memory issues | Close other apps, system needs 4GB+ |

---

## 📊 MONITORING BEST PRACTICES

### Before Starting:
1. ✅ Run `./check_system_status.sh`
2. ✅ Verify no critical failures (✗)
3. ✅ Address any warnings (⚠)
4. ✅ Confirm port 8080 available

### While Running:
1. 📍 Check `/api/status` periodically
2. 📍 Monitor `~/fortress-ai/logs/` for errors
3. 📍 Verify Ollama still running: `pgrep ollama`
4. 📍 Watch memory: `free -h` (need 4GB+ available)

### After Using:
1. 🔍 Review conversation logs in `~/fortress-ai/logs/conversations/`
2. 🔍 Check if vector DB updated after uploads
3. 🔍 Note any performance issues
4. 🔍 Document any errors encountered

---

## 🔍 ADVANCED DIAGNOSTICS

### Full System Dump
```bash
# Comprehensive info for troubleshooting
{
  echo "=== SYSTEM INFO ==="
  uname -a
  python3 --version
  free -h
  df -h
  
  echo -e "\n=== OLLAMA STATUS ==="
  pgrep -x ollama && echo "Running" || echo "Not running"
  ollama list 2>/dev/null || echo "Ollama not available"
  
  echo -e "\n=== PYTHON PACKAGES ==="
  pip3 list | grep -E "flask|langchain|faiss|sentence"
  
  echo -e "\n=== FORTRESS AI ==="
  ls -lh ~/fortress-ai/ 2>/dev/null || echo "Not created"
  
  echo -e "\n=== REPOSITORY ==="
  ls -lh check_system_status.sh start-agent-x.sh web/app.py
  
  echo -e "\n=== NETWORK ==="
  lsof -i :8080 || echo "Port 8080 available"
} > system-diagnostic.txt

cat system-diagnostic.txt
```

### Watch Live Status
```bash
# Monitor status every 5 seconds
watch -n 5 'curl -s http://localhost:8080/api/status | jq ".status, .ollama.running, .rag.document_count"'
```

### Log Monitoring
```bash
# Watch Ollama logs live
tail -f ~/fortress-ai/logs/ollama-server.log

# Watch conversation activity
watch -n 2 'ls -lt ~/fortress-ai/logs/conversations/ | head -5'
```

---

**See also**:
- 📄 [FINAL_SYSTEM_REPORT.md](FINAL_SYSTEM_REPORT.md) - Complete deployment status
- 📖 [README-AGENT-X.md](README-AGENT-X.md) - User guide
- 🚀 [DEPLOYMENT-READY.md](DEPLOYMENT-READY.md) - Deployment checklist

---

Last updated: December 16, 2025
