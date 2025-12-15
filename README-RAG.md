# 🔍 AGENT X - RAG DOCUMENT SEARCH

**Version 2.0 - Now with Retrieval-Augmented Generation**

## What's New

Agent X now includes **RAG (Retrieval-Augmented Generation)** - AI-powered document search that lets you:

- 📁 Upload evidence files (PDF, TXT, MD, HTML, DOCX)
- 🔍 Automatically index documents with FAISS vector search
- 💬 Ask questions and get AI answers with source citations
- 📚 Search through hundreds of documents instantly
- 🔒 100% offline and private (all processing on your PC)

## Features

### Document Upload
- Drag and drop or click "Upload Document" button
- Supports: PDF, TXT, Markdown, HTML, MHTML, DOC, DOCX
- Automatic text extraction and indexing
- Real-time feedback on upload status

### Smart Search
- Semantic search (not just keyword matching)
- AI finds relevant content even with different wording
- Returns top 3 most relevant document chunks
- Includes source file citations

### Enhanced AI Responses
- AI receives document context with your question
- Cites specific sources in responses
- Combines document evidence with AI knowledge
- Professional legal analysis

## Quick Start

### 1. Install Dependencies

```bash
pip3 install langchain langchain-community faiss-cpu \
    sentence-transformers pymupdf
```

### 2. Start Agent X

```bash
cd ~/your-repo
bash start-agent-x.sh
```

### 3. Upload Documents

1. Click "📁 Upload Document" button
2. Select your evidence files
3. Wait for indexing confirmation
4. Start asking questions!

## How It Works

### Document Processing Pipeline

```
PDF/TXT File → Text Extraction → Chunking (1000 chars) 
→ Embeddings (all-MiniLM-L6-v2) → FAISS Vector Database
```

### Query Processing

```
Your Question → Vector Search → Top 3 Relevant Chunks 
→ AI (with context) → Answer + Citations
```

## File Locations

```
~/fortress-ai/
├── evidence/          # Your uploaded documents
├── vector_db/         # FAISS index files
│   ├── index.faiss    # Vector embeddings
│   └── index.pkl      # Metadata
└── logs/
    └── conversations/ # Saved chats
```

## Example Questions

After uploading your evidence files:

- "What date was the incident mentioned in witness_statement.txt?"
- "Summarize the key points from all legal documents"
- "Find any mentions of constitutional violations"
- "What evidence do I have regarding unlawful detention?"
- "Compare the witness statements"

## Technical Details

### Embedding Model
- **Model**: `all-MiniLM-L6-v2` (sentence-transformers)
- **Size**: 23MB (lightweight)
- **Performance**: Fast on CPU
- **Accuracy**: 384-dimensional embeddings

### Vector Database
- **Engine**: FAISS (Facebook AI Similarity Search)
- **Index Type**: FlatL2 (exact search)
- **Scalability**: Handles 1000+ documents easily
- **Storage**: ~10KB per document average

### Text Processing
- **Chunk Size**: 1000 characters
- **Overlap**: 200 characters (preserves context)
- **Splitter**: Recursive character splitter
- **Formats**: PDF (PyMuPDF), TXT, MD, HTML, DOCX

### AI Integration
- **Model**: Qwen 2.5:7B (local Ollama)
- **Context Window**: Up to 3 document chunks
- **Max Context**: ~3000 characters from documents
- **Timeout**: 90 seconds for RAG queries

## API Endpoints

### Upload Document
```bash
POST /api/upload
Content-Type: multipart/form-data

Response:
{
  "status": "success",
  "filename": "evidence.pdf",
  "message": "Document uploaded and indexed successfully"
}
```

### Query with RAG
```bash
POST /api/query
Content-Type: application/json
Body: {"message": "What's in the evidence?"}

Response:
{
  "response": "According to Source 1 (evidence.pdf)...",
  "timestamp": "2025-12-15T20:00:00"
}
```

### List Documents
```bash
GET /api/documents

Response:
{
  "documents": [
    {
      "name": "evidence.pdf",
      "size": 102400,
      "modified": "2025-12-15T19:30:00"
    }
  ]
}
```

### System Status
```bash
GET /api/status

Response:
{
  "ollama_running": true,
  "rag_available": true,
  "document_count": 5,
  "conversation_count": 3
}
```

## Performance

### Upload & Indexing
- **Small file** (< 1MB): 2-5 seconds
- **Medium file** (1-10MB): 10-30 seconds
- **Large file** (10-50MB): 30-90 seconds

### Query Speed
- **Without RAG**: 5-15 seconds
- **With RAG**: 10-25 seconds (includes document search)
- **Vector search**: < 1 second (very fast)

## Troubleshooting

### "RAG dependencies not installed"
```bash
pip3 install langchain langchain-community faiss-cpu sentence-transformers pymupdf
```

### "No vector database found"
- Upload at least one document
- Check `~/fortress-ai/vector_db/` exists
- Re-run ingestion if needed

### "Upload failed"
- Check file size (< 100MB recommended)
- Verify file format is supported
- Ensure disk space available

### Slow indexing
- Large PDFs take time to process
- CPU-only processing (no GPU needed)
- Wait for "Document uploaded" confirmation

## Future Enhancements

- [ ] Batch upload (multiple files at once)
- [ ] Document management UI (view, delete files)
- [ ] Advanced filters (date range, file type)
- [ ] Highlight relevant passages in source
- [ ] Export search results to PDF
- [ ] GPU acceleration option
- [ ] Multi-language support
- [ ] OCR for scanned documents

## Security & Privacy

- ✅ All processing happens locally
- ✅ No data sent to cloud
- ✅ Documents stored on your PC only
- ✅ Vector embeddings stay local
- ✅ No internet required after setup
- ✅ Full control over your data

## Credits

**RAG Implementation**: Based on LangChain + FAISS  
**Embedding Model**: sentence-transformers/all-MiniLM-L6-v2  
**Vector Search**: Facebook AI Similarity Search (FAISS)  
**PDF Processing**: PyMuPDF  
**AI Model**: Qwen 2.5:7B via Ollama  

## Support

For issues or questions:
- Check Agent X logs: `~/fortress-ai/logs/`
- Review Flask output in terminal
- Test with sample documents first
- Verify all dependencies installed

---

**Agent X 2.0** - Your private, offline, RAG-powered legal AI assistant

*Built for Francesco Longo's civil rights case*  
*Fortress AI - Dead to Rights Evidence System*
