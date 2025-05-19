# WARNING: This script will reset your PC, install .exe files, and create a local admin account.
# Run as Administrator.

# --- Configurable Section ---
$LogFile = Join-Path $PSScriptRoot "setup_log.txt"

# --- Logging Function ---
function Log {
    param([string]$msg)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$timestamp $msg"
    Write-Host $entry
    Add-Content -Path $LogFile -Value $entry
}

# --- Step 1: Ask if user wants to reset Windows ---
Log "Script started."
Write-Host "Do you want to reset this PC? (Y/N)"
$doReset = Read-Host
if ($doReset -eq 'Y') {
    Log "User chose to reset the PC."
    Write-Host "About to reset this PC. This will remove all apps and settings."
    Write-Host "Choose reset type: Local (L) or Cloud (C)? (L/C)"
    $resetType = Read-Host
    Write-Host "Press Y to continue or any other key to abort."
    $input = Read-Host
    if ($input -ne 'Y') {
        Log "Reset aborted by user."
        Write-Host "Aborted."
        exit
    }
    if ($resetType -eq 'C') {
        Log "Initiating system reset (Cloud Download)."
        systemreset -factoryreset -cloud
    } else {
        Log "Initiating system reset (Local reinstall)."
        systemreset -factoryreset
    }
} else {
    Log "User skipped system reset."
    Write-Host "Do you want to quit (Q) or continue with app and file installation (C)? (Q/C)"
    $nextStep = Read-Host
    if ($nextStep -eq 'Q') {
        Log "User chose to quit after skipping reset."
        Write-Host "Exiting script."
        exit
    } elseif ($nextStep -eq 'C') {
        Log "User chose to continue with app and file installation."
    } else {
        Log "Invalid input after skipping reset. Exiting."
        Write-Host "Invalid input. Exiting script."
        exit
    }
}

# --- Step 2: Install all .exe files in the same folder as this script ---
$scriptFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition
$exeFolder = $scriptFolder
$installed = @()
if (Test-Path $exeFolder) {
    $exes = Get-ChildItem -Path $exeFolder -Filter *.exe
    foreach ($exe in $exes) {
        Log "Installing $($exe.Name)..."
        Write-Host "Installing $($exe.Name)..."
        try {
            Start-Process -FilePath $exe.FullName -ArgumentList "/silent", "/verysilent", "/s", "/qn" -Wait
            Log "$($exe.Name) installed successfully."
            $installed += $exe.Name
        } catch {
            Log "Failed to install $($exe.Name): $_"
        }
    }
} else {
    Log "Installer folder not found: $exeFolder"
    Write-Host "Installer folder not found: $exeFolder"
}

# --- Step 3: Create a local admin account ---
Write-Host "Enter username for new local admin account (default: default):"
$Username = Read-Host
if ([string]::IsNullOrWhiteSpace($Username)) {
    $Username = "default"
}
Write-Host "Enter password for $Username (leave blank for no password):"
$Password = Read-Host -AsSecureString
if ($Password.Length -eq 0) {
    $PasswordPlain = ""
} else {
    $PasswordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
}
if (-not (Get-LocalUser -Name $Username -ErrorAction SilentlyContinue)) {
    Log "Creating user $Username."
    net user $Username $PasswordPlain /add
    net localgroup Administrators $Username /add
    Log "Created local admin account: $Username"
    Write-Host "Created local admin account: $Username"
} else {
    Log "User $Username already exists."
    Write-Host "User $Username already exists."
}

# --- Step 4: Copy files from 'system' folder to user profile if exists ---
$systemFolder = Join-Path $scriptFolder "system"
if (Test-Path $systemFolder) {
    $userProfile = "C:\Users\$Username"
    $folders = Get-ChildItem -Path $systemFolder -Directory
    foreach ($folder in $folders) {
        $targetFolder = Join-Path $userProfile $folder.Name
        if (!(Test-Path $targetFolder)) {
            New-Item -Path $targetFolder -ItemType Directory -Force | Out-Null
        }
        Log "Copying contents of $($folder.FullName) to $targetFolder"
        Copy-Item -Path (Join-Path $folder.FullName "*") -Destination $targetFolder -Recurse -Force
    }
    Log "Finished copying user files from 'system' folder."
}

# --- Step 5: Display summary ---
Write-Host "`n--- Setup Summary ---"
Write-Host "System reset: $doReset"
Write-Host "Installed .exe files:"
$installed | ForEach-Object { Write-Host " - $_" }
Write-Host "Local admin account: $Username"
Write-Host "Log file: $LogFile"
Log "Script completed."
