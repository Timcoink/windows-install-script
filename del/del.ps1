# This script removes unnecessary built-in Windows apps (bloatware) for all users.
# It targets common consumer apps that are not essential for most users.
# 
# WARNING: Removing some apps may break your Windows installation.
# You can choose to remove a default set of apps, or select custom apps to remove.

Write-Host "WARNING: Removing built-in Windows apps may break your installation." -ForegroundColor Red
Write-Host "Proceed with caution." -ForegroundColor Yellow
Write-Host ""
Write-Host "Choose removal mode:"
Write-Host "1. Default (recommended): Remove common bloatware apps."
Write-Host "2. Custom: Show all installed apps and select which to remove."
$choice = Read-Host "Enter 1 for Default or 2 for Custom"

if ($choice -eq "2") {
    # Show all installed AppxPackages
    $allApps = Get-AppxPackage -AllUsers | Select-Object -Property Name, PackageFullName
    Write-Host "`nInstalled AppxPackages:"
    $i = 1
    foreach ($app in $allApps) {
        Write-Host "$i. $($app.Name)"
        $i++
    }
    Write-Host "`nEnter the numbers of the apps you want to remove, separated by commas (e.g. 1,3,5):"
    $input = Read-Host
    $indices = $input -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^\d+$' }
    $selectedApps = @()
    foreach ($idx in $indices) {
        $index = [int]$idx - 1
        if ($index -ge 0 -and $index -lt $allApps.Count) {
            $selectedApps += $allApps[$index].Name
        }
    }
    $apps = $selectedApps
} else {
    # Default list of common unnecessary app package names
    $apps = @(
        "Microsoft.3DBuilder",                # 3D Builder
        "Microsoft.Advertising.Xaml",         # Advertising XAML
        "Microsoft.BingFinance",              # MSN Money
        "Microsoft.BingNews",                 # MSN News
        "Microsoft.BingSports",               # MSN Sports
        "Microsoft.BingWeather",              # MSN Weather
        "Microsoft.GetHelp",                  # Get Help
        "Microsoft.Getstarted",               # Get Started / Tips
        "Microsoft.Microsoft3DViewer",        # 3D Viewer
        "Microsoft.MicrosoftOfficeHub",       # Office Hub
        "Microsoft.MicrosoftSolitaireCollection", # Solitaire Collection
        "Microsoft.MicrosoftStickyNotes",     # Sticky Notes
        "Microsoft.MixedReality.Portal",      # Mixed Reality Portal
        "Microsoft.MSPaint",                  # Paint 3D
        "Microsoft.OneConnect",               # OneConnect
        "Microsoft.People",                   # People
        "Microsoft.Print3D",                  # Print 3D
        "Microsoft.SkypeApp",                 # Skype
        "Microsoft.Wallet",                   # Wallet
        "Microsoft.Whiteboard",               # Whiteboard
        "Microsoft.WindowsAlarms",            # Alarms & Clock
        "Microsoft.WindowsFeedbackHub",       # Feedback Hub
        "Microsoft.WindowsMaps",              # Maps
        "Microsoft.WindowsSoundRecorder",     # Voice Recorder
        "Microsoft.WindowsCommunicationsApps",# Mail and Calendar
        "Microsoft.WindowsReadingList",       # Reading List
        "Microsoft.Xbox.TCUI",                # Xbox TCUI
        "Microsoft.XboxApp",                  # Xbox Console Companion
        "Microsoft.XboxGameOverlay",          # Xbox Game Overlay
        "Microsoft.XboxGamingOverlay",        # Xbox Game Bar
        "Microsoft.XboxIdentityProvider",     # Xbox Identity Provider
        "Microsoft.XboxSpeechToTextOverlay",  # Xbox Speech to Text Overlay
        "Microsoft.YourPhone",                # Phone Link
        "Microsoft.ZuneMusic",                # Groove Music
        "Microsoft.ZuneVideo",                # Movies & TV
        "Microsoft.ScreenSketch",             # Snip & Sketch
        "Microsoft.Office.OneNote",           # OneNote
        "Microsoft.Todos",                    # Microsoft To Do
        "Microsoft.549981C3F5F10",            # Cortana
        "Microsoft.BingTranslator",           # Bing Translator
        "Microsoft.MinecraftUWP",             # Minecraft for Windows
        "Microsoft.Office.Sway",              # Office Sway
        "Microsoft.SkypeApp",                 # Skype
        "Microsoft.XboxGameCallableUI",       # Xbox Game Callable UI
    )
}

$logPath = Join-Path -Path $PSScriptRoot -ChildPath "del-log.txt"
"App removal log - $(Get-Date)" | Out-File -FilePath $logPath

foreach ($app in $apps) {
    $logEntry = "[$(Get-Date -Format 'u')] Attempting to remove: $app"
    Write-Host $logEntry
    $logEntry | Out-File -FilePath $logPath -Append

    try {
        $pkg = Get-AppxPackage -Name $app -AllUsers
        if ($pkg) {
            $pkg | Remove-AppxPackage -AllUsers -ErrorAction Stop
            "[$(Get-Date -Format 'u')] Removed AppxPackage: $app" | Out-File -FilePath $logPath -Append
        } else {
            "[$(Get-Date -Format 'u')] AppxPackage not found: $app" | Out-File -FilePath $logPath -Append
        }
    } catch {
        "[$(Get-Date -Format 'u')] Error removing AppxPackage: $app - $_" | Out-File -FilePath $logPath -Append
    }

    try {
        $prov = Get-AppxProvisionedPackage -Online | Where-Object DisplayName -EQ $app
        if ($prov) {
            $prov | Remove-AppxProvisionedPackage -Online -ErrorAction Stop
            "[$(Get-Date -Format 'u')] Removed ProvisionedPackage: $app" | Out-File -FilePath $logPath -Append
        } else {
            "[$(Get-Date -Format 'u')] ProvisionedPackage not found: $app" | Out-File -FilePath $logPath -Append
        }
    } catch {
        "[$(Get-Date -Format 'u')] Error removing ProvisionedPackage: $app - $_" | Out-File -FilePath $logPath -Append
    }
}

Write-Host "Unnecessary apps have been removed. See del-log.txt for details."
