#!/usr/bin/env python3
"""
AGENT X - Autonomous AI Interface
Flask backend for Fortress AI web interface
100% localhost/offline compatible
"""

from flask import Flask, render_template, request, jsonify
import subprocess
import os
import json
from datetime import datetime
from pathlib import Path

app = Flask(__name__)

# Configuration
FORTRESS_DIR = Path.home() / "fortress-ai"
OLLAMA_BIN = FORTRESS_DIR / "bin" / "ollama"
CONVERSATION_DIR = FORTRESS_DIR / "logs" / "conversations"
MODEL_NAME = "qwen2.5:7b-instruct-q4_K_M"

# Ensure conversation directory exists
CONVERSATION_DIR.mkdir(parents=True, exist_ok=True)

# Current conversation storage
current_conversation = []


def check_ollama_running():
    """Check if Ollama server is running"""
    try:
        result = subprocess.run(
            ["pgrep", "-f", "ollama"],
            capture_output=True,
            text=True,
            timeout=2
        )
        return result.returncode == 0
    except Exception:
        return False


def start_ollama():
    """Start Ollama server if not running"""
    if not check_ollama_running():
        try:
            # Start Ollama in background
            log_file = FORTRESS_DIR / "logs" / "ollama-server.log"
            with open(log_file, "a") as f:
                subprocess.Popen(
                    [str(OLLAMA_BIN), "serve"],
                    stdout=f,
                    stderr=f,
                    start_new_session=True
                )
            # Wait for startup
            import time
            time.sleep(3)
            return True
        except Exception as e:
            print(f"Failed to start Ollama: {e}")
            return False
    return True


def query_ollama(prompt):
    """Query Ollama and return response"""
    try:
        # Check if Ollama is running
        if not check_ollama_running():
            return "Error: Ollama server is not running. Please start it with: ollama serve"
        
        # Query Ollama
        result = subprocess.run(
            [str(OLLAMA_BIN), "run", MODEL_NAME, prompt],
            capture_output=True,
            text=True,
            timeout=60  # 60 second timeout
        )
        
        if result.returncode == 0:
            return result.stdout.strip()
        else:
            return f"Error: {result.stderr.strip()}"
    
    except subprocess.TimeoutExpired:
        return "Error: AI response timed out (60 seconds). Try a shorter query."
    except FileNotFoundError:
        return f"Error: Ollama not found at {OLLAMA_BIN}. Please check installation."
    except Exception as e:
        return f"Error: {str(e)}"


def save_conversation():
    """Save current conversation to file"""
    if not current_conversation:
        return
    
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    filename = CONVERSATION_DIR / f"conversation-{timestamp}.json"
    
    try:
        with open(filename, "w") as f:
            json.dump({
                "timestamp": datetime.now().isoformat(),
                "messages": current_conversation
            }, f, indent=2)
    except Exception as e:
        print(f"Failed to save conversation: {e}")


@app.route("/")
def index():
    """Serve main interface"""
    return render_template("index.html")


@app.route("/api/query", methods=["POST"])
def api_query():
    """Handle AI query requests"""
    data = request.json
    user_message = data.get("message", "").strip()
    
    if not user_message:
        return jsonify({"error": "Empty message"}), 400
    
    # Add user message to conversation
    current_conversation.append({
        "role": "user",
        "content": user_message,
        "timestamp": datetime.now().isoformat()
    })
    
    # Query AI
    ai_response = query_ollama(user_message)
    
    # Add AI response to conversation
    current_conversation.append({
        "role": "assistant",
        "content": ai_response,
        "timestamp": datetime.now().isoformat()
    })
    
    # Save conversation
    save_conversation()
    
    return jsonify({
        "response": ai_response,
        "timestamp": datetime.now().isoformat()
    })


@app.route("/api/clear", methods=["POST"])
def api_clear():
    """Clear current conversation"""
    global current_conversation
    
    # Save before clearing
    save_conversation()
    
    # Clear conversation
    current_conversation = []
    
    return jsonify({"status": "cleared"})


@app.route("/api/status", methods=["GET"])
def api_status():
    """Check system status"""
    ollama_running = check_ollama_running()
    ollama_exists = OLLAMA_BIN.exists()
    
    return jsonify({
        "ollama_running": ollama_running,
        "ollama_exists": ollama_exists,
        "ollama_path": str(OLLAMA_BIN),
        "model": MODEL_NAME,
        "conversation_count": len(current_conversation) // 2  # Divide by 2 (user + AI)
    })


@app.route("/api/history", methods=["GET"])
def api_history():
    """Return current conversation history"""
    return jsonify({
        "messages": current_conversation
    })


if __name__ == "__main__":
    print("=" * 80)
    print("  🏰 AGENT X - FORTRESS AI INTERFACE")
    print("=" * 80)
    print()
    print(f"Fortress Directory: {FORTRESS_DIR}")
    print(f"Ollama Binary: {OLLAMA_BIN}")
    print(f"Model: {MODEL_NAME}")
    print()
    
    # Check Ollama status
    if check_ollama_running():
        print("✅ Ollama server is running")
    else:
        print("⚠️  Ollama server not running - attempting to start...")
        if start_ollama():
            print("✅ Ollama server started")
        else:
            print("❌ Failed to start Ollama server")
            print("   Manual start: ollama serve")
    
    print()
    print("=" * 80)
    print("  🚀 Starting Agent X Web Interface")
    print("=" * 80)
    print()
    print("  Access at: http://localhost:8080")
    print("  Press Ctrl+C to stop")
    print()
    print("=" * 80)
    
    # Run Flask app
    app.run(host="0.0.0.0", port=8080, debug=False)
