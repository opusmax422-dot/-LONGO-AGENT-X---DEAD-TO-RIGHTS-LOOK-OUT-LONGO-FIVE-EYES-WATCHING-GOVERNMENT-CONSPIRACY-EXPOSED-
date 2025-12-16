# Agent X Fortress - PowerShell Connector for Windows
# Version: 1.0.0
# Description: WSL bridge for instant Agent X Fortress deployment

#Requires -Version 5.1

###############################################################################
# Configuration
###############################################################################

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$SCRIPT_VERSION = "1.0.0"
$REPO_URL = "https://github.com/opusmax422-dot/-LONGO-AGENT-X---DEAD-TO-RIGHTS-LOOK-OUT-LONGO-FIVE-EYES-WATCHING-GOVERNMENT-CONSPIRACY-EXPOSED-.git"
$REPO_DIR_NAME = "agent-x-fortress"
$WSL_INSTALL_PATH = "~/$REPO_DIR_NAME"

###############################################################################
# Colors and Formatting
###############################################################################

function Write-ColorOutput {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [string]$Color = "White",
        [switch]$NoNewline
    )
    
    if ($NoNewline) {
        Write-Host $Message -ForegroundColor $Color -NoNewline
    } else {
        Write-Host $Message -ForegroundColor $Color
    }
}

function Write-Header {
    Write-Host ""
    Write-ColorOutput "============================================================================" -Color Cyan
    Write-ColorOutput "  🔒 AGENT X FORTRESS - POWERSHELL CONNECTOR v$SCRIPT_VERSION" -Color Blue
    Write-ColorOutput "============================================================================" -Color Cyan
    Write-Host ""
}

function Write-Status {
    param([string]$Message)
    Write-ColorOutput "[✓] $Message" -Color Green
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "[!] $Message" -Color Yellow
}

function Write-Error {
    param([string]$Message)
    Write-ColorOutput "[✗] $Message" -Color Red
}

function Write-Info {
    param([string]$Message)
    Write-ColorOutput "[i] $Message" -Color Cyan
}

###############################################################################
# WSL Detection and Validation
###############################################################################

function Test-WSLInstalled {
    Write-Info "Checking for WSL installation..."
    
    try {
        $wslOutput = wsl --status 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Status "WSL is installed"
            return $true
        }
    } catch {
        Write-Error "WSL is not installed or not accessible"
        return $false
    }
    
    Write-Error "WSL is not installed"
    return $false
}

function Get-WSLDistributions {
    Write-Info "Detecting WSL distributions..."
    
    try {
        $distributions = wsl --list --quiet | Where-Object { $_ -match '\S' }
        
        if ($distributions) {
            Write-Status "Found WSL distributions:"
            foreach ($dist in $distributions) {
                $distName = $dist.Trim()
                if ($distName) {
                    Write-Info "  - $distName"
                }
            }
            return $distributions
        } else {
            Write-Warning "No WSL distributions found"
            return $null
        }
    } catch {
        Write-Error "Error detecting WSL distributions: $_"
        return $null
    }
}

function Select-WSLDistribution {
    param([array]$Distributions)
    
    if ($Distributions.Count -eq 1) {
        $selectedDist = $Distributions[0].Trim()
        Write-Status "Using distribution: $selectedDist"
        return $selectedDist
    }
    
    Write-Host ""
    Write-ColorOutput "Multiple WSL distributions found. Please select one:" -Color Yellow
    
    for ($i = 0; $i -lt $Distributions.Count; $i++) {
        $distName = $Distributions[$i].Trim()
        if ($distName) {
            Write-Host "  $($i + 1). $distName"
        }
    }
    
    do {
        $selection = Read-Host "Enter number (1-$($Distributions.Count))"
        $index = [int]$selection - 1
    } while ($index -lt 0 -or $index -ge $Distributions.Count)
    
    $selectedDist = $Distributions[$index].Trim()
    Write-Status "Selected: $selectedDist"
    return $selectedDist
}

###############################################################################
# Internet Connectivity Check
###############################################################################

function Test-InternetConnection {
    Write-Info "Checking internet connectivity..."
    
    $testHosts = @("github.com", "8.8.8.8")
    
    foreach ($host in $testHosts) {
        try {
            $ping = Test-Connection -ComputerName $host -Count 1 -Quiet -ErrorAction SilentlyContinue
            if ($ping) {
                Write-Status "Internet connection: OK"
                return $true
            }
        } catch {
            continue
        }
    }
    
    Write-Warning "Internet connection check failed"
    Write-Info "Some features may not work without internet"
    return $false
}

###############################################################################
# Git Operations
###############################################################################

function Install-GitInWSL {
    param([string]$Distribution)
    
    Write-Info "Checking git installation in WSL..."
    
    $gitCheck = wsl -d $Distribution bash -c "which git"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Git not found in WSL, attempting to install..."
        
        Write-Info "Updating package lists..."
        wsl -d $Distribution bash -c "sudo apt-get update -qq"
        
        Write-Info "Installing git..."
        wsl -d $Distribution bash -c "sudo apt-get install -y git"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Status "Git installed successfully"
        } else {
            Write-Error "Failed to install git"
            return $false
        }
    } else {
        Write-Status "Git is already installed"
    }
    
    return $true
}

function Clone-Repository {
    param(
        [string]$Distribution,
        [string]$RepoUrl,
        [string]$TargetPath
    )
    
    Write-Info "Checking if repository exists..."
    
    $repoExists = wsl -d $Distribution bash -c "test -d $TargetPath/.git && echo 'exists' || echo 'notfound'"
    
    if ($repoExists -match "exists") {
        Write-Warning "Repository already exists at $TargetPath"
        
        $response = Read-Host "Do you want to update it? (Y/N)"
        if ($response -match "^[Yy]") {
            Write-Info "Updating repository..."
            wsl -d $Distribution bash -c "cd $TargetPath && git pull"
            
            if ($LASTEXITCODE -eq 0) {
                Write-Status "Repository updated successfully"
                return $true
            } else {
                Write-Error "Failed to update repository"
                return $false
            }
        } else {
            Write-Info "Using existing repository"
            return $true
        }
    } else {
        Write-Info "Cloning repository from $RepoUrl..."
        
        wsl -d $Distribution bash -c "git clone $RepoUrl $TargetPath"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Status "Repository cloned successfully"
            return $true
        } else {
            Write-Error "Failed to clone repository"
            return $false
        }
    }
}

###############################################################################
# Installation Execution
###############################################################################

function Invoke-Installation {
    param(
        [string]$Distribution,
        [string]$RepoPath
    )
    
    Write-Info "Running installation script..."
    
    $installScript = "$RepoPath/install_agent_x.sh"
    
    # Check if install script exists
    $scriptExists = wsl -d $Distribution bash -c "test -f $installScript && echo 'exists' || echo 'notfound'"
    
    if ($scriptExists -match "notfound") {
        Write-Error "Installation script not found at $installScript"
        return $false
    }
    
    # Make script executable
    wsl -d $Distribution bash -c "chmod +x $installScript"
    
    # Run installation
    Write-Host ""
    Write-ColorOutput "Starting Agent X Fortress installation..." -Color Yellow
    Write-Host ""
    
    wsl -d $Distribution bash -c "cd $RepoPath && ./install_agent_x.sh"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Status "Installation completed successfully"
        return $true
    } else {
        Write-Error "Installation failed"
        return $false
    }
}

###############################################################################
# Launch Application
###############################################################################

function Start-AgentX {
    param(
        [string]$Distribution,
        [string]$RepoPath
    )
    
    Write-Info "Launching Agent X Fortress..."
    
    $launcherPath = "$RepoPath/bin/agent_x_launcher.py"
    
    # Check if launcher exists
    $launcherExists = wsl -d $Distribution bash -c "test -f $launcherPath && echo 'exists' || echo 'notfound'"
    
    if ($launcherExists -match "notfound") {
        Write-Error "Launcher not found at $launcherPath"
        return $false
    }
    
    # Launch application
    Write-Host ""
    wsl -d $Distribution bash -c "cd $RepoPath && python3 $launcherPath"
    
    return $true
}

###############################################################################
# Diagnostic Tools
###############################################################################

function Show-SystemInfo {
    Write-Header
    
    Write-Info "Gathering system information..."
    Write-Host ""
    
    # Windows version
    $winVersion = [System.Environment]::OSVersion.VersionString
    Write-ColorOutput "Windows Version: " -Color Cyan -NoNewline
    Write-Host $winVersion
    
    # PowerShell version
    Write-ColorOutput "PowerShell Version: " -Color Cyan -NoNewline
    Write-Host $PSVersionTable.PSVersion.ToString()
    
    # WSL version
    Write-ColorOutput "WSL Status: " -Color Cyan -NoNewline
    if (Test-WSLInstalled) {
        Write-ColorOutput "Installed" -Color Green
        
        $distributions = Get-WSLDistributions
        if ($distributions) {
            Write-ColorOutput "Distributions: " -Color Cyan
            foreach ($dist in $distributions) {
                $distName = $dist.Trim()
                if ($distName) {
                    Write-Host "  - $distName"
                }
            }
        }
    } else {
        Write-ColorOutput "Not Installed" -Color Red
    }
    
    # Internet connectivity
    Write-ColorOutput "Internet: " -Color Cyan -NoNewline
    if (Test-InternetConnection) {
        Write-ColorOutput "Connected" -Color Green
    } else {
        Write-ColorOutput "Not Connected" -Color Red
    }
    
    Write-Host ""
}

###############################################################################
# Uninstall Function
###############################################################################

function Uninstall-AgentX {
    param(
        [string]$Distribution,
        [string]$RepoPath
    )
    
    Write-Warning "This will remove the Agent X Fortress installation"
    $confirm = Read-Host "Are you sure? (Y/N)"
    
    if ($confirm -notmatch "^[Yy]") {
        Write-Info "Uninstall cancelled"
        return
    }
    
    Write-Info "Removing installation..."
    
    wsl -d $Distribution bash -c "rm -rf $RepoPath"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Status "Agent X Fortress uninstalled"
    } else {
        Write-Error "Failed to uninstall"
    }
}

###############################################################################
# Main Menu
###############################################################################

function Show-MainMenu {
    Write-Host ""
    Write-ColorOutput "============================================================================" -Color Cyan
    Write-ColorOutput "MAIN MENU" -Color White
    Write-ColorOutput "============================================================================" -Color Cyan
    Write-Host "1. Install Agent X Fortress"
    Write-Host "2. Launch Agent X Fortress"
    Write-Host "3. Update Agent X Fortress"
    Write-Host "4. System Diagnostics"
    Write-Host "5. Uninstall Agent X Fortress"
    Write-Host "6. Exit"
    Write-ColorOutput "============================================================================" -Color Cyan
    Write-Host ""
}

###############################################################################
# Main Function
###############################################################################

function Main {
    Write-Header
    
    # Check WSL
    if (-not (Test-WSLInstalled)) {
        Write-Error "WSL is required but not installed"
        Write-Info "Please install WSL first:"
        Write-Info "  1. Open PowerShell as Administrator"
        Write-Info "  2. Run: wsl --install"
        Write-Info "  3. Restart your computer"
        Write-Info "  4. Run this script again"
        return
    }
    
    # Get distributions
    $distributions = Get-WSLDistributions
    if (-not $distributions) {
        Write-Error "No WSL distributions found"
        Write-Info "Please install a Linux distribution from the Microsoft Store"
        return
    }
    
    # Select distribution
    $selectedDist = Select-WSLDistribution -Distributions $distributions
    
    # Main loop
    while ($true) {
        Show-MainMenu
        $choice = Read-Host "Select option"
        
        switch ($choice) {
            "1" {
                # Install
                Write-Host ""
                if (Test-InternetConnection) {
                    if (Install-GitInWSL -Distribution $selectedDist) {
                        if (Clone-Repository -Distribution $selectedDist -RepoUrl $REPO_URL -TargetPath $WSL_INSTALL_PATH) {
                            Invoke-Installation -Distribution $selectedDist -RepoPath $WSL_INSTALL_PATH
                        }
                    }
                } else {
                    Write-Error "Internet connection required for installation"
                }
                Read-Host "`nPress Enter to continue"
            }
            "2" {
                # Launch
                Write-Host ""
                Start-AgentX -Distribution $selectedDist -RepoPath $WSL_INSTALL_PATH
                Read-Host "`nPress Enter to continue"
            }
            "3" {
                # Update
                Write-Host ""
                if (Test-InternetConnection) {
                    Clone-Repository -Distribution $selectedDist -RepoUrl $REPO_URL -TargetPath $WSL_INSTALL_PATH
                } else {
                    Write-Error "Internet connection required for updates"
                }
                Read-Host "`nPress Enter to continue"
            }
            "4" {
                # Diagnostics
                Show-SystemInfo
                Read-Host "`nPress Enter to continue"
            }
            "5" {
                # Uninstall
                Write-Host ""
                Uninstall-AgentX -Distribution $selectedDist -RepoPath $WSL_INSTALL_PATH
                Read-Host "`nPress Enter to continue"
            }
            "6" {
                # Exit
                Write-Info "Goodbye!"
                return
            }
            default {
                Write-Warning "Invalid option. Please try again."
                Start-Sleep -Seconds 2
            }
        }
    }
}

###############################################################################
# Script Entry Point
###############################################################################

try {
    Main
} catch {
    Write-Error "An error occurred: $_"
    Write-Host ""
    Write-Info "Error details:"
    Write-Host $_.Exception.Message
    Write-Host $_.ScriptStackTrace
}
