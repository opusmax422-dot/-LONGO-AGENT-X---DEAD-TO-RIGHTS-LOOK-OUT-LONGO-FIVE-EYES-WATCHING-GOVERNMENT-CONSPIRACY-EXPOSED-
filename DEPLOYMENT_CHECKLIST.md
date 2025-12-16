# 🚀 Agent X Fortress - Deployment Checklist

**Complete verification guide for Agent X Fortress deployment**

---

## 📋 Pre-Deployment Verification

### System Requirements Check

- [ ] **Operating System**: Ubuntu 20.04+ or WSL2 with Ubuntu
- [ ] **Python Version**: Python 3.8 or higher installed
- [ ] **Disk Space**: At least 100MB available
- [ ] **RAM**: Minimum 512MB available
- [ ] **Permissions**: User has write access to installation directory

#### Commands to verify:

```bash
# Check OS version
cat /etc/os-release

# Check Python version
python3 --version

# Check disk space
df -h .

# Check RAM
free -h

# Check write permissions
touch test.txt && rm test.txt && echo "Write access: OK" || echo "Write access: FAILED"
```

---

## 🔧 Installation Validation

### Step 1: Repository Clone

- [ ] Repository successfully cloned
- [ ] All files present in repository
- [ ] .git directory exists

```bash
# Verify repository
ls -la
# Should see: bin/, data/, config/, logs/, output/, etc.

# Check git status
git status
```

### Step 2: Installation Script Execution

- [ ] `install_agent_x.sh` is executable
- [ ] Installation script runs without errors
- [ ] All directories created successfully
- [ ] Permissions set correctly

```bash
# Make installation script executable
chmod +x install_agent_x.sh

# Run installation
./install_agent_x.sh

# Verify exit code (should be 0)
echo $?
```

### Step 3: Directory Structure Validation

- [ ] `bin/` directory exists with `agent_x_launcher.py`
- [ ] `data/charts/` exists with chart files
- [ ] `data/evidence/` exists
- [ ] `data/social/` exists
- [ ] `data/templates/` exists
- [ ] `config/` directory exists
- [ ] `logs/` directory exists
- [ ] `output/` directory exists

```bash
# Check all directories
for dir in bin data/charts data/evidence data/social data/templates config logs output; do
    if [ -d "$dir" ]; then
        echo "✓ $dir exists"
    else
        echo "✗ $dir MISSING"
    fi
done
```

### Step 4: File Permissions Check

- [ ] `agent_x_launcher.py` is executable
- [ ] `install_agent_x.sh` is executable
- [ ] Log directory is writable
- [ ] Output directory is writable

```bash
# Check executable permissions
ls -l bin/agent_x_launcher.py
ls -l install_agent_x.sh

# Test write access
touch logs/test.log && rm logs/test.log && echo "✓ logs/ writable" || echo "✗ logs/ not writable"
touch output/test.txt && rm output/test.txt && echo "✓ output/ writable" || echo "✗ output/ not writable"
```

---

## ✅ Critical Fixes Validation

### Fix #1: Offline Compatibility

- [ ] `lightweight-charts.standalone.production.js` exists in `data/charts/`
- [ ] File size is greater than 10KB (not just placeholder)
- [ ] `chart_template.html` references local file (not CDN)
- [ ] Chart loads in browser without internet

```bash
# Check library file
ls -lh data/charts/lightweight-charts.standalone.production.js

# Check if chart template references local file
grep "lightweight-charts.standalone.production.js" data/charts/chart_template.html

# Should NOT find unpkg.com CDN reference
grep -i "unpkg.com" data/charts/chart_template.html && echo "✗ CDN reference found!" || echo "✓ No CDN references"
```

### Fix #2: Method Reference Correctness

- [ ] Method is named `generate_motion_to_dismiss()` in code
- [ ] All calls use correct method name
- [ ] No references to incorrect method names

```bash
# Check method definition
grep -n "def generate_motion_to_dismiss" bin/agent_x_launcher.py

# Check for any incorrect calls (should find none)
grep -n "generate_motion(" bin/agent_x_launcher.py && echo "✗ Incorrect method call found!" || echo "✓ No incorrect calls"

# Verify correct calls exist
grep -n "generate_motion_to_dismiss(" bin/agent_x_launcher.py
```

### Fix #3: Robust Error Handling

- [ ] `safe_save_file()` function exists
- [ ] `safe_read_file()` function exists
- [ ] Functions include try/catch blocks
- [ ] Functions return (success, message) tuples
- [ ] Path validation implemented
- [ ] Permission checking implemented

```bash
# Check for safe_save_file function
grep -n "def safe_save_file" bin/agent_x_launcher.py

# Check for error handling
grep -n "try:" bin/agent_x_launcher.py | wc -l
grep -n "except" bin/agent_x_launcher.py | wc -l

# Verify logging is implemented
grep -n "logging\." bin/agent_x_launcher.py | wc -l
```

### Fix #4: Path Validation

- [ ] All file operations use path validation
- [ ] Directories created if they don't exist
- [ ] `os.path.exists()` checks before operations
- [ ] `os.makedirs()` used with `exist_ok=True`
- [ ] Permission checks before writes

```bash
# Check for path validation
grep -n "os.path.exists\|Path.*exists" bin/agent_x_launcher.py

# Check for directory creation
grep -n "makedirs\|mkdir" bin/agent_x_launcher.py

# Check for permission checks
grep -n "os.access\|W_OK" bin/agent_x_launcher.py
```

---

## 🧪 Functional Testing

### Test 1: Application Launch

- [ ] Application starts without errors
- [ ] Main menu displays correctly
- [ ] All menu options are visible
- [ ] Color formatting works

```bash
# Launch application (should not crash)
python3 bin/agent_x_launcher.py << EOF
7
EOF

# Check if it exited cleanly (exit code 0)
echo "Exit code: $?"
```

### Test 2: Form 7A Generation

- [ ] Menu option 1 accessible
- [ ] Can input case information
- [ ] Document generates successfully
- [ ] File saved to output directory
- [ ] File contains expected content
- [ ] No errors in generation process

```bash
# Test Form 7A generation
python3 bin/agent_x_launcher.py << EOF
1
TEST-001
FEDERAL COURT
Test Plaintiff
Test Defendant
This is a test fact

This is a test ground

Test relief sought
7
EOF

# Check if file was created
ls -lt output/Form_7A_* | head -1
```

### Test 3: Motion to Dismiss Generation

- [ ] Menu option 2 accessible
- [ ] Can input case information
- [ ] Document generates successfully
- [ ] File saved to output directory
- [ ] Method call works correctly (Fix #2 verified)

```bash
# Test Motion to Dismiss generation
python3 bin/agent_x_launcher.py << EOF
2
TEST-002
FEDERAL COURT
Test Plaintiff
Test Defendant
Ground 1

Argument 1

7
EOF

# Check if file was created
ls -lt output/Motion_to_Dismiss_* | head -1
```

### Test 4: Evidence Timeline Analysis

- [ ] Menu option 3 accessible
- [ ] Can input evidence text
- [ ] Dates are extracted correctly
- [ ] Timeline report generated
- [ ] File saved successfully

```bash
# Test timeline analysis
python3 bin/agent_x_launcher.py << EOF
3
On 2024-01-15 the incident occurred.
Another event on 2024-02-20.
END
7
EOF

# Check if timeline file was created
ls -lt output/Timeline_Analysis_* | head -1
```

### Test 5: Social Media Content Generation

- [ ] Menu option 4 accessible
- [ ] Can specify topic and platform
- [ ] Content generates successfully
- [ ] File saved to social directory

```bash
# Test social content generation
python3 bin/agent_x_launcher.py << EOF
4
Test Topic
twitter
7
EOF

# Check if social content was created
ls -lt data/social/twitter_content_* | head -1
```

### Test 6: Chart System

- [ ] Menu option 5 accessible
- [ ] Sample data can be loaded
- [ ] Chart template location displayed
- [ ] Chart file exists and is accessible

```bash
# Test chart system menu
python3 bin/agent_x_launcher.py << EOF
5
3
7
EOF

# Verify chart template exists
ls -lh data/charts/chart_template.html
```

### Test 7: System Information

- [ ] Menu option 6 accessible
- [ ] System info displays correctly
- [ ] All directories shown as existing
- [ ] All 4 fixes shown as complete

```bash
# Test system info
python3 bin/agent_x_launcher.py << EOF
6
7
EOF
```

---

## 📊 Chart System Testing

### Offline Chart Test

- [ ] Open `data/charts/chart_template.html` in browser
- [ ] Page loads without errors
- [ ] No console errors related to missing libraries
- [ ] "Load Sample Data" button works
- [ ] Sample data displays in chart
- [ ] Chart renders correctly

```bash
# For WSL, open chart in Windows browser
explorer.exe data/charts/chart_template.html

# Or copy path to manually open
realpath data/charts/chart_template.html
```

### Chart Data Validation Test

- [ ] Invalid JSON is rejected with error message
- [ ] Missing required fields detected
- [ ] OHLC data validates correctly
- [ ] Volume data is optional but processed when present

---

## 📝 Logging System Testing

### Log File Verification

- [ ] Log directory exists
- [ ] Log file created on first run
- [ ] Log file contains timestamped entries
- [ ] Log entries include severity levels
- [ ] Errors are logged with details

```bash
# Check log file
ls -lh logs/agent_x.log

# View recent log entries
tail -20 logs/agent_x.log

# Check for error logging
grep -i "error" logs/agent_x.log

# Check for info logging
grep -i "info" logs/agent_x.log
```

### Log Rotation Test

- [ ] Log rotation configuration present
- [ ] Max file size set to 10MB
- [ ] Backup count set to 5
- [ ] Old logs are rotated properly

```bash
# Check log rotation configuration
grep -A5 "RotatingFileHandler" bin/agent_x_launcher.py
```

---

## 🔒 Security Testing

### File Permission Test

- [ ] Application respects file permissions
- [ ] Read-only directories handled gracefully
- [ ] Permission errors logged properly
- [ ] User receives clear error messages

```bash
# Test read-only directory handling
mkdir -p /tmp/readonly_test
touch /tmp/readonly_test/test.txt
chmod 444 /tmp/readonly_test/test.txt

# Try to write (should fail gracefully)
python3 -c "
import sys
sys.path.insert(0, 'bin')
from agent_x_launcher import safe_save_file
success, msg = safe_save_file('test', 'test.txt', '/tmp/readonly_test')
print(f'Success: {success}')
print(f'Message: {msg}')
"

# Cleanup
rm -rf /tmp/readonly_test
```

### Input Sanitization Test

- [ ] Special characters in filenames handled
- [ ] Path traversal attempts blocked
- [ ] Invalid input rejected gracefully

---

## 🌐 Integration Testing

### Fortress Integration

- [ ] Existing fortress files still functional
- [ ] `agent_x_speech.py` works
- [ ] `agent_x_terminal.py` works
- [ ] `start-agent-x.sh` works
- [ ] Web interface still accessible
- [ ] Scripts directory intact

```bash
# Check existing fortress components
ls -l agent_x_speech.py
ls -l agent_x_terminal.py
ls -l start-agent-x.sh

# Verify web interface
ls -l web/app.py

# Check scripts
ls -l scripts/
```

---

## 📦 Package Completeness

### Core Files Check

- [ ] `bin/agent_x_launcher.py` - Main application
- [ ] `data/charts/chart_template.html` - Chart interface
- [ ] `data/charts/lightweight-charts.standalone.production.js` - Chart library
- [ ] `agent_x_connector.ps1` - PowerShell bridge
- [ ] `install_agent_x.sh` - Installation script
- [ ] `README_AGENT_X.md` - Main documentation
- [ ] `DEPLOYMENT_CHECKLIST.md` - This file
- [ ] `LICENSE` - License file
- [ ] `.gitignore` - Git configuration

```bash
# Check all core files
for file in bin/agent_x_launcher.py \
            data/charts/chart_template.html \
            data/charts/lightweight-charts.standalone.production.js \
            agent_x_connector.ps1 \
            install_agent_x.sh \
            README_AGENT_X.md \
            DEPLOYMENT_CHECKLIST.md \
            .gitignore; do
    if [ -f "$file" ]; then
        echo "✓ $file exists"
    else
        echo "✗ $file MISSING"
    fi
done
```

---

## 🎯 Final Verification

### Complete System Test

Run the complete test suite:

```bash
#!/bin/bash
echo "🚀 Agent X Fortress - Complete System Test"
echo "=========================================="

# 1. Directory structure
echo "📁 Checking directories..."
DIRS="bin data/charts data/evidence data/social data/templates config logs output"
for dir in $DIRS; do
    [ -d "$dir" ] && echo "  ✓ $dir" || echo "  ✗ $dir MISSING"
done

# 2. File permissions
echo ""
echo "🔐 Checking permissions..."
[ -x "bin/agent_x_launcher.py" ] && echo "  ✓ agent_x_launcher.py executable" || echo "  ✗ Not executable"
[ -x "install_agent_x.sh" ] && echo "  ✓ install_agent_x.sh executable" || echo "  ✗ Not executable"

# 3. Critical fixes
echo ""
echo "✅ Verifying critical fixes..."

# Fix #1: Offline compatibility
if [ -f "data/charts/lightweight-charts.standalone.production.js" ]; then
    echo "  ✓ Fix #1: Chart library is local"
else
    echo "  ✗ Fix #1: Chart library missing"
fi

# Fix #2: Method naming
if grep -q "def generate_motion_to_dismiss" bin/agent_x_launcher.py; then
    echo "  ✓ Fix #2: Correct method name"
else
    echo "  ✗ Fix #2: Method name incorrect"
fi

# Fix #3: Error handling
if grep -q "def safe_save_file" bin/agent_x_launcher.py; then
    echo "  ✓ Fix #3: Error handling implemented"
else
    echo "  ✗ Fix #3: Error handling missing"
fi

# Fix #4: Path validation
if grep -q "os.path.exists\|Path.*exists" bin/agent_x_launcher.py; then
    echo "  ✓ Fix #4: Path validation present"
else
    echo "  ✗ Fix #4: Path validation missing"
fi

# 4. Application launch test
echo ""
echo "🚀 Testing application launch..."
timeout 5 python3 bin/agent_x_launcher.py << EOF > /dev/null 2>&1
7
EOF

if [ $? -eq 0 ]; then
    echo "  ✓ Application launches successfully"
else
    echo "  ⚠ Application test timed out or failed (check logs)"
fi

# 5. Log file check
echo ""
echo "📝 Checking logs..."
if [ -f "logs/agent_x.log" ]; then
    echo "  ✓ Log file created"
    echo "  📊 Log entries: $(wc -l < logs/agent_x.log)"
else
    echo "  ℹ Log file not yet created (will be created on first run)"
fi

echo ""
echo "=========================================="
echo "✅ System test complete!"
echo ""
```

Save the above as `test_deployment.sh` and run:

```bash
chmod +x test_deployment.sh
./test_deployment.sh
```

---

## 📋 Deployment Sign-Off

### Pre-Production Checklist

- [ ] All system requirements verified
- [ ] Installation completed without errors
- [ ] All directories created and writable
- [ ] All 4 critical fixes validated
- [ ] All functional tests passed
- [ ] Chart system works offline
- [ ] Logging system operational
- [ ] Security tests passed
- [ ] Integration with fortress verified
- [ ] Documentation complete
- [ ] Test deployment script passes

### Production Readiness Criteria

✅ **Ready for Production** if ALL of the following are true:

1. ✅ All 4 critical fixes validated
2. ✅ Application launches without errors
3. ✅ All menu options functional
4. ✅ Documents generate correctly
5. ✅ Chart system loads offline
6. ✅ Logging system operational
7. ✅ Error handling robust
8. ✅ Path validation working
9. ✅ File operations safe
10. ✅ Integration tests passed

---

## 🔄 Post-Deployment

### Monitoring

Monitor these items after deployment:

- [ ] Check logs daily: `tail -f logs/agent_x.log`
- [ ] Monitor disk space: `df -h`
- [ ] Verify output directory permissions
- [ ] Check for error patterns in logs
- [ ] Validate generated documents

### Maintenance

Regular maintenance tasks:

- [ ] Review and archive old log files
- [ ] Clean up old output files
- [ ] Update TradingView library if needed
- [ ] Backup configuration files
- [ ] Update documentation

### Updates

When updating:

1. Backup current installation
2. Pull latest changes: `git pull`
3. Re-run installation script: `./install_agent_x.sh`
4. Re-run deployment checklist
5. Verify all fixes still present

---

## 📞 Support

If any checks fail:

1. Review error messages in logs
2. Check system requirements
3. Re-run installation script
4. Consult README_AGENT_X.md troubleshooting section
5. Create GitHub issue with:
   - Failed check details
   - Error messages
   - System information
   - Log file contents

---

**Deployment Checklist Version: 1.0.0**  
**Last Updated: 2025-01-20**

---

✅ **DEPLOYMENT COMPLETE** when all checks pass!
