$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    # Relaunch the script with Administrator privileges
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$ProfileDir = Split-Path -Parent $PROFILE
if (!(Test-Path $ProfileDir)) { New-Item -ItemType Directory -Path $ProfileDir -Force }

# Link the main profile
New-Item -ItemType SymbolicLink -Path $PROFILE -Target "~\dotfiles\powershell\main.ps1" -Force

# Link Starship config
$ConfigDir = "$HOME\.config"
if (!(Test-Path $ConfigDir)) { New-Item -ItemType Directory -Path $ConfigDir -Force }
New-Item -ItemType SymbolicLink -Path "$ConfigDir\starship.toml" -Target "~\dotfiles\starship.toml" -Force

# Windows Terminal config
$WTSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
New-Item -ItemType SymbolicLink -Path $WTSettings -Target "~\dotfiles\terminal\settings.json" -Force

# =============================================================================
# Scoop Bootstrap
# =============================================================================

Write-Host "Checking for Scoop package manager..." -ForegroundColor Cyan

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Scoop not found. Installing Scoop..." -ForegroundColor Yellow
    
    Set-ExecutionPolicy RemoteSigned -Scope Process -Force
    
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    
    Write-Host "Scoop installed successfully." -ForegroundColor Green
} else {
    Write-Host "Scoop is already installed." -ForegroundColor Green
}

$ScoopFile = "~\dotfiles\scoopfile.json"
if (Test-Path $ScoopFile) {
    Write-Host "Restoring packages from scoopfile.json..." -ForegroundColor Cyan
    
    scoop import $ScoopFile
    
    Write-Host "Package restoration complete." -ForegroundColor Green
}