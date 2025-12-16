#!/usr/bin/env python3
"""
AGENT X FORTRESS - MAIN LAUNCHER APPLICATION
Production-ready legal document generator with enterprise-grade error handling

Features:
- Form 7A Federal Court Document Generation
- Motion to Dismiss Generation  
- Evidence Timeline Analysis
- Chart System Integration (Ready for Francesco's Algorithm)
- Social Media Content Generation
- Comprehensive Error Handling
- Path Validation & Safe File Operations
- Rotating Log System

All 4 Critical Fixes Implemented:
✅ Fix #1: Offline compatibility - Local chart library reference
✅ Fix #2: Correct method naming - generate_motion_to_dismiss()
✅ Fix #3: Robust error handling - safe_save_file() function
✅ Fix #4: Path validation - All file operations validated
"""

import os
import sys
import logging
import json
from datetime import datetime
from pathlib import Path
from logging.handlers import RotatingFileHandler

# ANSI Colors for terminal output
class Colors:
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    MAGENTA = '\033[95m'
    BOLD = '\033[1m'
    RESET = '\033[0m'

# Get base directory (repository root)
BASE_DIR = Path(__file__).resolve().parent.parent

# Directory paths
LOGS_DIR = BASE_DIR / "logs"
OUTPUT_DIR = BASE_DIR / "output"
DATA_DIR = BASE_DIR / "data"
TEMPLATES_DIR = DATA_DIR / "templates"
EVIDENCE_DIR = DATA_DIR / "evidence"
SOCIAL_DIR = DATA_DIR / "social"
CHARTS_DIR = DATA_DIR / "charts"
CONFIG_DIR = BASE_DIR / "config"

# Logging setup
def setup_logging():
    """Configure rotating log handler with error handling"""
    try:
        # Ensure log directory exists
        LOGS_DIR.mkdir(parents=True, exist_ok=True)
        
        # Create rotating file handler (10MB per file, keep 5 backups)
        log_file = LOGS_DIR / "agent_x.log"
        handler = RotatingFileHandler(
            log_file,
            maxBytes=10*1024*1024,  # 10MB
            backupCount=5
        )
        
        # Set format
        formatter = logging.Formatter(
            '%(asctime)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        handler.setFormatter(formatter)
        
        # Configure root logger
        logger = logging.getLogger()
        logger.setLevel(logging.INFO)
        logger.addHandler(handler)
        
        # Also log to console
        console_handler = logging.StreamHandler()
        console_handler.setFormatter(formatter)
        logger.addHandler(console_handler)
        
        logging.info("=" * 60)
        logging.info("AGENT X FORTRESS - Application Started")
        logging.info("=" * 60)
        return True
        
    except Exception as e:
        print(f"{Colors.RED}⚠️  Warning: Could not setup logging: {e}{Colors.RESET}")
        return False

# FIX #3 & #4: Robust error handling with path validation
def safe_save_file(content, filename, filepath):
    """
    Safely save file with comprehensive error handling and path validation
    
    Args:
        content (str): Content to write to file
        filename (str): Name of the file
        filepath (Path or str): Directory path where file should be saved
        
    Returns:
        tuple: (success: bool, message: str)
    """
    try:
        # Convert to Path object
        filepath = Path(filepath)
        
        # Validate filepath exists, create if needed
        if not filepath.exists():
            try:
                filepath.mkdir(parents=True, exist_ok=True)
                logging.info(f"Created directory: {filepath}")
            except PermissionError:
                error_msg = f"❌ Permission denied: Cannot create directory {filepath}"
                logging.error(error_msg)
                return False, error_msg
            except Exception as e:
                error_msg = f"❌ Error creating directory {filepath}: {str(e)}"
                logging.error(error_msg)
                return False, error_msg
        
        # Check if directory is writable
        if not os.access(filepath, os.W_OK):
            error_msg = f"❌ Permission denied: Directory {filepath} is not writable"
            logging.error(error_msg)
            return False, error_msg
        
        # Construct full path
        full_path = filepath / filename
        
        # Write file
        try:
            with open(full_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            success_msg = f"✅ Saved: {filename} ({len(content)} bytes)"
            logging.info(f"File saved successfully: {full_path}")
            return True, success_msg
            
        except PermissionError:
            error_msg = f"❌ Permission denied: Cannot write to {full_path}"
            logging.error(error_msg)
            return False, error_msg
            
        except IOError as e:
            error_msg = f"❌ I/O error writing {filename}: {str(e)}"
            logging.error(error_msg)
            return False, error_msg
            
    except Exception as e:
        error_msg = f"❌ Unexpected error saving {filename}: {str(e)}"
        logging.error(error_msg)
        return False, error_msg

def safe_read_file(filepath):
    """
    Safely read file with error handling
    
    Args:
        filepath (Path or str): Full path to file
        
    Returns:
        tuple: (success: bool, content: str or error message)
    """
    try:
        filepath = Path(filepath)
        
        if not filepath.exists():
            error_msg = f"❌ File not found: {filepath}"
            logging.error(error_msg)
            return False, error_msg
        
        if not os.access(filepath, os.R_OK):
            error_msg = f"❌ Permission denied: Cannot read {filepath}"
            logging.error(error_msg)
            return False, error_msg
        
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        logging.info(f"File read successfully: {filepath}")
        return True, content
        
    except Exception as e:
        error_msg = f"❌ Error reading file: {str(e)}"
        logging.error(error_msg)
        return False, error_msg

class AgentXFortress:
    """Main application class for Agent X Fortress"""
    
    def __init__(self):
        """Initialize the application"""
        self.version = "1.0.0"
        self.ensure_directories()
    
    def ensure_directories(self):
        """Ensure all required directories exist"""
        directories = [
            LOGS_DIR, OUTPUT_DIR, TEMPLATES_DIR, 
            EVIDENCE_DIR, SOCIAL_DIR, CHARTS_DIR, CONFIG_DIR
        ]
        
        for directory in directories:
            try:
                directory.mkdir(parents=True, exist_ok=True)
            except Exception as e:
                logging.warning(f"Could not create directory {directory}: {e}")
    
    def generate_form_7a(self, case_info):
        """
        Generate Form 7A Federal Court Document
        
        Args:
            case_info (dict): Case information including:
                - case_number: str
                - court: str
                - plaintiff: str
                - defendant: str
                - facts: list of str
                - grounds: list of str
                - relief: str
        
        Returns:
            tuple: (success: bool, message: str)
        """
        try:
            # Validate required fields
            required_fields = ['case_number', 'court', 'plaintiff', 'defendant']
            for field in required_fields:
                if field not in case_info:
                    return False, f"❌ Missing required field: {field}"
            
            # Generate document content
            content = f"""
{'=' * 80}
FORM 7A - STATEMENT OF CLAIM
{'=' * 80}

Court File No.: {case_info.get('case_number', 'N/A')}

IN THE {case_info.get('court', 'FEDERAL COURT')}

BETWEEN:

    {case_info.get('plaintiff', 'N/A').upper()}
                                                                    Plaintiff
- and -

    {case_info.get('defendant', 'N/A').upper()}
                                                                    Defendant

{'=' * 80}
STATEMENT OF CLAIM
{'=' * 80}

TO THE DEFENDANT:

A LEGAL PROCEEDING has been commenced against you by the Plaintiff. The claim
made against you is set out in the following pages.

IF YOU WISH TO DEFEND THIS PROCEEDING, you or a solicitor acting for you must
prepare a Statement of Defence in Form 7B prescribed by the Federal Courts Rules,
serve it on the Plaintiff's solicitor, or where the Plaintiff does not have a
solicitor, serve it on the Plaintiff, and file it, with proof of service, at
this Court office, WITHIN 30 DAYS after this Statement of Claim is served on you,
if you are served in Canada.

IF YOU FAIL TO DEFEND THIS PROCEEDING, judgment may be given against you in your
absence and without further notice to you.

Date: {datetime.now().strftime('%B %d, %Y')}


{'=' * 80}
STATEMENT OF FACTS
{'=' * 80}

"""
            # Add facts
            facts = case_info.get('facts', [])
            if facts:
                for i, fact in enumerate(facts, 1):
                    content += f"{i}. {fact}\n\n"
            else:
                content += "1. [State the material facts upon which you rely]\n\n"
            
            content += f"""
{'=' * 80}
LEGAL GROUNDS
{'=' * 80}

"""
            # Add legal grounds
            grounds = case_info.get('grounds', [])
            if grounds:
                for i, ground in enumerate(grounds, 1):
                    content += f"{i}. {ground}\n\n"
            else:
                content += "1. [Cite the legal provisions upon which you rely]\n\n"
            
            content += f"""
{'=' * 80}
RELIEF SOUGHT
{'=' * 80}

The Plaintiff claims:

{case_info.get('relief', '1. [Specify the relief sought]')}


{'=' * 80}
SIGNATURE
{'=' * 80}

Date: {datetime.now().strftime('%B %d, %Y')}

_________________________________
{case_info.get('plaintiff', 'Plaintiff')}
Plaintiff (or Solicitor for the Plaintiff)

Address: ___________________________
         ___________________________
         ___________________________

Email: _____________________________
Phone: _____________________________

{'=' * 80}
END OF DOCUMENT
{'=' * 80}
"""
            
            # Save to file
            filename = f"Form_7A_{case_info.get('case_number', 'draft').replace('/', '_')}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
            success, message = safe_save_file(content, filename, OUTPUT_DIR)
            
            if success:
                logging.info(f"Form 7A generated: {filename}")
                return True, f"{message}\nPath: {OUTPUT_DIR / filename}"
            else:
                return False, message
                
        except Exception as e:
            error_msg = f"❌ Error generating Form 7A: {str(e)}"
            logging.error(error_msg)
            return False, error_msg
    
    # FIX #2: Method correctly named as generate_motion_to_dismiss()
    def generate_motion_to_dismiss(self, case_info):
        """
        Generate Motion to Dismiss document
        
        Args:
            case_info (dict): Case information including:
                - case_number: str
                - court: str
                - plaintiff: str
                - defendant: str
                - grounds: list of str (grounds for dismissal)
                - arguments: list of str (legal arguments)
        
        Returns:
            tuple: (success: bool, message: str)
        """
        try:
            # Validate required fields
            required_fields = ['case_number', 'court', 'plaintiff', 'defendant']
            for field in required_fields:
                if field not in case_info:
                    return False, f"❌ Missing required field: {field}"
            
            # Generate document content
            content = f"""
{'=' * 80}
MOTION TO DISMISS
{'=' * 80}

Court File No.: {case_info.get('case_number', 'N/A')}

IN THE {case_info.get('court', 'FEDERAL COURT')}

BETWEEN:

    {case_info.get('plaintiff', 'N/A').upper()}
                                                                    Plaintiff
- and -

    {case_info.get('defendant', 'N/A').upper()}
                                                                    Defendant

{'=' * 80}
NOTICE OF MOTION
{'=' * 80}

TAKE NOTICE that the Defendant will make a motion to the Court on a date to be
fixed by the Court, or as soon thereafter as the motion can be heard, for an
Order dismissing this action.

THE GROUNDS FOR THIS MOTION ARE:

"""
            # Add grounds
            grounds = case_info.get('grounds', [])
            if grounds:
                for i, ground in enumerate(grounds, 1):
                    content += f"{i}. {ground}\n\n"
            else:
                content += "1. The Statement of Claim discloses no reasonable cause of action.\n\n"
                content += "2. The Court lacks jurisdiction over the subject matter of this action.\n\n"
                content += "3. The Plaintiff lacks standing to bring this action.\n\n"
            
            content += f"""
{'=' * 80}
LEGAL ARGUMENT
{'=' * 80}

"""
            # Add arguments
            arguments = case_info.get('arguments', [])
            if arguments:
                for i, argument in enumerate(arguments, 1):
                    content += f"{i}. {argument}\n\n"
            else:
                content += "1. [State your legal arguments for dismissal]\n\n"
            
            content += f"""
{'=' * 80}
CONCLUSION
{'=' * 80}

For the foregoing reasons, the Defendant respectfully requests that this
Honourable Court grant an Order:

1. Dismissing the Plaintiff's action in its entirety;
2. Awarding costs to the Defendant on a substantial indemnity basis; and
3. Such further and other relief as this Honourable Court deems just.


{'=' * 80}
CERTIFICATE OF SERVICE
{'=' * 80}

I hereby certify that a copy of this Motion to Dismiss was served on the
Plaintiff's solicitor (or the Plaintiff, if unrepresented) on
{datetime.now().strftime('%B %d, %Y')} by [method of service].


Date: {datetime.now().strftime('%B %d, %Y')}

_________________________________
{case_info.get('defendant', 'Defendant')}
Defendant (or Solicitor for the Defendant)

Address: ___________________________
         ___________________________
         ___________________________

Email: _____________________________
Phone: _____________________________

{'=' * 80}
END OF DOCUMENT
{'=' * 80}
"""
            
            # Save to file
            filename = f"Motion_to_Dismiss_{case_info.get('case_number', 'draft').replace('/', '_')}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
            success, message = safe_save_file(content, filename, OUTPUT_DIR)
            
            if success:
                logging.info(f"Motion to Dismiss generated: {filename}")
                return True, f"{message}\nPath: {OUTPUT_DIR / filename}"
            else:
                return False, message
                
        except Exception as e:
            error_msg = f"❌ Error generating Motion to Dismiss: {str(e)}"
            logging.error(error_msg)
            return False, error_msg
    
    def analyze_evidence_timeline(self, evidence_text):
        """
        Analyze evidence text and extract timeline of events
        
        Args:
            evidence_text (str): Text containing evidence with dates
        
        Returns:
            tuple: (success: bool, result: dict or error message)
        """
        try:
            import re
            from datetime import datetime
            
            # Common date patterns
            date_patterns = [
                r'\b(\d{4}-\d{2}-\d{2})\b',  # YYYY-MM-DD
                r'\b(\d{1,2}/\d{1,2}/\d{4})\b',  # MM/DD/YYYY or DD/MM/YYYY
                r'\b(\d{1,2}-\d{1,2}-\d{4})\b',  # MM-DD-YYYY or DD-MM-YYYY
                r'\b(January|February|March|April|May|June|July|August|September|October|November|December)\s+\d{1,2},?\s+\d{4}\b',  # Month DD, YYYY
            ]
            
            events = []
            
            # Split text into lines
            lines = evidence_text.split('\n')
            
            for line in lines:
                line = line.strip()
                if not line:
                    continue
                
                # Try to find dates in the line
                for pattern in date_patterns:
                    matches = re.finditer(pattern, line, re.IGNORECASE)
                    for match in matches:
                        date_str = match.group(0)
                        events.append({
                            'date': date_str,
                            'description': line,
                            'position': match.start()
                        })
            
            # Remove duplicates and sort
            unique_events = []
            seen = set()
            for event in events:
                key = (event['date'], event['description'])
                if key not in seen:
                    seen.add(key)
                    unique_events.append(event)
            
            result = {
                'total_events': len(unique_events),
                'events': unique_events,
                'summary': f"Found {len(unique_events)} dated events in the evidence"
            }
            
            # Save timeline to file
            timeline_content = f"""
{'=' * 80}
EVIDENCE TIMELINE ANALYSIS
{'=' * 80}

Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
Total Events Found: {len(unique_events)}

{'=' * 80}
CHRONOLOGICAL EVENTS
{'=' * 80}

"""
            for i, event in enumerate(unique_events, 1):
                timeline_content += f"{i}. Date: {event['date']}\n"
                timeline_content += f"   Event: {event['description']}\n\n"
            
            timeline_content += f"""
{'=' * 80}
END OF TIMELINE
{'=' * 80}
"""
            
            filename = f"Timeline_Analysis_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
            success, message = safe_save_file(timeline_content, filename, OUTPUT_DIR)
            
            if success:
                logging.info(f"Timeline analysis saved: {filename}")
                result['file'] = filename
                result['path'] = str(OUTPUT_DIR / filename)
            
            return True, result
            
        except Exception as e:
            error_msg = f"❌ Error analyzing timeline: {str(e)}"
            logging.error(error_msg)
            return False, error_msg
    
    def generate_social_content(self, topic, platform="twitter"):
        """
        Generate social media content
        
        Args:
            topic (str): Topic for the content
            platform (str): Social media platform (twitter, facebook, etc.)
        
        Returns:
            tuple: (success: bool, message: str)
        """
        try:
            if platform.lower() == "twitter":
                # Generate Twitter/X thread
                content = f"""
{'=' * 80}
TWITTER/X THREAD - {topic.upper()}
{'=' * 80}

Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

THREAD:

1/🧵 {topic} - Let's break this down. This is a critical issue that demands attention.

2/🧵 The evidence is clear and documented. We have receipts, timestamps, and corroborating witnesses.

3/🧵 This isn't speculation - these are facts supported by official records and documentation.

4/🧵 Key points to understand:
   • Timeline is verified
   • Evidence is preserved
   • Witnesses are on record

5/🧵 The implications are serious. This affects not just individuals but systemic accountability.

6/🧵 What can be done? First, awareness. Second, documentation. Third, legal action where warranted.

7/🧵 Resources and documentation are available. Contact information and support channels are provided.

8/🧵 This thread will be updated as new information becomes available. Stay informed, stay vigilant.

{'=' * 80}
HASHTAGS
{'=' * 80}

#Justice #Accountability #Truth #Evidence #Documentation #Legal #Rights

{'=' * 80}
END OF THREAD
{'=' * 80}
"""
            else:
                content = f"""
{'=' * 80}
SOCIAL MEDIA POST - {platform.upper()}
{'=' * 80}

Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

Topic: {topic}

[Content would be customized for {platform}]

{'=' * 80}
"""
            
            # Save to file
            filename = f"{platform}_content_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
            success, message = safe_save_file(content, filename, SOCIAL_DIR)
            
            if success:
                logging.info(f"Social content generated: {filename}")
                return True, f"{message}\nPath: {SOCIAL_DIR / filename}"
            else:
                return False, message
                
        except Exception as e:
            error_msg = f"❌ Error generating social content: {str(e)}"
            logging.error(error_msg)
            return False, error_msg
    
    def insert_francesco_algorithm(self, data):
        """
        Interface for Francesco's proprietary trading algorithm
        
        This method provides the integration point for custom trading algorithms
        to be visualized using the chart system.
        
        Args:
            data (list): OHLC data in format:
                [{"time": "2025-01-01", "open": 100, "high": 105, 
                  "low": 99, "close": 103, "volume": 10000}, ...]
        
        Returns:
            tuple: (success: bool, message: str)
        """
        try:
            # Validate data format
            if not isinstance(data, list) or len(data) == 0:
                return False, "❌ Data must be a non-empty list"
            
            # Basic validation of OHLC format
            required_fields = ['time', 'open', 'high', 'low', 'close']
            for i, item in enumerate(data):
                for field in required_fields:
                    if field not in item:
                        return False, f"❌ Missing field '{field}' in data item {i}"
            
            # Generate chart HTML with data
            chart_template_path = CHARTS_DIR / "chart_template.html"
            success, template_content = safe_read_file(chart_template_path)
            
            if not success:
                return False, f"❌ Could not read chart template: {template_content}"
            
            # Create a custom chart with the data embedded
            data_json = json.dumps(data, indent=2)
            
            custom_chart = template_content.replace(
                'document.getElementById(\'dataInput\').value = \'\';',
                f'document.getElementById(\'dataInput\').value = {json.dumps(data_json)};'
            )
            
            # Save custom chart
            filename = f"algorithm_chart_{datetime.now().strftime('%Y%m%d_%H%M%S')}.html"
            success, message = safe_save_file(custom_chart, filename, OUTPUT_DIR)
            
            if success:
                logging.info(f"Francesco's algorithm chart generated: {filename}")
                return True, f"{message}\nPath: {OUTPUT_DIR / filename}\nData points: {len(data)}"
            else:
                return False, message
                
        except Exception as e:
            error_msg = f"❌ Error inserting algorithm: {str(e)}"
            logging.error(error_msg)
            return False, error_msg
    
    def print_header(self):
        """Print application header"""
        print(f"\n{Colors.CYAN}{'=' * 80}{Colors.RESET}")
        print(f"{Colors.BOLD}{Colors.BLUE}   🔒 AGENT X FORTRESS - LEGAL DOCUMENT GENERATOR v{self.version}{Colors.RESET}")
        print(f"{Colors.CYAN}{'=' * 80}{Colors.RESET}\n")
    
    def print_menu(self):
        """Print main menu"""
        print(f"{Colors.GREEN}{'=' * 80}{Colors.RESET}")
        print(f"{Colors.BOLD}MAIN MENU{Colors.RESET}")
        print(f"{Colors.GREEN}{'=' * 80}{Colors.RESET}")
        print(f"{Colors.CYAN}1.{Colors.RESET} Generate Form 7A (Statement of Claim)")
        print(f"{Colors.CYAN}2.{Colors.RESET} Generate Motion to Dismiss")
        print(f"{Colors.CYAN}3.{Colors.RESET} Analyze Evidence Timeline")
        print(f"{Colors.CYAN}4.{Colors.RESET} Generate Social Media Content")
        print(f"{Colors.CYAN}5.{Colors.RESET} Chart System (Francesco's Algorithm Interface)")
        print(f"{Colors.CYAN}6.{Colors.RESET} System Information")
        print(f"{Colors.CYAN}7.{Colors.RESET} Exit")
        print(f"{Colors.GREEN}{'=' * 80}{Colors.RESET}\n")
    
    def get_input(self, prompt, required=True):
        """Get user input with optional requirement check"""
        while True:
            value = input(f"{Colors.YELLOW}{prompt}{Colors.RESET}").strip()
            if value or not required:
                return value
            print(f"{Colors.RED}This field is required.{Colors.RESET}")
    
    def menu_form_7a(self):
        """Interactive menu for Form 7A generation"""
        print(f"\n{Colors.BOLD}FORM 7A - STATEMENT OF CLAIM{Colors.RESET}\n")
        
        case_info = {
            'case_number': self.get_input("Case Number: "),
            'court': self.get_input("Court (default: FEDERAL COURT): ", required=False) or "FEDERAL COURT",
            'plaintiff': self.get_input("Plaintiff Name: "),
            'defendant': self.get_input("Defendant Name: "),
        }
        
        # Get facts
        print(f"\n{Colors.CYAN}Enter facts (one per line, empty line to finish):{Colors.RESET}")
        facts = []
        while True:
            fact = input().strip()
            if not fact:
                break
            facts.append(fact)
        case_info['facts'] = facts
        
        # Get grounds
        print(f"\n{Colors.CYAN}Enter legal grounds (one per line, empty line to finish):{Colors.RESET}")
        grounds = []
        while True:
            ground = input().strip()
            if not ground:
                break
            grounds.append(ground)
        case_info['grounds'] = grounds
        
        # Get relief
        case_info['relief'] = self.get_input("\nRelief Sought: ")
        
        # Generate document
        print(f"\n{Colors.YELLOW}Generating Form 7A...{Colors.RESET}")
        success, message = self.generate_form_7a(case_info)
        
        if success:
            print(f"\n{Colors.GREEN}{message}{Colors.RESET}")
        else:
            print(f"\n{Colors.RED}{message}{Colors.RESET}")
        
        input(f"\n{Colors.YELLOW}Press Enter to continue...{Colors.RESET}")
    
    def menu_motion_to_dismiss(self):
        """Interactive menu for Motion to Dismiss generation"""
        print(f"\n{Colors.BOLD}MOTION TO DISMISS{Colors.RESET}\n")
        
        case_info = {
            'case_number': self.get_input("Case Number: "),
            'court': self.get_input("Court (default: FEDERAL COURT): ", required=False) or "FEDERAL COURT",
            'plaintiff': self.get_input("Plaintiff Name: "),
            'defendant': self.get_input("Defendant Name: "),
        }
        
        # Get grounds
        print(f"\n{Colors.CYAN}Enter grounds for dismissal (one per line, empty line to finish):{Colors.RESET}")
        grounds = []
        while True:
            ground = input().strip()
            if not ground:
                break
            grounds.append(ground)
        case_info['grounds'] = grounds
        
        # Get arguments
        print(f"\n{Colors.CYAN}Enter legal arguments (one per line, empty line to finish):{Colors.RESET}")
        arguments = []
        while True:
            argument = input().strip()
            if not argument:
                break
            arguments.append(argument)
        case_info['arguments'] = arguments
        
        # Generate document - FIX #2: Using correct method name
        print(f"\n{Colors.YELLOW}Generating Motion to Dismiss...{Colors.RESET}")
        success, message = self.generate_motion_to_dismiss(case_info)
        
        if success:
            print(f"\n{Colors.GREEN}{message}{Colors.RESET}")
        else:
            print(f"\n{Colors.RED}{message}{Colors.RESET}")
        
        input(f"\n{Colors.YELLOW}Press Enter to continue...{Colors.RESET}")
    
    def menu_timeline_analysis(self):
        """Interactive menu for timeline analysis"""
        print(f"\n{Colors.BOLD}EVIDENCE TIMELINE ANALYSIS{Colors.RESET}\n")
        
        print(f"{Colors.CYAN}Enter evidence text (multi-line, type 'END' on a new line to finish):{Colors.RESET}")
        lines = []
        while True:
            line = input()
            if line.strip().upper() == 'END':
                break
            lines.append(line)
        
        evidence_text = '\n'.join(lines)
        
        if not evidence_text.strip():
            print(f"{Colors.RED}No evidence text provided.{Colors.RESET}")
            input(f"\n{Colors.YELLOW}Press Enter to continue...{Colors.RESET}")
            return
        
        print(f"\n{Colors.YELLOW}Analyzing timeline...{Colors.RESET}")
        success, result = self.analyze_evidence_timeline(evidence_text)
        
        if success:
            print(f"\n{Colors.GREEN}✅ Analysis complete!{Colors.RESET}")
            print(f"{Colors.CYAN}Total events found: {result['total_events']}{Colors.RESET}")
            if result['total_events'] > 0:
                print(f"\n{Colors.BOLD}Events:{Colors.RESET}")
                for i, event in enumerate(result['events'][:10], 1):  # Show first 10
                    print(f"{i}. {event['date']} - {event['description'][:60]}...")
                if result['total_events'] > 10:
                    print(f"\n{Colors.YELLOW}... and {result['total_events'] - 10} more events{Colors.RESET}")
            print(f"\n{Colors.GREEN}Full timeline saved to: {result.get('path', 'N/A')}{Colors.RESET}")
        else:
            print(f"\n{Colors.RED}{result}{Colors.RESET}")
        
        input(f"\n{Colors.YELLOW}Press Enter to continue...{Colors.RESET}")
    
    def menu_social_content(self):
        """Interactive menu for social media content generation"""
        print(f"\n{Colors.BOLD}SOCIAL MEDIA CONTENT GENERATOR{Colors.RESET}\n")
        
        topic = self.get_input("Topic: ")
        platform = self.get_input("Platform (twitter/facebook/linkedin) [default: twitter]: ", required=False) or "twitter"
        
        print(f"\n{Colors.YELLOW}Generating content for {platform}...{Colors.RESET}")
        success, message = self.generate_social_content(topic, platform)
        
        if success:
            print(f"\n{Colors.GREEN}{message}{Colors.RESET}")
        else:
            print(f"\n{Colors.RED}{message}{Colors.RESET}")
        
        input(f"\n{Colors.YELLOW}Press Enter to continue...{Colors.RESET}")
    
    def menu_chart_system(self):
        """Interactive menu for chart system"""
        print(f"\n{Colors.BOLD}CHART SYSTEM - FRANCESCO'S ALGORITHM INTERFACE{Colors.RESET}\n")
        
        print(f"{Colors.CYAN}1.{Colors.RESET} Load sample algorithm data")
        print(f"{Colors.CYAN}2.{Colors.RESET} Open chart template in browser")
        print(f"{Colors.CYAN}3.{Colors.RESET} Back to main menu")
        
        choice = self.get_input("\nSelect option: ")
        
        if choice == '1':
            # Sample algorithm data
            sample_data = [
                {"time": "2024-01-01", "open": 100, "high": 110, "low": 95, "close": 108, "volume": 50000},
                {"time": "2024-02-01", "open": 108, "high": 115, "low": 105, "close": 112, "volume": 60000},
                {"time": "2024-03-01", "open": 112, "high": 120, "low": 110, "close": 118, "volume": 75000},
                {"time": "2024-04-01", "open": 118, "high": 125, "low": 115, "close": 122, "volume": 80000},
                {"time": "2024-05-01", "open": 122, "high": 130, "low": 120, "close": 128, "volume": 90000},
            ]
            
            print(f"\n{Colors.YELLOW}Generating chart with sample data...{Colors.RESET}")
            success, message = self.insert_francesco_algorithm(sample_data)
            
            if success:
                print(f"\n{Colors.GREEN}{message}{Colors.RESET}")
            else:
                print(f"\n{Colors.RED}{message}{Colors.RESET}")
        
        elif choice == '2':
            chart_path = CHARTS_DIR / "chart_template.html"
            if chart_path.exists():
                print(f"\n{Colors.GREEN}Chart template location: {chart_path}{Colors.RESET}")
                print(f"{Colors.YELLOW}Open this file in your browser to use the chart interface.{Colors.RESET}")
            else:
                print(f"\n{Colors.RED}Chart template not found at: {chart_path}{Colors.RESET}")
        
        input(f"\n{Colors.YELLOW}Press Enter to continue...{Colors.RESET}")
    
    def menu_system_info(self):
        """Display system information"""
        print(f"\n{Colors.BOLD}SYSTEM INFORMATION{Colors.RESET}\n")
        
        print(f"{Colors.CYAN}Version:{Colors.RESET} {self.version}")
        print(f"{Colors.CYAN}Base Directory:{Colors.RESET} {BASE_DIR}")
        print(f"{Colors.CYAN}Output Directory:{Colors.RESET} {OUTPUT_DIR}")
        print(f"{Colors.CYAN}Logs Directory:{Colors.RESET} {LOGS_DIR}")
        print(f"{Colors.CYAN}Charts Directory:{Colors.RESET} {CHARTS_DIR}")
        
        print(f"\n{Colors.BOLD}Directory Status:{Colors.RESET}")
        directories = {
            'Output': OUTPUT_DIR,
            'Logs': LOGS_DIR,
            'Templates': TEMPLATES_DIR,
            'Evidence': EVIDENCE_DIR,
            'Social': SOCIAL_DIR,
            'Charts': CHARTS_DIR,
            'Config': CONFIG_DIR
        }
        
        for name, path in directories.items():
            status = f"{Colors.GREEN}✓{Colors.RESET}" if path.exists() else f"{Colors.RED}✗{Colors.RESET}"
            print(f"  {status} {name}: {path}")
        
        print(f"\n{Colors.BOLD}Critical Fixes Status:{Colors.RESET}")
        print(f"{Colors.GREEN}✅ Fix #1:{Colors.RESET} Offline Compatibility - Chart uses local library")
        print(f"{Colors.GREEN}✅ Fix #2:{Colors.RESET} Method Reference - generate_motion_to_dismiss() correctly named")
        print(f"{Colors.GREEN}✅ Fix #3:{Colors.RESET} Error Handling - safe_save_file() implemented")
        print(f"{Colors.GREEN}✅ Fix #4:{Colors.RESET} Path Validation - All file operations validated")
        
        input(f"\n{Colors.YELLOW}Press Enter to continue...{Colors.RESET}")
    
    def run(self):
        """Main application loop"""
        try:
            self.print_header()
            
            while True:
                self.print_menu()
                choice = self.get_input("Select option: ", required=False)
                
                if choice == '1':
                    self.menu_form_7a()
                elif choice == '2':
                    self.menu_motion_to_dismiss()
                elif choice == '3':
                    self.menu_timeline_analysis()
                elif choice == '4':
                    self.menu_social_content()
                elif choice == '5':
                    self.menu_chart_system()
                elif choice == '6':
                    self.menu_system_info()
                elif choice == '7':
                    print(f"\n{Colors.GREEN}Thank you for using Agent X Fortress!{Colors.RESET}\n")
                    logging.info("Application shutdown by user")
                    break
                else:
                    print(f"{Colors.RED}Invalid option. Please try again.{Colors.RESET}")
                    input(f"\n{Colors.YELLOW}Press Enter to continue...{Colors.RESET}")
        
        except KeyboardInterrupt:
            print(f"\n\n{Colors.YELLOW}Application interrupted by user.{Colors.RESET}\n")
            logging.info("Application interrupted by user (Ctrl+C)")
        except Exception as e:
            print(f"\n{Colors.RED}Fatal error: {str(e)}{Colors.RESET}\n")
            logging.error(f"Fatal error in main loop: {str(e)}", exc_info=True)

def main():
    """Main entry point"""
    # Setup logging
    setup_logging()
    
    # Create and run application
    app = AgentXFortress()
    app.run()

if __name__ == "__main__":
    main()
