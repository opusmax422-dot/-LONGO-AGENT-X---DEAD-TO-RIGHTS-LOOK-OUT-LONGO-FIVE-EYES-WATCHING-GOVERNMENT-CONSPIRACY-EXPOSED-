#!/usr/bin/env python3
"""
Agent X Terminal - Optimized Voice Interface
Supports: Piper TTS (fast), Coqui XTTS (realistic), pyttsx3 (fallback)
Target: <1.5s TTS latency, <2s total reaction time
"""

import json
import os
import sys
import time
import subprocess
from pathlib import Path
import numpy as np
import sounddevice as sd
from scipy.io.wavfile import write
import warnings
warnings.filterwarnings("ignore")

# Config with defaults
CONFIG_PATH = Path.home() / "fortress-ai" / "tts_config.json"

DEFAULT_CONFIG = {
    "engine": "piper",
    "pyttsx3": {"rate": 150, "volume": 1.0},
    "coqui": {
        "model": "tts_models/multilingual/multi-dataset/xtts_v2",
        "voice_sample": "voices/my_voice.wav"
    },
    "piper": {
        "model": "voices/en_US-lessac-medium.onnx",
        "binary": "bin/piper"
    }
}

# Load or create config
if CONFIG_PATH.exists():
    with open(CONFIG_PATH) as f:
        config = json.load(f)
else:
    print(f"⚠️  Config not found, using defaults")
    config = DEFAULT_CONFIG

# Lazy model loading
whisper_model = None
tts_engine = None
ollama_available = False


def init_models():
    """Initialize models on first use."""
    global whisper_model, tts_engine, ollama_available
    
    # Whisper STT
    if whisper_model is None:
        try:
            import whisper
            print("Loading Whisper model...")
            whisper_model = whisper.load_model("base")
            print("✅ Whisper loaded")
        except Exception as e:
            print(f"❌ Whisper failed: {e}")
            sys.exit(1)
    
    # Ollama check
    try:
        import ollama
        ollama.list()
        ollama_available = True
        print("✅ Ollama connected")
    except Exception as e:
        print(f"⚠️  Ollama not available: {e}")
        ollama_available = False
    
    # TTS Engine
    if tts_engine is None:
        engine_type = config.get('engine', 'piper')
        print(f"Loading TTS engine: {engine_type}")
        
        if engine_type == 'piper':
            # Piper uses subprocess - no loading needed
            piper_model = Path.home() / "fortress-ai" / config['piper']['model']
            piper_binary = Path.home() / "fortress-ai" / config['piper']['binary']
            if not piper_model.exists():
                print(f"❌ Piper model not found: {piper_model}")
                print("Run install script first!")
                sys.exit(1)
            print(f"✅ Piper ready: {piper_model.name}")
        
        elif engine_type == 'coqui':
            try:
                from TTS.api import TTS
                tts_engine = TTS(config['coqui']['model'], gpu=False)
                print(f"✅ Coqui loaded: {config['coqui']['model']}")
            except Exception as e:
                print(f"❌ Coqui failed: {e}")
                print("Falling back to pyttsx3...")
                config['engine'] = 'pyttsx3'
        
        elif engine_type == 'pyttsx3':
            try:
                import pyttsx3
                tts_engine = pyttsx3.init()
                tts_engine.setProperty('rate', config['pyttsx3']['rate'])
                tts_engine.setProperty('volume', config['pyttsx3']['volume'])
                print("✅ pyttsx3 loaded")
            except Exception as e:
                print(f"❌ pyttsx3 failed: {e}")
                sys.exit(1)


def listen_and_transcribe(duration=5, sample_rate=16000):
    """Capture audio and transcribe with Whisper."""
    print("\n🎤 Listening... (speak now)")
    
    audio = sd.rec(
        int(duration * sample_rate),
        samplerate=sample_rate,
        channels=1,
        dtype='float32'
    )
    sd.wait()
    
    # Voice activity detection (simple energy threshold)
    energy = np.sqrt(np.mean(audio**2))
    if energy < 0.01:
        return ""  # Silent
    
    # Save and transcribe
    temp_path = "/tmp/fortress_audio.wav"
    write(temp_path, sample_rate, (audio * 32767).astype(np.int16))
    
    try:
        result = whisper_model.transcribe(temp_path, fp16=False)
        return result['text'].strip()
    except Exception as e:
        print(f"❌ Transcription error: {e}")
        return ""


def speak_streaming(text):
    """
    Streaming TTS with sentence-level chunking.
    Plays audio incrementally for low perceived latency.
    """
    if not text or len(text) < 2:
        return
    
    start_time = time.time()
    engine_type = config.get('engine', 'piper')
    
    # Split into sentences
    import re
    sentences = [s.strip() for s in re.split(r'(?<=[.!?])\s+', text) if s.strip()]
    
    first_audio_time = None
    
    # === PIPER (FASTEST) ===
    if engine_type == 'piper':
        piper_binary = Path.home() / "fortress-ai" / config['piper']['binary']
        piper_model = Path.home() / "fortress-ai" / config['piper']['model']
        
        for sentence in sentences:
            try:
                # Generate WAV to stdout
                result = subprocess.run(
                    [str(piper_binary), '--model', str(piper_model), '--output_file', '/tmp/piper_chunk.wav'],
                    input=sentence.encode(),
                    capture_output=True,
                    check=True
                )
                
                if first_audio_time is None:
                    first_audio_time = time.time() - start_time
                    print(f"⚡ First audio: {first_audio_time:.2f}s")
                
                # Play immediately
                if Path('/tmp/piper_chunk.wav').exists():
                    subprocess.run(['aplay', '-q', '/tmp/piper_chunk.wav'], check=False)
                
            except Exception as e:
                print(f"⚠️  Piper chunk error: {e}")
    
    # === COQUI (HIGH QUALITY) ===
    elif engine_type == 'coqui':
        for sentence in sentences:
            try:
                voice_sample = Path.home() / "fortress-ai" / config['coqui']['voice_sample']
                
                wav = tts_engine.tts(
                    text=sentence,
                    speaker_wav=str(voice_sample) if voice_sample.exists() else None,
                    language='en'
                )
                
                if first_audio_time is None:
                    first_audio_time = time.time() - start_time
                    print(f"⚡ First audio: {first_audio_time:.2f}s")
                
                # Play with sounddevice
                sd.play(np.array(wav), samplerate=22050)
                sd.wait()
                
            except Exception as e:
                print(f"⚠️  Coqui chunk error: {e}")
    
    # === PYTTSX3 (FALLBACK) ===
    elif engine_type == 'pyttsx3':
        try:
            tts_engine.say(text)
            tts_engine.runAndWait()
            first_audio_time = time.time() - start_time
            print(f"⚡ Audio time: {first_audio_time:.2f}s")
        except Exception as e:
            print(f"⚠️  pyttsx3 error: {e}")
    
    total_time = time.time() - start_time
    print(f"🔊 Total TTS: {total_time:.2f}s")


def query_ollama(user_input):
    """Query Ollama LLM with error handling."""
    if not ollama_available:
        return "Ollama is not available. Please start Ollama service."
    
    try:
        import ollama
        response = ollama.chat(
            model='qwen2.5:7b-instruct-q4_K_M',
            messages=[
                {'role': 'system', 'content': 'You are Agent X, a tactical AI assistant investigating the Longo case. Be concise and direct. Keep responses under 50 words for voice interface.'},
                {'role': 'user', 'content': user_input}
            ]
        )
        return response['message']['content']
    except Exception as e:
        print(f"❌ Ollama error: {e}")
        return f"Query error: {str(e)}"


def main():
    """Main voice interaction loop."""
    print("=" * 70)
    print("🎯 AGENT X TERMINAL - Voice Interface Active")
    print("=" * 70)
    print(f"TTS Engine: {config.get('engine', 'unknown').upper()}")
    print("Commands: 'exit', 'quit', 'stop' to terminate")
    print("=" * 70)
    print()
    
    # Initialize all models
    init_models()
    
    conversation_count = 0
    
    while True:
        try:
            # Listen
            user_input = listen_and_transcribe()
            
            if not user_input or len(user_input) < 3:
                print("⚠️  No speech detected or too short")
                continue
            
            # Exit commands
            if user_input.lower() in ['exit', 'quit', 'stop', 'shutdown']:
                print("\n👋 Shutting down Agent X...")
                speak_streaming("Shutting down. Goodbye.")
                break
            
            conversation_count += 1
            print(f"\n[Conversation {conversation_count}]")
            print(f"👤 YOU: {user_input}")
            
            # Query LLM
            query_start = time.time()
            agent_response = query_ollama(user_input)
            query_time = time.time() - query_start
            
            print(f"🤖 AGENT X: {agent_response}")
            print(f"⏱️  LLM: {query_time:.2f}s")
            
            # Speak response
            speak_streaming(agent_response)
            
            print("-" * 70)
            
        except KeyboardInterrupt:
            print("\n\n👋 Session terminated by user (Ctrl+C)")
            break
        except Exception as e:
            print(f"\n❌ Unexpected error: {e}")
            import traceback
            traceback.print_exc()
            print("\nContinuing...\n")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"\n💥 Fatal error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
