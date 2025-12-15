#!/usr/bin/env python3
"""
AGENT X - SPEECH-TO-SPEECH (PRODUCTION VERSION)
Multi-engine TTS with automatic fallback
Optimized for WSL2 fortress environment
"""

import subprocess
import os
import json
import sys
import tempfile
import time
from pathlib import Path

# Colors
BLUE = '\033[94m'
CYAN = '\033[96m'
RED = '\033[91m'
GREEN = '\033[92m'
YELLOW = '\033[93m'
RESET = '\033[0m'

# Base directory
BASE_DIR = Path.home() / "fortress-ai"

# Load TTS config
try:
    with open(BASE_DIR / 'tts_config.json') as f:
        config = json.load(f)
except FileNotFoundError:
    print(f"{YELLOW}⚠️  tts_config.json not found, using defaults{RESET}")
    config = {
        "engine": "pyttsx3",
        "pyttsx3": {"rate": 150, "volume": 1.0},
        "piper": {
            "binary": "bin/piper",
            "model": "voices/en_US-lessac-medium.onnx"
        },
        "coqui": {
            "model": "tts_models/multilingual/multi-dataset/xtts_v2",
            "voice_sample": "voices/my_voice.wav"
        }
    }

# TTS engine instances (lazy loading)
_pyttsx3_engine = None
_coqui_engine = None
_whisper_model = None

def speak_pyttsx3(text):
    """Fast offline TTS (robot voice)"""
    global _pyttsx3_engine
    try:
        import pyttsx3
        if _pyttsx3_engine is None:
            _pyttsx3_engine = pyttsx3.init()
            _pyttsx3_engine.setProperty('rate', config.get('pyttsx3', {}).get('rate', 150))
            _pyttsx3_engine.setProperty('volume', config.get('pyttsx3', {}).get('volume', 1.0))
        
        _pyttsx3_engine.say(text)
        _pyttsx3_engine.runAndWait()
        return True
        
    except Exception as e:
        print(f"{RED}⚠️  pyttsx3 Error: {e}{RESET}")
        return False

def speak_coqui(text):
    """Hyper-realistic TTS with voice cloning"""
    global _coqui_engine
    try:
        from TTS.api import TTS
        
        # Initialize engine (cached)
        if _coqui_engine is None:
            print(f"{YELLOW}Loading Coqui model (first time only)...{RESET}")
            model_name = config.get('coqui', {}).get('model', 'tts_models/multilingual/multi-dataset/xtts_v2')
            _coqui_engine = TTS(model_name)
        
        # Generate speech
        temp_wav = tempfile.mktemp(suffix='.wav')
        
        voice_sample = config.get('coqui', {}).get('voice_sample', None)
        if voice_sample:
            voice_sample_path = BASE_DIR / voice_sample
            if voice_sample_path.exists():
                # Voice cloning mode
                _coqui_engine.tts_to_file(
                    text=text,
                    speaker_wav=str(voice_sample_path),
                    language="en",
                    file_path=temp_wav
                )
            else:
                # Default voice
                _coqui_engine.tts_to_file(
                    text=text,
                    language="en",
                    file_path=temp_wav
                )
        else:
            _coqui_engine.tts_to_file(
                text=text,
                language="en",
                file_path=temp_wav
            )
        
        # Play audio
        subprocess.run(['aplay', '-q', temp_wav], 
                      timeout=30,
                      check=False)
        os.remove(temp_wav)
        return True
        
    except Exception as e:
        print(f"{RED}⚠️  Coqui Error: {e}{RESET}")
        return False

def speak_piper(text):
    """Fast natural TTS using Piper"""
    try:
        piper_bin = BASE_DIR / config.get('piper', {}).get('binary', 'bin/piper')
        piper_model = BASE_DIR / config.get('piper', {}).get('model', 'voices/en_US-lessac-medium.onnx')
        
        if not piper_bin.exists():
            raise FileNotFoundError(f"Piper binary not found: {piper_bin}")
        
        if not piper_model.exists():
            raise FileNotFoundError(f"Piper model not found: {piper_model}")
        
        # Generate speech
        temp_wav = tempfile.mktemp(suffix='.wav')
        
        process = subprocess.run(
            [str(piper_bin), '--model', str(piper_model), '--output_file', temp_wav],
            input=text.encode('utf-8'),
            capture_output=True,
            timeout=30
        )
        
        if process.returncode != 0:
            raise Exception(f"Piper failed: {process.stderr.decode()}")
        
        # Play audio
        subprocess.run(['aplay', '-q', temp_wav], 
                      timeout=30,
                      check=False)
        os.remove(temp_wav)
        return True
        
    except Exception as e:
        print(f"{RED}⚠️  Piper Error: {e}{RESET}")
        return False

def speak(text):
    """Universal TTS with automatic fallback"""
    start_time = time.time()
    engine = config.get('engine', 'pyttsx3')
    
    # Try primary engine
    success = False
    if engine == 'coqui':
        success = speak_coqui(text)
    elif engine == 'piper':
        success = speak_piper(text)
    elif engine == 'pyttsx3':
        success = speak_pyttsx3(text)
    
    if success:
        elapsed = time.time() - start_time
        print(f"{GREEN}🔊 TTS: {elapsed:.2f}s{RESET}")
        return
    
    # Fallback chain
    print(f"{YELLOW}Primary engine failed, trying fallbacks...{RESET}")
    
    if engine != 'pyttsx3' and speak_pyttsx3(text):
        return
    
    if engine != 'piper' and speak_piper(text):
        return
    
    if engine != 'coqui' and speak_coqui(text):
        return
    
    print(f"{RED}❌ All TTS engines failed{RESET}")

def listen():
    """Get voice input (STT)"""
    global _whisper_model
    try:
        import sounddevice as sd
        from scipy.io.wavfile import write
        import whisper
        import numpy as np
        
        print(f"\n{CYAN}🎤 Listening...{RESET} (speak now)")
        
        # Record 5 seconds
        fs = 16000
        duration = 5
        recording = sd.rec(int(duration * fs), samplerate=fs, channels=1, dtype='float32')
        sd.wait()
        
        # Check for silence (voice activity detection)
        energy = np.sqrt(np.mean(recording**2))
        if energy < 0.01:
            print(f"{YELLOW}⚠️  No speech detected{RESET}")
            return ""
        
        # Save and transcribe
        temp_file = tempfile.mktemp(suffix='.wav')
        write(temp_file, fs, (recording * 32767).astype(np.int16))
        
        print(f"{CYAN}🤖 Processing...{RESET}")
        
        # Load Whisper model (cached)
        if _whisper_model is None:
            _whisper_model = whisper.load_model("base")
        
        result = _whisper_model.transcribe(temp_file, fp16=False)
        
        os.remove(temp_file)
        return result['text'].strip()
        
    except Exception as e:
        print(f"{RED}⚠️  STT Error: {e}{RESET}")
        # Fallback to text input
        return input(f"{BLUE}You (type):{RESET} ").strip()

def ask_ollama(question):
    """Query Qwen via Ollama"""
    try:
        import ollama
        
        start_time = time.time()
        response = ollama.chat(
            model='qwen2.5:7b-instruct-q4_K_M',
            messages=[
                {'role': 'system', 'content': 'You are Agent X, a tactical AI assistant investigating the Longo case. Be concise and direct. Keep responses under 100 words for voice interface.'},
                {'role': 'user', 'content': question}
            ]
        )
        elapsed = time.time() - start_time
        print(f"{GREEN}⚡ LLM: {elapsed:.2f}s{RESET}")
        
        return response['message']['content']
        
    except ImportError:
        # Fallback to subprocess
        ollama_path = BASE_DIR / "bin" / "ollama"
        if not ollama_path.exists():
            return "Error: Ollama not found. Please install Ollama."
        
        try:
            result = subprocess.run(
                [str(ollama_path), "run", "qwen2.5:7b-instruct-q4_K_M", question],
                capture_output=True,
                text=True,
                timeout=60
            )
            return result.stdout.strip()
        except Exception as e:
            return f"Error: {e}"
    
    except Exception as e:
        return f"Error querying Ollama: {e}"

def print_banner():
    print(f"\n{BLUE}{'='*70}{RESET}")
    print(f"{CYAN}  🎙️  AGENT X - SPEECH-TO-SPEECH MODE 🎙️{RESET}")
    print(f"{BLUE}{'='*70}{RESET}\n")
    print(f"{GREEN}TTS Engine: {config.get('engine', 'pyttsx3').upper()}{RESET}")
    print(f"{GREEN}Base Dir: {BASE_DIR}{RESET}")
    print(f"{YELLOW}Commands: 'exit', 'quit', 'stop' to terminate{RESET}")
    print(f"{BLUE}{'='*70}{RESET}\n")

def main():
    """Main conversation loop"""
    print_banner()
    
    # Test TTS
    print(f"{CYAN}Testing voice output...{RESET}")
    speak("Agent X speech mode activated. I can now hear you and speak back.")
    print("")
    
    conversation_count = 0
    
    while True:
        try:
            # Get voice input
            user_input = listen()
            
            if not user_input or len(user_input) < 3:
                continue
            
            conversation_count += 1
            print(f"\n{BLUE}[Conversation {conversation_count}]{RESET}")
            print(f"{BLUE}YOU:{RESET} {user_input}\n")
            
            # Check for exit
            if any(word in user_input.lower() for word in ['exit', 'quit', 'stop', 'goodbye', 'shutdown']):
                speak("Agent X signing off. Operation complete.")
                print(f"\n{CYAN}👋 Agent X signing off.{RESET}\n")
                break
            
            # Get AI response
            print(f"{CYAN}🤖 Agent X is thinking...{RESET}")
            response = ask_ollama(user_input)
            
            # Print response
            print(f"\n{CYAN}AGENT X:{RESET}")
            print(f"{response}\n")
            print(f"{BLUE}{'-'*70}{RESET}\n")
            
            # Speak response
            speak(response)
            
        except KeyboardInterrupt:
            speak("Agent X signing off.")
            print(f"\n\n{CYAN}👋 Session terminated by user (Ctrl+C){RESET}\n")
            break
        except Exception as e:
            print(f"{RED}⚠️  Error: {e}{RESET}")
            import traceback
            traceback.print_exc()
            print()

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"\n{RED}💥 Fatal error: {e}{RESET}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
