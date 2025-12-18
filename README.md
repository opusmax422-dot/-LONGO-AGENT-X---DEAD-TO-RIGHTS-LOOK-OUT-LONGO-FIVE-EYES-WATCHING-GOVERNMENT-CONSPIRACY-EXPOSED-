# 🏰 AGENT X - Fortress AI Web Interface

**One-Command AI Assistant for Legal Research & Document Analysis**

---

> **⚡ Just want to get started?** See [SIMPLE_START.md](SIMPLE_START.md) for the 2 commands you need!

---

## 🚀 QUICK START (ONE COMMAND)

**First time? Clone the repository:**

```bash
cd ~
git clone https://github.com/opusmax422-dot/-LONGO-AGENT-X---DEAD-TO-RIGHTS-LOOK-OUT-LONGO-FIVE-EYES-WATCHING-GOVERNMENT-CONSPIRACY-EXPOSED-.git
```

**Then navigate and run:**

```bash
# Navigate to the repository directory
# NOTE: Use ./ before the directory name since it starts with a hyphen
cd ./-LONGO-AGENT-X---DEAD-TO-RIGHTS-LOOK-OUT-LONGO-FIVE-EYES-WATCHING-GOVERNMENT-CONSPIRACY-EXPOSED-

# Run the launcher
bash LAUNCH_WEB_INTERFACE.sh
```

**That's it!** The script will:
- ✅ Check and install all dependencies
- ✅ Verify Ollama is running
- ✅ Create necessary directories
- ✅ Start the web server
- ✅ Open your browser automatically

**Access the interface at:** http://localhost:8080

---

## 📋 Prerequisites

Before running the quick start, ensure you have:

1. **Linux/WSL** (Ubuntu, Debian, Fedora, etc.)
2. **Python 3.8+** (usually pre-installed)
3. **Ollama** - Install with:
   ```bash
   curl -fsSL https://ollama.com/install.sh | sh
   ```

That's all you need! The launch script handles everything else.

---

## 💡 Features

- 🤖 **Local AI Chat** - Powered by Qwen 2.5:7B (4-bit quantized)
- 📚 **RAG Document Search** - Upload evidence and get AI-powered citations
- 🎤 **Speech Input** - Use Windows Key+H for voice dictation (WSL)
- 🔒 **100% Offline** - All data stays on your PC
- 🎯 **Legal Focus** - Optimized for legal research and case analysis
- 📁 **File Upload** - Drag & drop PDF, DOCX, TXT, MD, HTML files
- 💬 **Conversation History** - Auto-saved to `~/fortress-ai/logs/conversations/`

---

## 🎯 Usage

### Starting the Interface

```bash
bash LAUNCH_WEB_INTERFACE.sh
```

### Using the Chat Interface

1. **Type or speak your question** (Windows Key+H for speech)
2. **Press Enter** to send (Shift+Enter for new line)
3. **Wait for AI response** (typically 5-15 seconds)
4. **Upload documents** by dragging into browser or clicking 📎

### Example Queries

- "Explain the 4th Amendment and unlawful search"
- "Review the evidence in my uploaded documents about [topic]"
- "What are my rights during an unlawful detention?"
- "Draft a legal argument about [issue]"

---

## 📁 Directory Structure

After running the launcher, these directories are created:

```
~/fortress-ai/
├── evidence/          # Your uploaded documents
│   └── uploads/       # Auto-uploaded files
├── logs/
│   └── conversations/ # Chat history (JSON format)
├── vector_db/         # RAG embeddings database
├── bin/               # Binaries (if using local Ollama)
└── models/            # AI model storage (if using local Ollama)
```

---

## 🔧 Troubleshooting

Having issues? Check the comprehensive troubleshooting guide:

**[📖 TROUBLESHOOTING.md](TROUBLESHOOTING.md)**

### Common Quick Fixes

**Port 8080 in use:**
```bash
kill $(lsof -t -i:8080)
```

**Ollama not running:**
```bash
ollama serve
```

**Missing Python packages:**
```bash
pip3 install -r requirements.txt
```

**Browser won't open automatically:**
- Manually go to: http://localhost:8080

---

## 🛠️ Advanced Configuration

### Change AI Model

Edit `web/app.py` line 36 to use a different model:
```python
MODEL_NAME = "qwen2.5:3b"  # Smaller, faster model
```

Then download the model:
```bash
ollama pull qwen2.5:3b
```

### Change Port

Edit `LAUNCH_WEB_INTERFACE.sh` line 20:
```bash
PORT=8081
```

### Custom Fortress Directory

Edit `web/app.py` line 20:
```python
FORTRESS_DIR = Path("/custom/path/fortress-ai")
```

---

## 📝 System Requirements

### Minimum
- **OS:** Linux/WSL Ubuntu 20.04+
- **RAM:** 8 GB
- **Storage:** 10 GB free (for AI model)
- **CPU:** 4 cores recommended

### Recommended
- **RAM:** 16 GB+ 
- **GPU:** NVIDIA RTX 3060+ (for faster responses)
- **Storage:** 20 GB+ (for multiple models and documents)

---

## 🔐 Privacy & Security

- ✅ **100% Offline** - No data sent to cloud services
- ✅ **Local Storage** - All conversations saved locally
- ✅ **No Telemetry** - No tracking or analytics
- ✅ **Your Hardware** - Runs entirely on your PC/laptop

---

## 📦 What Gets Installed

The launch script installs these Python packages:
- `flask` - Web framework
- `langchain` + `langchain-community` - AI framework
- `faiss-cpu` - Vector database for RAG
- `sentence-transformers` - Text embeddings
- `pymupdf` - PDF processing
- `python-docx` - DOCX processing
- `beautifulsoup4` - HTML processing
- `requests` - HTTP client

See [requirements.txt](requirements.txt) for exact versions.

---

## 🤝 Support & Documentation

- **Quick Start:** You're reading it! (This README)
- **Troubleshooting:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Technical Details:** [TECHNICAL_VALIDATION.md](TECHNICAL_VALIDATION.md)
- **Deployment:** [DEPLOYMENT-READY.md](DEPLOYMENT-READY.md)

---

## ⚖️ Legal Notice

🚨 **LONGO AGENT X - DEAD TO RIGHTS: TOP SECRET**

**KIDNAPPING BY USA (DEA) | ATTEMPTED MURDER BY CANADIAN GOVERNMENT**

**INTERPOL | FBI | DEA | ESPIONAGE | SURVEILLANCE**

**DOCUMENTED CRIMES THEY CANNOT DENY:**
- ✅ **KIDNAPPING:** 18 months unlawful detention by US/DEA (no charges, no warrant, no paperwork)
- ✅ **ATTEMPTED MURDER:** [Details in case files]

This software is designed to help document and organize evidence of government misconduct, civil rights violations, and legal cases. All functionality operates 100% offline to protect sensitive information.

---

## 📜 License

See [LICENSE](LICENSE) file for details.

---

**Made with ⚖️ for Legal Justice and Civil Rights Protection** 
