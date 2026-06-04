# =============================================================================
# install.ps1
# =============================================================================

param (
    # Pass -UseSymlinks to force symbolic linking. 
    # If omitted, defaults to dot-sourcing and copying.
    [switch]$UseSymlinks
)

# Robustly resolve the absolute path of the repository
$RepoRoot = $PSScriptRoot

Write-Host "Starting dotfiles installation..." -ForegroundColor Cyan
if ($UseSymlinks) {
    Write-Host "Mode: Symbolic Links (-UseSymlinks flag detected)" -ForegroundColor Magenta
} else {
    Write-Host "Mode: Safe Fallback (Dot-Sourcing & Copying)" -ForegroundColor Magenta
}

# -----------------------------------------------------------------------------
# Deploy PowerShell Profile
# -----------------------------------------------------------------------------
$ProfileParent = Split-Path -Parent $PROFILE
if (!(Test-Path $ProfileParent)) { New-Item -ItemType Directory -Path $ProfileParent -Force | Out-Null }

$RepoMainProfile = Join-Path $RepoRoot "powershell\main.ps1"

if ($UseSymlinks) {
    Remove-Item $PROFILE -ErrorAction SilentlyContinue
    New-Item -ItemType SymbolicLink -Path $PROFILE -Target $RepoMainProfile -Force | Out-Null
    Write-Host " -> Symlinked PowerShell Profile" -ForegroundColor Green
} else {
    # Write the execution command directly into the real profile path
    $ProfileContent = ". `"$RepoMainProfile`""
    Set-Content -Path $PROFILE -Value $ProfileContent -Force
    Write-Host " -> Dot-Sourced PowerShell Profile" -ForegroundColor Green
}

# -----------------------------------------------------------------------------
# Deploy Windows Terminal Settings
# -----------------------------------------------------------------------------
$WTSettingsDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$WTSettingsPath = Join-Path $WTSettingsDir "settings.json"
$RepoSettingsPath = Join-Path $RepoRoot "terminal\settings.json"

if (Test-Path $RepoSettingsPath) {
    if (!(Test-Path $WTSettingsDir)) { New-Item -ItemType Directory -Path $WTSettingsDir -Force | Out-Null }
    
    if ($UseSymlinks) {
        Remove-Item $WTSettingsPath -ErrorAction SilentlyContinue
        New-Item -ItemType SymbolicLink -Path $WTSettingsPath -Target $RepoSettingsPath -Force | Out-Null
        Write-Host " -> Symlinked Windows Terminal settings" -ForegroundColor Green
    } else {
        Copy-Item -Path $RepoSettingsPath -Destination $WTSettingsPath -Force
        Write-Host " -> Copied Windows Terminal settings" -ForegroundColor Green
    }
} else {
    Write-Warning "Windows Terminal settings not found in repo at $RepoSettingsPath"
}

# -----------------------------------------------------------------------------
# Handle Scoop Installation & Restore
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# Cargo Update Bootstrap
# -----------------------------------------------------------------------------
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