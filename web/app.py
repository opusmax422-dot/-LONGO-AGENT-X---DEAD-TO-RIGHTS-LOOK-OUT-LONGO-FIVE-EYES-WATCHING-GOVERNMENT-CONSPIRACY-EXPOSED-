#!/usr/bin/env python3
"""
AGENT X - Autonomous AI Interface
Flask backend for Fortress AI web interface
100% localhost/offline compatible
NOW WITH RAG DOCUMENT SEARCH
"""

from flask import Flask, render_template, request, jsonify
import subprocess
import os
import json
from datetime import datetime
from pathlib import Path
from werkzeug.utils import secure_filename

app = Flask(__name__)

# Configuration
FORTRESS_DIR = Path.home() / "fortress-ai"
# Check for Ollama binary - prefer environment variable, then system PATH, then local install
if os.environ.get("OLLAMA_BIN"):
    OLLAMA_BIN = Path(os.environ.get("OLLAMA_BIN"))
elif os.system("which ollama > /dev/null 2>&1") == 0:
    import subprocess
    result = subprocess.run(["which", "ollama"], capture_output=True, text=True)
    OLLAMA_BIN = Path(result.stdout.strip())
else:
    OLLAMA_BIN = FORTRESS_DIR / "bin" / "ollama"

CONVERSATION_DIR = FORTRESS_DIR / "logs" / "conversations"
EVIDENCE_DIR = FORTRESS_DIR / "evidence"
UPLOAD_DIR = EVIDENCE_DIR / "uploads"
VECTOR_DB_DIR = FORTRESS_DIR / "vector_db"
MODEL_NAME = "qwen2.5:7b-instruct-q4_K_M"
ALLOWED_EXTENSIONS = {'pdf', 'txt', 'md', 'html', 'mhtml', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'zip'}
MAX_FILE_SIZE = 50 * 1024 * 1024  # 50MB in bytes

# Ensure directories exist
CONVERSATION_DIR.mkdir(parents=True, exist_ok=True)
EVIDENCE_DIR.mkdir(parents=True, exist_ok=True)
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

# Current conversation storage
current_conversation = []

# RAG System
rag_system = None

def init_rag_system():
    """Initialize RAG system (lazy loading)"""
    global rag_system
    if rag_system is None:
        try:
            from langchain_community.vectorstores import FAISS
            from langchain_community.embeddings import HuggingFaceEmbeddings
            
            # Check if vector DB exists
            if VECTOR_DB_DIR.exists() and (VECTOR_DB_DIR / "index.faiss").exists():
                embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
                rag_system = FAISS.load_local(
                    str(VECTOR_DB_DIR),
                    embeddings,
                    allow_dangerous_deserialization=True
                )
                print("✅ RAG system loaded")
                return True
            else:
                print("⚠️  No vector database found")
                return False
        except ImportError:
            print("⚠️  RAG dependencies not installed (langchain, faiss-cpu)")
            return False
        except Exception as e:
            print(f"⚠️  RAG system error: {e}")
            return False
    return True


def check_ollama_running():
    """Check if Ollama server is running and responding"""
    try:
        # First check if process is running
        result = subprocess.run(
            ["pgrep", "-f", "ollama"],
            capture_output=True,
            text=True,
            timeout=2
        )
        if result.returncode != 0:
            return False
        
        # Also verify API is responding
        try:
            import requests
            response = requests.get("http://127.0.0.1:11434/api/tags", timeout=2)
            return response.status_code == 200
        except:
            # Process is running but API not ready yet
            return True
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


def query_ollama(prompt, use_rag=True):
    """Query Ollama with optional RAG enhancement"""
    try:
        # Check if Ollama is running
        if not check_ollama_running():
            return "Error: Ollama server is not running. Please start it with: ollama serve"
        
        # RAG Enhancement
        context = ""
        sources = []
        if use_rag and init_rag_system() and rag_system is not None:
            try:
                # Search for relevant documents
                docs = rag_system.similarity_search(prompt, k=3)
                if docs:
                    context_parts = []
                    for i, doc in enumerate(docs, 1):
                        context_parts.append(f"[Source {i}: {doc.metadata.get('source', 'Unknown')}]\n{doc.page_content}")
                        sources.append(doc.metadata.get('source', 'Unknown'))
                    
                    context = "\n\n---\n\n".join(context_parts)
                    
                    # Enhance prompt with context
                    prompt = f"""You are a legal AI assistant with access to evidence documents.

EVIDENCE CONTEXT:
{context}

---

USER QUESTION:
{prompt}

---

INSTRUCTIONS:
- Use the evidence context above to answer the question
- Cite specific sources when referencing information (e.g., "According to Source 1...")
- If the evidence doesn't contain relevant information, say so and provide general legal knowledge
- Be precise and professional
- Format your response clearly with bullet points where appropriate"""
            except Exception as e:
                print(f"RAG search error: {e}")
        
        # Query Ollama
        result = subprocess.run(
            [str(OLLAMA_BIN), "run", MODEL_NAME, prompt],
            capture_output=True,
            text=True,
            timeout=90  # Increased timeout for RAG queries
        )
        
        if result.returncode == 0:
            response = result.stdout.strip()
            if sources:
                # Append sources to response
                response += f"\n\n---\n📚 **Sources**: {', '.join(set(sources))}"
            return response
        else:
            return f"Error: {result.stderr.strip()}"
    
    except subprocess.TimeoutExpired:
        return "Error: AI response timed out (90 seconds). Try a shorter query."
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
    
    # Check RAG status
    rag_available = False
    document_count = 0
    if VECTOR_DB_DIR.exists():
        rag_available = (VECTOR_DB_DIR / "index.faiss").exists()
        if EVIDENCE_DIR.exists():
            document_count = len(list(EVIDENCE_DIR.glob("**/*.*")))
    
    return jsonify({
        "ollama_running": ollama_running,
        "ollama_exists": ollama_exists,
        "ollama_path": str(OLLAMA_BIN),
        "model": MODEL_NAME,
        "conversation_count": len(current_conversation) // 2,
        "rag_available": rag_available,
        "document_count": document_count
    })


@app.route("/api/history", methods=["GET"])
def api_history():
    """Return current conversation history"""
    return jsonify({
        "messages": current_conversation
    })


@app.route("/api/upload", methods=["POST"])
def api_upload():
    """Handle document upload and ingestion"""
    if 'file' not in request.files:
        return jsonify({"success": False, "error": "No file provided"}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({"success": False, "error": "No file selected"}), 400
    
    # Check file extension
    if '.' not in file.filename:
        return jsonify({"success": False, "error": "Invalid file type - no extension found"}), 400
    
    ext = file.filename.rsplit('.', 1)[1].lower()
    if ext not in ALLOWED_EXTENSIONS:
        return jsonify({
            "success": False,
            "error": f"File type '.{ext}' not allowed. Allowed types: {', '.join(sorted(ALLOWED_EXTENSIONS))}"
        }), 400
    
    try:
        # Check file size
        file.seek(0, 2)  # Seek to end
        file_size = file.tell()
        file.seek(0)  # Reset to beginning
        
        if file_size > MAX_FILE_SIZE:
            size_mb = file_size / (1024 * 1024)
            return jsonify({
                "success": False,
                "error": f"File too large ({size_mb:.1f}MB). Maximum size: 50MB"
            }), 400
        
        # Save file to uploads directory
        filename = secure_filename(file.filename)
        filepath = UPLOAD_DIR / filename
        
        # Check if file already exists
        if filepath.exists():
            base, extension = filename.rsplit('.', 1)
            counter = 1
            while filepath.exists():
                filename = f"{base}_{counter}.{extension}"
                filepath = UPLOAD_DIR / filename
                counter += 1
        
        file.save(str(filepath))
        
        # Format file size for response
        if file_size < 1024:
            size_str = f"{file_size} B"
        elif file_size < 1024 * 1024:
            size_str = f"{file_size / 1024:.1f} KB"
        else:
            size_str = f"{file_size / (1024 * 1024):.1f} MB"
        
        # Trigger re-ingestion
        ingestion_success = ingest_documents()
        
        message = "✅ File uploaded and indexed for AI search" if ingestion_success else "✅ File uploaded (indexing may have failed)"
        
        return jsonify({
            "success": True,
            "filename": filename,
            "size": size_str,
            "message": message
        })
    except Exception as e:
        print(f"Upload error: {e}")
        return jsonify({
            "success": False,
            "error": f"Upload failed: {str(e)}"
        }), 500


@app.route("/api/documents", methods=["GET"])
def api_documents():
    """List all uploaded documents"""
    try:
        documents = []
        if EVIDENCE_DIR.exists():
            for filepath in EVIDENCE_DIR.glob("**/*.*"):
                if filepath.is_file():
                    documents.append({
                        "name": filepath.name,
                        "size": filepath.stat().st_size,
                        "modified": datetime.fromtimestamp(filepath.stat().st_mtime).isoformat()
                    })
        return jsonify({"documents": documents})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


def ingest_documents():
    """Ingest all documents in evidence directory into vector database"""
    try:
        import fitz  # PyMuPDF
        from langchain_community.vectorstores import FAISS
        from langchain_community.embeddings import HuggingFaceEmbeddings
        from langchain.text_splitter import RecursiveCharacterTextSplitter
        
        embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
        splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
        
        docs = []
        # Scan both evidence root and uploads subdirectory
        for search_dir in [EVIDENCE_DIR, UPLOAD_DIR]:
            if not search_dir.exists():
                continue
            for filepath in search_dir.glob("**/*.*"):
                if not filepath.is_file():
                    continue
                
                try:
                    text = None
                    ext = filepath.suffix.lower()
                    
                    if ext == '.pdf':
                        pdf = fitz.open(str(filepath))
                        text = '\n'.join(page.get_text() for page in pdf)
                        pdf.close()
                    elif ext in ['.txt', '.md']:
                        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                            text = f.read()
                    elif ext in ['.html', '.mhtml']:
                        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                            text = f.read()
                    # Skip image and zip files for now (no text extraction)
                    
                    if text and text.strip():
                        chunks = splitter.split_text(text)
                        for chunk in chunks:
                            docs.append({
                                "content": chunk,
                                "metadata": {"source": filepath.name, "path": str(filepath)}
                            })
                except Exception as e:
                    print(f"Error processing {filepath.name}: {e}")
        
        if docs:
            texts = [d["content"] for d in docs]
            metadatas = [d["metadata"] for d in docs]
            
            db = FAISS.from_texts(texts, embeddings, metadatas=metadatas)
            db.save_local(str(VECTOR_DB_DIR))
            
            # Reload RAG system
            global rag_system
            rag_system = None
            init_rag_system()
            
            print(f"✅ Indexed {len(docs)} document chunks from {len(list(EVIDENCE_DIR.glob('**/*.*')))} files")
            return True
        return False
    except Exception as e:
        print(f"Ingestion error: {e}")
        return False


if __name__ == "__main__":
    print("=" * 80)
    print("  🏰 AGENT X - FORTRESS AI INTERFACE")
    print("  🔍 NOW WITH RAG DOCUMENT SEARCH")
    print("=" * 80)
    print()
    print(f"Fortress Directory: {FORTRESS_DIR}")
    print(f"Ollama Binary: {OLLAMA_BIN}")
    print(f"Model: {MODEL_NAME}")
    print(f"Evidence Directory: {EVIDENCE_DIR}")
    print(f"Vector Database: {VECTOR_DB_DIR}")
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
    
    # Check RAG status
    if init_rag_system():
        doc_count = len(list(EVIDENCE_DIR.glob("**/*.*"))) if EVIDENCE_DIR.exists() else 0
        print(f"✅ RAG system loaded ({doc_count} documents indexed)")
    else:
        print("⚠️  RAG system not available - upload documents to enable")
    
    print()
    print("=" * 80)
    print("  🚀 Starting Agent X Web Interface")
    print("=" * 80)
    print()
    print("  Access at: http://localhost:8080")
    print("  Press Ctrl+C to stop")
    print()
    print("  Features:")
    print("  - Chat with AI (Qwen 2.5:7B)")
    print("  - Upload evidence documents (PDF, TXT, MD, HTML)")
    print("  - RAG-enhanced answers with source citations")
    print("  - 100% offline & private")
    print()
    print("=" * 80)
    
    # Run Flask app
    app.run(host="0.0.0.0", port=8080, debug=False)
