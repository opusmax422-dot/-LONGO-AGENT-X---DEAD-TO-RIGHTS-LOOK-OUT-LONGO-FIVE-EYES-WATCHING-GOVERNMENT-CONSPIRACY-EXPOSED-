# 🏰 AGENT X - Autonomous AI Interface

## What is Agent X?

Agent X is a professional web-based interface for your local AI (Qwen 2.5:7B). It provides a ChatGPT-like experience that runs **100% offline** on your PC.

### Features

✅ **Clean Web Interface** - Professional chat-style UI at `http://localhost:8080`  
✅ **Windows Speech Input** - Press `Windows Key + H` to dictate questions  
✅ **100% Offline** - No internet required, completely private  
✅ **Conversation History** - Auto-saves all conversations to logs  
✅ **One-Command Startup** - Just run `bash start-agent-x.sh`  
✅ **Legal AI Assistant** - Specialized for civil rights and legal research  

---

## 🚀 Quick Start

### On Your Local PC (WSL2 Ubuntu):

```bash
cd ~/fortress-ai
bash start-agent-x.sh
```

That's it! The browser will open automatically to `http://localhost:8080`

---

## 📋 Requirements

Before running Agent X, ensure you have:

1. **Ollama installed** (with `qwen2.5:7b-instruct-q4_K_M` model)
2. **Python 3** with Flask (`pip3 install flask`)
3. **WSL2 Ubuntu** (or any Linux environment)

---

## 🎯 How to Use

### Basic Usage

1. **Start Agent X:**
   ```bash
   bash start-agent-x.sh
   ```

2. **Access Interface:**
   - Browser opens automatically
   - Or manually go to: `http://localhost:8080`

3. **Ask Questions:**
   - Type in the text box
   - Or press `Windows Key + H` to use speech
   - Press Enter or click "Send"

4. **Features:**
   - **Clear Chat** - Saves current conversation and starts fresh
   - **Copy Response** - Copies AI's last response to clipboard
   - **Status Indicator** - Shows online/offline status

### Speech Input (Windows)

1. Click in the text box
2. Press `Windows Key + H`
3. Speak your question
4. Windows will transcribe your speech into the text box
5. Press Enter to send

---

## 📁 File Structure

```
~/fortress-ai/
├── start-agent-x.sh          # Startup script
├── web/
│   ├── app.py                # Flask backend
│   ├── templates/
│   │   └── index.html        # Web interface
│   └── static/
│       └── style.css         # Styling
├── logs/
│   ├── conversations/        # Auto-saved conversations
│   └── ollama-server.log     # Server logs
├── bin/
│   └── ollama                # Ollama binary
└── models/                   # AI models storage
```

---

## 🔧 Configuration

### Change Port (Default: 8080)

Edit `start-agent-x.sh`:
```bash
PORT=8080  # Change this line
```

Edit `web/app.py`:
```python
app.run(host="0.0.0.0", port=8080, debug=False)  # Change port here
```

### Change AI Model

Edit `web/app.py`:
```python
MODEL_NAME = "qwen2.5:7b-instruct-q4_K_M"  # Change model name
```

### Conversation Storage

Conversations automatically save to:
```
~/fortress-ai/logs/conversations/conversation-YYYYMMDD-HHMMSS.json
```

Each file contains:
- Timestamp
- Full conversation (user + AI messages)
- Structured JSON format

---

## 🐛 Troubleshooting

### Ollama Not Found

**Error:** "Ollama not installed"

**Solution:**
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

### Model Not Downloaded

**Error:** "Qwen 2.5:7B model not found"

**Solution:**
```bash
ollama pull qwen2.5:7b-instruct-q4_K_M
```
(This takes 10-15 minutes - 4.7 GB download)

### Port Already in Use

**Error:** "Port 8080 is already in use"

**Solution:**
```bash
# Find and kill existing process
kill $(lsof -t -i:8080)

# Or change port in configuration
```

### Flask Not Installed

**Error:** "ModuleNotFoundError: No module named 'flask'"

**Solution:**
```bash
pip3 install flask
```

### Browser Doesn't Auto-Open

**Manual Access:**
1. Open any browser on Windows
2. Go to: `http://localhost:8080`
3. (WSL2 forwards localhost automatically)

### Ollama Server Won't Start

**Check logs:**
```bash
cat ~/fortress-ai/logs/ollama-server.log
```

**Manual start:**
```bash
ollama serve
```

---

## 🎨 Customization

### Change UI Theme

Edit `web/static/style.css`:
```css
:root {
    --primary-color: #2563eb;      /* Blue accent color */
    --bg-dark: #0f172a;            /* Dark background */
    --text-primary: #f1f5f9;       /* Text color */
}
```

### Add New API Endpoints

Edit `web/app.py` and add new routes:
```python
@app.route("/api/custom", methods=["POST"])
def api_custom():
    # Your custom endpoint
    return jsonify({"result": "success"})
```

---

## 🔒 Security & Privacy

### 100% Offline Operation

- No internet connection required
- All processing happens locally
- Conversations never leave your PC
- No cloud APIs, no tracking

### Data Storage

- Conversations: `~/fortress-ai/logs/conversations/`
- Server logs: `~/fortress-ai/logs/ollama-server.log`
- All stored locally, never uploaded

### Network Binding

- Listens on: `0.0.0.0:8080`
- Accessible only from: `localhost` (same machine)
- WSL2: Windows can access via `localhost`
- Not exposed to internet/LAN

---

## 🚀 Advanced Usage

### Run in Background

```bash
nohup bash start-agent-x.sh > /tmp/agent-x.log 2>&1 &
```

### Auto-Start on Boot

Add to `~/.bashrc`:
```bash
# Auto-start Agent X
if ! pgrep -f "app.py" > /dev/null; then
    bash ~/fortress-ai/start-agent-x.sh &
fi
```

### Integration with Other Scripts

Query AI from command line:
```bash
curl -X POST http://localhost:8080/api/query \
  -H "Content-Type: application/json" \
  -d '{"message": "Your question here"}'
```

Response:
```json
{
  "response": "AI answer...",
  "timestamp": "2025-12-15T17:30:00"
}
```

---

## 📊 API Documentation

### POST /api/query

Send message to AI:
```json
Request:
{
  "message": "Your question"
}

Response:
{
  "response": "AI response",
  "timestamp": "ISO-8601 timestamp"
}
```

### POST /api/clear

Clear conversation:
```json
Response:
{
  "status": "cleared"
}
```

### GET /api/status

Check system status:
```json
Response:
{
  "ollama_running": true,
  "ollama_exists": true,
  "ollama_path": "/usr/local/bin/ollama",
  "model": "qwen2.5:7b-instruct-q4_K_M",
  "conversation_count": 5
}
```

### GET /api/history

Get conversation history:
```json
Response:
{
  "messages": [
    {
      "role": "user",
      "content": "Question",
      "timestamp": "..."
    },
    {
      "role": "assistant",
      "content": "Answer",
      "timestamp": "..."
    }
  ]
}
```

---

## 🎯 Use Cases

### Legal Research

- Ask questions about civil rights law
- Research case law and precedents
- Get explanations of legal concepts
- Draft legal documents

### Document Analysis

- Upload evidence (future feature)
- Analyze legal documents
- Extract key information
- Summarize complex texts

### Case Strategy

- Discuss case approaches
- Explore legal arguments
- Identify potential issues
- Plan litigation strategy

---

## 🆘 Support

### Check System Status

```bash
# Check if Ollama is running
ps aux | grep ollama

# Check Flask server
ps aux | grep app.py

# Check port binding
lsof -i :8080

# View recent logs
tail -f ~/fortress-ai/logs/ollama-server.log
```

### Restart Everything

```bash
# Kill all processes
pkill ollama
pkill -f app.py

# Restart
bash ~/fortress-ai/start-agent-x.sh
```

---

## 📝 Version History

### v1.0 (2025-12-15)
- Initial release
- Web interface with chat UI
- Windows speech input support
- Conversation history
- Auto-save functionality
- Status monitoring
- Error handling

---

## 🏰 Fortress AI Project

Agent X is part of the Fortress AI suite for legal automation and civil rights litigation support.

**Repository:** [GitHub - LONGO-AGENT-X](https://github.com/opusmax422-dot/-LONGO-AGENT-X---DEAD-TO-RIGHTS-LOOK-OUT-LONGO-FIVE-EYES-WATCHING-GOVERNMENT-CONSPIRACY-EXPOSED-)

---

## 📄 License

For personal use in civil rights litigation.

---

**🏰 Agent X - Your Autonomous Legal AI Assistant**
