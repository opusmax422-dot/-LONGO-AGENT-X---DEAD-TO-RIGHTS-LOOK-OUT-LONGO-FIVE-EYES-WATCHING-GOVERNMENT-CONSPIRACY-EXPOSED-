#!/usr/bin/env python3
"""
FORTRESS AI - Simple Text Chat Interface
Direct conversation with Qwen2.5 AI model
No audio requirements - pure text interaction
"""

import subprocess
import sys

print("""
============================================================
🤖 FORTRESS AI - TEXT CHAT MODE
============================================================
Connected to: Qwen2.5-7B AI Model
Mode: Text-only (no audio required)
Commands: Type 'exit', 'quit', or press Ctrl+C to stop
============================================================
""")

# Verify Ollama is running
result = subprocess.run("ollama list", shell=True, capture_output=True, text=True)
if result.returncode != 0:
    print("❌ Ollama is not running. Start it with: ollama serve")
    sys.exit(1)

if "qwen2.5" not in result.stdout:
    print("❌ Qwen2.5 model not found. Install it with:")
    print("   ollama pull qwen2.5:7b-instruct-q4_K_M")
    sys.exit(1)

print("✅ Connected to Ollama")
print("✅ Qwen2.5 model ready\n")
print("Type your question below:\n")

model = "qwen2.5:7b-instruct-q4_K_M"

while True:
    try:
        # Get user input
        user_input = input("\n👤 You: ").strip()
        
        if not user_input:
            continue
            
        # Check for exit commands
        if user_input.lower() in ['exit', 'quit', 'stop', 'bye']:
            print("\n👋 Goodbye! Fortress AI shutting down.\n")
            break
        
        # Query Ollama
        print("\n🤔 AI is thinking...\n")
        cmd = f'ollama run {model} "{user_input}"'
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=120)
        
        if result.returncode == 0:
            response = result.stdout.strip()
            print(f"🤖 AI: {response}\n")
        else:
            print(f"❌ Error: {result.stderr}\n")
            
    except KeyboardInterrupt:
        print("\n\n👋 Interrupted. Goodbye!\n")
        break
    except subprocess.TimeoutExpired:
        print("\n❌ Response timeout (>2 minutes). Try a shorter question.\n")
    except Exception as e:
        print(f"\n❌ Error: {e}\n")

print("="*60)
print("Session ended.")
print("="*60)
