# 🚀 QUICK START - Agent X Web Interface

## ⚠️ IMPORTANT: Directory Name Starts with Hyphen!

The repository name starts with a hyphen (`-`), which causes bash to interpret it as a command option. You **MUST** use `./` before the directory name:

```bash
# ✅ CORRECT - Use ./ prefix
cd ./-LONGO-AGENT-X---DEAD-TO-RIGHTS-LOOK-OUT-LONGO-FIVE-EYES-WATCHING-GOVERNMENT-CONSPIRACY-EXPOSED-

# ❌ WRONG - Will give "invalid option" error
cd -LONGO-AGENT-X---DEAD-TO-RIGHTS-LOOK-OUT-LONGO-FIVE-EYES-WATCHING-GOVERNMENT-CONSPIRACY-EXPOSED-
```

---

## The Problem You're Experiencing

If you're seeing **"No such file or directory"** or **"invalid option"** error, it's likely because:

1. **You're not in the correct directory** when running the script
2. **The repository wasn't cloned properly**
3. **You're using the wrong command**

---

## ✅ CORRECT WAY TO RUN

### Step 1: Navigate to the Repository Directory

First, you MUST be in the repository root directory:

```bash
cd /path/to/-LONGO-AGENT-X---DEAD-TO-RIGHTS-LOOK-OUT-LONGO-FIVE-EYES-WATCHING-GOVERNMENT-CONSPIRACY-EXPOSED-
```

Or if you just cloned it (NOTE: Use ./ prefix since directory name starts with a hyphen):
```bash
cd ./-LONGO-AGENT-X---DEAD-TO-RIGHTS-LOOK-OUT-LONGO-FIVE-EYES-WATCHING-GOVERNMENT-CONSPIRACY-EXPOSED-
```

### Step 2: Verify You're in the Right Place

Check that you can see the launcher script:

```bash
ls -la LAUNCH_WEB_INTERFACE.sh
```

You should see something like:
```
-rwxrwxr-x 1 user user 13351 Dec 18 12:50 LAUNCH_WEB_INTERFACE.sh
```

### Step 3: Run the Script

Now run the ONE command:

```bash
bash LAUNCH_WEB_INTERFACE.sh
```

**NOTE:** Use `bash` before the script name. This ensures it runs correctly.

---

## ❌ WRONG WAYS (Will Cause Errors)

**DON'T DO THIS:**
```bash
# ❌ Forgetting ./ prefix (gives "invalid option" error)
cd -LONGO-AGENT-X---DEAD-TO-RIGHTS-LOOK-OUT-LONGO-FIVE-EYES-WATCHING-GOVERNMENT-CONSPIRACY-EXPOSED-
# ERROR: -bash: cd: -O: invalid option

# ❌ Running from wrong directory
cd ~
bash LAUNCH_WEB_INTERFACE.sh  # ERROR: No such file

# ❌ Wrong path
./some/other/path/LAUNCH_WEB_INTERFACE.sh  # ERROR: No such file

# ❌ Trying to run without bash command
LAUNCH_WEB_INTERFACE.sh  # May fail depending on PATH
```

---

## 🔍 Troubleshooting "No Such File"

### Error: "bash: LAUNCH_WEB_INTERFACE.sh: No such file or directory"

**Solution:** You're not in the repository directory.

1. Find where you cloned the repository:
   ```bash
   find ~ -name "LAUNCH_WEB_INTERFACE.sh" 2>/dev/null
   ```

2. Navigate to that directory:
   ```bash
   cd /path/shown/above
   ```

3. Run the script:
   ```bash
   bash LAUNCH_WEB_INTERFACE.sh
   ```

### Error During Script Execution: "Web directory not found"

**Solution:** The repository might not be complete.

1. Check if the `web` directory exists:
   ```bash
   ls -la web/
   ```

2. If missing, re-clone the repository:
   ```bash
   git clone https://github.com/opusmax422-dot/-LONGO-AGENT-X---DEAD-TO-RIGHTS-LOOK-OUT-LONGO-FIVE-EYES-WATCHING-GOVERNMENT-CONSPIRACY-EXPOSED-.git
   cd ./-LONGO-AGENT-X---DEAD-TO-RIGHTS-LOOK-OUT-LONGO-FIVE-EYES-WATCHING-GOVERNMENT-CONSPIRACY-EXPOSED-
   bash LAUNCH_WEB_INTERFACE.sh
   ```

---

## 📍 How to Know You're in the Right Directory

When you run `ls`, you should see these files:

```
LAUNCH_WEB_INTERFACE.sh  ← The launcher script
requirements.txt          ← Python dependencies
README.md                 ← Documentation
TROUBLESHOOTING.md        ← Help guide
web/                      ← Web interface directory
  ├── app.py
  ├── templates/
  └── static/
```

If you see these files, you're in the right place!

---

## 🎯 Full Example: From Clone to Running

Here's the complete sequence from start to finish:

```bash
# 1. Clone the repository (if you haven't already)
git clone https://github.com/opusmax422-dot/-LONGO-AGENT-X---DEAD-TO-RIGHTS-LOOK-OUT-LONGO-FIVE-EYES-WATCHING-GOVERNMENT-CONSPIRACY-EXPOSED-.git

# 2. Navigate into the repository (use ./ prefix since name starts with hyphen)
cd ./-LONGO-AGENT-X---DEAD-TO-RIGHTS-LOOK-OUT-LONGO-FIVE-EYES-WATCHING-GOVERNMENT-CONSPIRACY-EXPOSED-

# 3. Verify you're in the right place
ls LAUNCH_WEB_INTERFACE.sh

# 4. Run the launcher
bash LAUNCH_WEB_INTERFACE.sh

# 5. Wait for browser to open (10-30 seconds)
# 6. Start chatting at http://localhost:8080
```

---

## 🆘 Still Having Issues?

1. **Share the exact error message** - Copy the full error output
2. **Show your current directory** - Run: `pwd`
3. **Show what files you see** - Run: `ls -la`
4. **Check README.md** - Has the full documentation
5. **Check TROUBLESHOOTING.md** - Has 38 solutions for common problems

---

## ✅ What Success Looks Like

When you run the script correctly, you'll see:

```
════════════════════════════════════════════════════════════════════
  🏰 AGENT X - ONE-COMMAND WEB INTERFACE LAUNCHER
════════════════════════════════════════════════════════════════════

[STEP] Checking operating system...
✅ Running on Linux/WSL
[STEP] Checking Python installation...
✅ Python 3.12.3 found
[STEP] Checking Ollama installation...
✅ Ollama found at: /usr/local/bin/ollama
...
[STEP] Opening browser...
✅ Browser opened (Windows)
```

Then your browser opens to http://localhost:8080 and you're ready to chat!

---

**Remember:** The key is to be in the repository directory when you run the script!
