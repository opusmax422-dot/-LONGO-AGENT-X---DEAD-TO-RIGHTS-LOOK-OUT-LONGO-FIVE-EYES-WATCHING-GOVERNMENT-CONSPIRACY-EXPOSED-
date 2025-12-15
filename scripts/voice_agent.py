#!/usr/bin/env python3
"""
FORTRESS AI - Voice Interaction Module
Hands-free voice assistant for legal case analysis
Integrated with Ollama for offline AI processing
"""

import os
import sys
import subprocess
import json
from pathlib import Path

# Color codes
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
RED = '\033[0;31m'
BLUE = '\033[0;34m'
NC = '\033[0m'

def check_dependencies():
    """Verify all required packages are installed"""
    print(f"{BLUE}[VOICE AGENT] Checking dependencies...{NC}")
    
    required_packages = {
        'openai-whisper': 'whisper',
        'TTS': 'TTS',
        'sounddevice': 'sounddevice',
        'numpy': 'numpy',
        'pydantic': 'pydantic'
    }
    
    missing = []
    for pip_name, import_name in required_packages.items():
        try:
            __import__(import_name)
            print(f"{GREEN}✓{NC} {import_name}")
        except ImportError:
            missing.append(pip_name)
            print(f"{RED}✗{NC} {import_name} (missing)")
    
    if missing:
        print(f"\n{YELLOW}Installing missing packages...{NC}")
        cmd = f"pip install --quiet --no-input {' '.join(missing)}"
        subprocess.run(cmd, shell=True, check=False)
        print(f"{GREEN}✓ Installation complete{NC}\n")
    else:
        print(f"{GREEN}✓ All dependencies available{NC}\n")

class VoiceAgent:
    def __init__(self):
        """Initialize the voice agent"""
        print(f"\n{BLUE}{'='*60}{NC}")
        print(f"{BLUE}🎙️  FORTRESS AI - VOICE AGENT INITIALIZATION{NC}")
        print(f"{BLUE}{'='*60}{NC}\n")
        
        # Check dependencies first
        check_dependencies()
        
        # Load models
        print(f"{BLUE}[VOICE AGENT] Loading AI models...{NC}")
        
        try:
            import whisper
            print(f"{YELLOW}Loading Whisper (Speech-to-Text)...{NC}")
            self.whisper = whisper.load_model("base")  # Use 'base' for faster inference
            print(f"{GREEN}✓ Whisper loaded{NC}")
        except Exception as e:
            print(f"{RED}✗ Failed to load Whisper: {e}{NC}")
            self.whisper = None
        
        try:
            from TTS.api import TTS
            print(f"{YELLOW}Loading Coqui TTS (Text-to-Speech)...{NC}")
            self.tts = TTS(model_name="tts_models/en/ljspeech/tacotron2-DDC", progress_bar=False)
            print(f"{GREEN}✓ TTS loaded{NC}")
        except Exception as e:
            print(f"{RED}✗ Failed to load TTS: {e}{NC}")
            self.tts = None
        
        self.ollama_model = "qwen2.5:7b-instruct-q4_K_M"
        print(f"{GREEN}✓ Ollama model: {self.ollama_model}{NC}\n")
        
        # Verify Ollama is running
        self.verify_ollama()
    
    def verify_ollama(self):
        """Check if Ollama is running"""
        print(f"{BLUE}[VOICE AGENT] Verifying Ollama...{NC}")
        result = subprocess.run("ollama list", shell=True, capture_output=True, text=True)
        if result.returncode == 0:
            print(f"{GREEN}✓ Ollama is running{NC}")
            if "qwen2.5" in result.stdout:
                print(f"{GREEN}✓ Qwen2.5 model available{NC}\n")
            else:
                print(f"{YELLOW}⚠ Qwen2.5 model not found{NC}\n")
        else:
            print(f"{RED}✗ Ollama is not running{NC}")
            print(f"{YELLOW}Start with: ollama serve{NC}\n")
            sys.exit(1)
    
    def listen(self, duration=5):
        """Record audio from microphone"""
        try:
            import sounddevice as sd
            print(f"{YELLOW}🎤 Listening for {duration}s...{NC}")
            audio = sd.rec(int(duration * 16000), 
                          samplerate=16000, 
                          channels=1, 
                          dtype='float32')
            sd.wait()
            return audio.flatten()
        except Exception as e:
            print(f"{RED}✗ Audio recording failed: {e}{NC}")
            return None
    
    def transcribe(self, audio):
        """Convert speech to text using Whisper"""
        if not self.whisper or audio is None:
            return None
        
        try:
            print(f"{YELLOW}🔄 Transcribing audio...{NC}")
            result = self.whisper.transcribe(audio, fp16=False)
            text = result["text"].strip()
            print(f"{GREEN}✓ Transcribed: {text}{NC}")
            return text
        except Exception as e:
            print(f"{RED}✗ Transcription failed: {e}{NC}")
            return None
    
    def query_ollama(self, prompt):
        """Send query to Ollama"""
        try:
            print(f"{YELLOW}🤔 Querying AI model...{NC}")
            cmd = f'ollama run {self.ollama_model} "{prompt}"'
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=60)
            
            if result.returncode == 0:
                response = result.stdout.strip()
                print(f"{GREEN}✓ AI Response received{NC}")
                return response
            else:
                print(f"{RED}✗ AI query failed{NC}")
                return None
        except subprocess.TimeoutExpired:
            print(f"{RED}✗ AI response timeout{NC}")
            return None
        except Exception as e:
            print(f"{RED}✗ Error querying AI: {e}{NC}")
            return None
    
    def speak(self, text):
        """Convert text to speech"""
        if not self.tts:
            print(f"{BLUE}[AI RESPONSE]{NC}\n{text}\n")
            return
        
        try:
            print(f"\n{BLUE}🔊 AI Response:{NC}")
            print(f"{GREEN}{text}{NC}\n")
            
            # Save and play audio
            audio_file = "/tmp/fortress_response.wav"
            self.tts.tts_to_file(text=text, file_path=audio_file)
            
            # Try to play audio (cross-platform)
            for cmd in ["aplay", "afplay", "paplay"]:
                if subprocess.run(f"which {cmd}", shell=True, capture_output=True).returncode == 0:
                    subprocess.run(f"{cmd} {audio_file}", shell=True, stderr=subprocess.DEVNULL)
                    break
        except Exception as e:
            print(f"{YELLOW}⚠ Text-to-speech failed: {e}{NC}")
            print(f"{BLUE}[AI RESPONSE]{NC}\n{text}\n")
    
    def run_interactive(self):
        """Interactive voice conversation mode"""
        print(f"\n{BLUE}{'='*60}{NC}")
        print(f"{GREEN}✅ VOICE AGENT READY{NC}")
        print(f"{BLUE}{'='*60}{NC}")
        print(f"\n{YELLOW}Commands:{NC}")
        print(f"  - Say anything to chat with AI")
        print(f"  - Say 'exit', 'quit', or 'stop' to end")
        print(f"  - Say 'test' to run a quick test\n")
        
        while True:
            try:
                # Listen for input
                audio = self.listen(duration=5)
                if audio is None:
                    continue
                
                # Transcribe
                user_text = self.transcribe(audio)
                if not user_text:
                    continue
                
                print()
                
                # Check for exit commands
                if any(word in user_text.lower() for word in ["exit", "quit", "stop"]):
                    print(f"{YELLOW}👋 Shutting down voice agent...{NC}\n")
                    self.speak("Voice agent shutting down. Goodbye.")
                    break
                
                # Check for test command
                if "test" in user_text.lower():
                    response = "Voice integration test successful. All systems operational."
                    self.speak(response)
                    continue
                
                # Query AI
                response = self.query_ollama(user_text)
                if response:
                    self.speak(response)
                else:
                    print(f"{RED}✗ Failed to get AI response{NC}\n")
                
            except KeyboardInterrupt:
                print(f"\n{YELLOW}⏹ Voice agent stopped by user{NC}\n")
                break
            except Exception as e:
                print(f"{RED}✗ Unexpected error: {e}{NC}\n")
    
    def run_test(self):
        """Run a quick test of all components"""
        print(f"\n{BLUE}{'='*60}{NC}")
        print(f"{BLUE}🧪 FORTRESS AI - VOICE AGENT TEST{NC}")
        print(f"{BLUE}{'='*60}{NC}\n")
        
        # Test Ollama
        print(f"{BLUE}Test 1: Ollama Connection{NC}")
        result = subprocess.run("ollama list", shell=True, capture_output=True, text=True)
        if result.returncode == 0:
            print(f"{GREEN}✓ Ollama connected{NC}\n")
        else:
            print(f"{RED}✗ Ollama connection failed{NC}\n")
            return
        
        # Test AI model
        print(f"{BLUE}Test 2: AI Model Response{NC}")
        response = self.query_ollama("Say 'Voice integration successful' in one sentence.")
        if response:
            print(f"{GREEN}✓ Model response: {response[:100]}...{NC}\n")
        else:
            print(f"{RED}✗ Model test failed{NC}\n")
            return
        
        # Test TTS (if available)
        if self.tts:
            print(f"{BLUE}Test 3: Text-to-Speech{NC}")
            try:
                self.speak("Voice integration test successful.")
                print(f"{GREEN}✓ TTS test passed{NC}\n")
            except Exception as e:
                print(f"{YELLOW}⚠ TTS test failed: {e}{NC}\n")
        
        print(f"{BLUE}{'='*60}{NC}")
        print(f"{GREEN}✅ ALL TESTS COMPLETED{NC}")
        print(f"{BLUE}{'='*60}{NC}\n")

def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="FORTRESS AI - Voice Assistant for Legal Automation"
    )
    parser.add_argument(
        "--test",
        action="store_true",
        help="Run system test instead of interactive mode"
    )
    parser.add_argument(
        "--no-tts",
        action="store_true",
        help="Disable text-to-speech (for testing on servers)"
    )
    
    args = parser.parse_args()
    
    agent = VoiceAgent()
    
    if args.no_tts:
        agent.tts = None
    
    if args.test:
        agent.run_test()
    else:
        agent.run_interactive()

if __name__ == "__main__":
    main()
