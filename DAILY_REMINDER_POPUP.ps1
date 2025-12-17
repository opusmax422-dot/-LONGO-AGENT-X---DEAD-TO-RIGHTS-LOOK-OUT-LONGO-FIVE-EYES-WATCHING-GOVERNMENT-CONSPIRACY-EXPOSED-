# DAILY_REMINDER_POPUP.ps1
# Francesco's Daily Trading Algorithm Launcher

Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show(
    "🎯 FORTRESS AGENT X - DAILY TRAJECTORY REMINDER`n`n" +
    "✅ Launch WSL: cd ~/FORTRESS_AGENT_X && ./RUN_FULL_DAY_CHART.sh",
    "FORTRESS AGENT X",
    [System.Windows.MessageBoxButton]::OK,
    [System.Windows.MessageBoxImage]::Information
)