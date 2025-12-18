# 🔧 TROUBLESHOOTING GUIDE - Agent X Web Interface

This guide helps you solve common issues when launching the Agent X web interface.

---

## 🚨 Problem: Connection Refused (ERR_CONNECTION_REFUSED)

**Symptom:** Browser shows "ERR_CONNECTION_REFUSED" when accessing http://localhost:8080

### Solution 1: Port is Already in Use
The most common cause is another process using port 8080.

**Check what's using the port:**
```bash
lsof -i :8080
```

**Kill the process:**
```bash
kill $(lsof -t -i:8080)
```

**Then re-run:**
```bash
bash LAUNCH_WEB_INTERFACE.sh
```

### Solution 2: Flask Didn't Start
Check if Flask started successfully.

**Look for error messages in the terminal** where you ran the launch script.

Common Flask errors:
- Import errors → Python packages not installed (see below)
- Port binding errors → Port already in use (see Solution 1)
- Permission errors → Run without sudo (Flask should run as user)

### Solution 3: Firewall Blocking
WSL/Windows firewall might be blocking the connection.

**Allow Python through firewall (Windows):**
1. Open Windows Security → Firewall
2. Allow Python through firewall for private networks
3. Re-run the launch script

---

## 🤖 Problem: Ollama Not Found

**Symptom:** Script says "Ollama not found" or "Ollama server not running"

### Solution 1: Install Ollama

**Linux/WSL:**
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

**Windows:**
- Download from https://ollama.com/download
- Install the Windows version (it works with WSL)

**Verify installation:**
```bash
ollama --version
which ollama
```

### Solution 2: Ollama Not Running

**Start Ollama manually:**
```bash
ollama serve
```

**Leave this running in one terminal, then open a new terminal and run:**
```bash
bash LAUNCH_WEB_INTERFACE.sh
```

### Solution 3: Check Ollama Status

**Test if Ollama is responding:**
```bash
curl http://127.0.0.1:11434/api/tags
```

**Should return a JSON response with your models.**

If you get "Connection refused":
- Ollama is not running → Run `ollama serve`
- Wrong port → Check if Ollama is on different port
- Firewall → Temporarily disable to test

### Solution 4: AI Model Not Downloaded

**Check available models:**
```bash
ollama list
```

**Download Qwen 2.5 model (4.7 GB):**
```bash
ollama pull qwen2.5:7b-instruct-q4_K_M
```

This takes 5-15 minutes depending on internet speed.

---

## 📦 Problem: Python Import Errors

**Symptom:** Script fails with "ModuleNotFoundError" or import errors

### Solution 1: Install Missing Packages

**Install all dependencies at once:**
```bash
pip3 install -r requirements.txt
```

**Or install individually:**
```bash
pip3 install flask
pip3 install langchain langchain-community
pip3 install faiss-cpu
pip3 install sentence-transformers
pip3 install pymupdf python-docx beautifulsoup4
```

### Solution 2: Wrong Python Version

**Check Python version (need 3.8+):**
```bash
python3 --version
```

**If version is too old:**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install python3.12 python3.12-pip

# Use python3.12 explicitly
python3.12 -m pip install -r requirements.txt
```

### Solution 3: Virtual Environment Issues

**Create clean virtual environment:**
```bash
python3 -m venv ~/agent-x-venv
source ~/agent-x-venv/bin/activate
pip install -r requirements.txt
bash LAUNCH_WEB_INTERFACE.sh
```

---

## 🌐 Problem: Browser Won't Open Automatically

**Symptom:** Script runs but browser doesn't open automatically

### Solution: Open Browser Manually

**Simply open your browser and go to:**
```
http://localhost:8080
```

**Or if you prefer IPv4:**
```
http://127.0.0.1:8080
```

### WSL-Specific
In WSL, the script tries to use PowerShell to open Windows browser.

**If that fails, from Windows:**
1. Open any browser (Chrome, Firefox, Edge)
2. Type: `http://localhost:8080`
3. Press Enter

---

## 💾 Problem: Document Upload Fails

**Symptom:** "Upload failed" or files not being indexed

### Solution 1: Check File Type
Supported file types:
- Documents: `.pdf`, `.docx`, `.txt`, `.md`, `.html`, `.mhtml`
- Images: `.jpg`, `.jpeg`, `.png`
- Archives: `.zip`

### Solution 2: File Size Limit
Maximum file size is **50 MB**.

**Check file size:**
```bash
ls -lh your-file.pdf
```

**For larger files, split them or compress:**
```bash
# Compress PDF
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook \
   -dNOPAUSE -dQUIET -dBATCH -sOutputFile=compressed.pdf input.pdf
```

### Solution 3: Directory Permissions
Ensure the evidence directory is writable.

**Check permissions:**
```bash
ls -ld ~/fortress-ai/evidence
```

**Fix if needed:**
```bash
chmod 755 ~/fortress-ai/evidence
chmod 755 ~/fortress-ai/evidence/uploads
```

---

## 🔍 Problem: RAG Search Not Working

**Symptom:** Documents uploaded but AI doesn't cite them

### Solution 1: Re-Index Documents

**Delete vector database and re-upload:**
```bash
rm -rf ~/fortress-ai/vector_db/*
```

Then re-upload your documents through the web interface.

### Solution 2: Check Dependencies

**Ensure RAG dependencies are installed:**
```bash
pip3 show faiss-cpu sentence-transformers langchain langchain-community
```

**If missing:**
```bash
pip3 install faiss-cpu sentence-transformers langchain langchain-community
```

### Solution 3: Verify Document Processing

**Check logs for errors:**
```bash
tail -f ~/fortress-ai/logs/conversations/*.json
```

Look for error messages related to document processing.

---

## ⚡ Problem: Slow Response Times

**Symptom:** AI takes very long to respond (30+ seconds)

### Solution 1: Use Faster Model
The default Qwen 2.5:7B model is optimized, but you can try smaller models:

```bash
# Smaller, faster model
ollama pull qwen2.5:3b
```

Then edit `web/app.py` line 26 to use `qwen2.5:3b`.

### Solution 2: Check GPU Usage

**If you have NVIDIA GPU (RTX 5060):**
```bash
nvidia-smi
```

Should show Ollama using the GPU. If not, Ollama might not be using GPU acceleration.

**Reinstall Ollama with CUDA support** if GPU is not being used.

### Solution 3: Reduce RAG Search
If RAG search is slow:
- Upload fewer documents
- Use smaller documents
- Increase chunk size in app.py (line 386)

---

## 🖥️ WSL-Specific Issues

### Problem: WSL Can't Access Windows Browser

**Solution:**
The script uses `powershell.exe` to open browsers in Windows.

**Test if PowerShell is accessible:**
```bash
which powershell.exe
powershell.exe -Command "echo 'test'"
```

**If not working:**
- Add to PATH: `export PATH="$PATH:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"`
- Or just open browser manually in Windows

### Problem: Windows Firewall Blocking WSL

**Solution:**
1. Open Windows Security → Firewall & network protection
2. Advanced settings → Inbound Rules
3. Allow TCP port 8080 for private networks

---

## 🆘 Emergency Recovery

If nothing works, try this complete reset:

```bash
# 1. Stop everything
pkill -f ollama
pkill -f flask
pkill -f python.*app.py

# 2. Clean install
cd ~/
rm -rf fortress-ai
cd /path/to/agent-x-repo

# 3. Reinstall dependencies
pip3 install --force-reinstall -r requirements.txt

# 4. Start fresh
bash LAUNCH_WEB_INTERFACE.sh
```

---

## 📝 Still Having Issues?

### Collect Diagnostic Information

Run these commands and save output:

```bash
# System info
uname -a
python3 --version
pip3 --version

# Ollama status
ollama list
curl http://127.0.0.1:11434/api/tags

# Port status
lsof -i :8080
lsof -i :11434

# Python packages
pip3 list | grep -E "(flask|langchain|faiss|sentence)"

# Directory structure
ls -la ~/fortress-ai/
```

### Check Logs

```bash
# Flask/Web logs (in terminal where you ran the script)
# Ollama logs
cat /tmp/ollama-server.log
cat ~/fortress-ai/logs/ollama-server.log

# Conversation logs
ls -la ~/fortress-ai/logs/conversations/
```

### Common Error Messages

**"Address already in use"**
→ Port 8080 is busy. Kill process: `kill $(lsof -t -i:8080)`

**"ModuleNotFoundError: No module named 'flask'"**
→ Install Flask: `pip3 install flask`

**"Ollama not found"**
→ Install Ollama: `curl -fsSL https://ollama.com/install.sh | sh`

**"Model not found"**
→ Download model: `ollama pull qwen2.5:7b-instruct-q4_K_M`

**"Permission denied"**
→ Check directory permissions: `chmod 755 ~/fortress-ai`

---

## ✅ Success Checklist

When everything is working correctly, you should see:

- ✅ Script completes without errors
- ✅ Browser opens automatically (or opens manually)
- ✅ Web interface loads at http://localhost:8080
- ✅ Status indicator shows "Online"
- ✅ Can type messages and get AI responses
- ✅ Can upload documents successfully
- ✅ Windows Key+H speech input works (in browser text fields)

---

## 💡 Pro Tips

1. **Keep Ollama running**: Start `ollama serve` in a separate terminal and leave it running
2. **Bookmark the interface**: Add http://localhost:8080 to your browser bookmarks
3. **Use keyboard shortcuts**: Enter to send, Shift+Enter for new line, Win+H for speech
4. **Monitor resources**: Run `htop` or `nvidia-smi` to see resource usage
5. **Save conversations**: Your chats auto-save to `~/fortress-ai/logs/conversations/`

---

**Last Updated:** December 2024  
**For the latest version:** Check the GitHub repository
