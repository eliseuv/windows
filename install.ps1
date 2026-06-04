<#
.SYNOPSIS
Dotfiles installation and bootstrap script.
.DESCRIPTION
Sets up the user environment by symlinking or copying configuration files,
installing package managers (Scoop, Cargo), and bootstrapping packages
from declarative files (scoopfile.json, cargofile.json).
#>

param (
    <#
    .DESCRIPTION
    Pass -UseSymlinks to force symbolic linking of configuration files. 
    If omitted, defaults to dot-sourcing and copying as a safer fallback.
    #>
    [switch]$UseSymlinks
)

<#
.SYNOPSIS
Robustly resolve the absolute path of the repository
#>
$RepoRoot = $PSScriptRoot

Write-Host "Starting dotfiles installation..." -ForegroundColor Cyan
if ($UseSymlinks) {
    Write-Host "Mode: Symbolic Links (-UseSymlinks flag detected)" -ForegroundColor Magenta
} else {
    Write-Host "Mode: Safe Fallback (Dot-Sourcing & Copying)" -ForegroundColor Magenta
}

<#
.SYNOPSIS
Deploy PowerShell Profile
.DESCRIPTION
Creates the profile directory if it does not exist and either symlinks
the dotfiles main.ps1 or dot-sources it directly within the profile.
#>
$ProfileParent = Split-Path -Parent $PROFILE
if (!(Test-Path $ProfileParent)) { New-Item -ItemType Directory -Path $ProfileParent -Force | Out-Null }

$RepoMainProfile = Join-Path $RepoRoot "powershell\main.ps1"

Remove-Item $PROFILE -ErrorAction SilentlyContinue
if ($UseSymlinks) {
    New-Item -ItemType SymbolicLink -Path $PROFILE -Target $RepoMainProfile -Force | Out-Null
    Write-Host " -> Symlinked PowerShell Profile" -ForegroundColor Green
} else {
    <# Write the execution command directly into the real profile path #>
    $ProfileContent = ". `"$RepoMainProfile`""
    Set-Content -Path $PROFILE -Value $ProfileContent -Force
    Write-Host " -> Dot-Sourced PowerShell Profile" -ForegroundColor Green
}

<#
.SYNOPSIS
Deploy Windows Terminal Settings
.DESCRIPTION
Locates the LocalState directory for Windows Terminal and symlinks or copies
the custom settings.json into it.
#>
$WTSettingsDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$WTSettingsPath = Join-Path $WTSettingsDir "settings.json"
$RepoSettingsPath = Join-Path $RepoRoot "terminal\settings.json"

if (Test-Path $RepoSettingsPath) {
    if (!(Test-Path $WTSettingsDir)) { New-Item -ItemType Directory -Path $WTSettingsDir -Force | Out-Null }
    
    Remove-Item $WTSettingsPath -ErrorAction SilentlyContinue
    if ($UseSymlinks) {
        New-Item -ItemType SymbolicLink -Path $WTSettingsPath -Target $RepoSettingsPath -Force | Out-Null
        Write-Host " -> Symlinked Windows Terminal settings" -ForegroundColor Green
    } else {
        Copy-Item -Path $RepoSettingsPath -Destination $WTSettingsPath -Force
        Write-Host " -> Copied Windows Terminal settings" -ForegroundColor Green
    }
} else {
    Write-Warning "Windows Terminal settings not found in repo at $RepoSettingsPath"
}

<#
.SYNOPSIS
Deploy psmux config
.DESCRIPTION
Symlinks or copies the psmux configuration to ~/.psmux.conf
#>
$PsmuxConfigTarget = Join-Path $HOME ".psmux.conf"
$RepoPsmuxConfig = Join-Path $RepoRoot "psmux\psmux.conf"

if (Test-Path $RepoPsmuxConfig) {
    Remove-Item $PsmuxConfigTarget -ErrorAction SilentlyContinue
    if ($UseSymlinks) {
        New-Item -ItemType SymbolicLink -Path $PsmuxConfigTarget -Target $RepoPsmuxConfig -Force | Out-Null
        Write-Host " -> Symlinked psmux config" -ForegroundColor Green
    } else {
        Copy-Item -Path $RepoPsmuxConfig -Destination $PsmuxConfigTarget -Force
        Write-Host " -> Copied psmux config" -ForegroundColor Green
    }
} else {
    Write-Warning "psmux config not found in repo at $RepoPsmuxConfig"
}

<#
.SYNOPSIS
Handle Scoop Installation & Restore
.DESCRIPTION
Automatically installs Scoop to the user space if missing, and restores
apps from scoopfile.json if available.
#>
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Scoop to user space..." -ForegroundColor Cyan
    Set-ExecutionPolicy RemoteSigned -Scope Process -Force
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

$ScoopFile = Join-Path $RepoRoot "scoopfile.json"
if (Test-Path $ScoopFile) {
    Write-Host "Restoring declarative apps via Scoop..." -ForegroundColor Cyan
    scoop import $ScoopFile
}

<#
.SYNOPSIS
Cargo Update Bootstrap
.DESCRIPTION
Ensures cargo-update is installed and bootstraps Cargo binaries based
on the declarative cargofile.json manifest.
#>
if (Get-Command cargo -ErrorAction SilentlyContinue) {
    Write-Host "Checking for cargo-update..." -ForegroundColor Cyan
    
    $cargoList = cargo install --list | Out-String
    if ($cargoList -notmatch "cargo-update v") {
        Write-Host "cargo-update not found. Compiling and installing..." -ForegroundColor Yellow
        cargo install cargo-update
        Write-Host "cargo-update installed successfully." -ForegroundColor Green
    } else {
        Write-Host "cargo-update is already installed." -ForegroundColor Green
    }

    $CargoFile = Join-Path $RepoRoot "cargofile.json"
    if (Test-Path $CargoFile) {
        Write-Host "Restoring Cargo binaries from cargofile.json..." -ForegroundColor Cyan
        $data = Get-Content $CargoFile | ConvertFrom-Json
        if ($data.packages) {
            foreach ($pkg in $data.packages) {
                Write-Host "Installing Cargo package: $pkg..." -ForegroundColor Cyan
                cargo install $pkg
            }
        }
    }
}