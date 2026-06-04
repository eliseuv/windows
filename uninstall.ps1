<#
.SYNOPSIS
Dotfiles uninstallation and cleanup script.
.DESCRIPTION
Reverses the actions of install.ps1 by removing symlinked or copied configuration files.
Optionally removes packages installed via Scoop and Cargo.
#>

param (
    <#
    .DESCRIPTION
    Pass -RemovePackages to also uninstall packages that were installed via Scoop (from scoopfile.json)
    and Cargo (from cargofile.json). Warning: This will remove packages from your system.
    #>
    [switch]$RemovePackages
)

$RepoRoot = $PSScriptRoot

Write-Host "Starting dotfiles uninstallation..." -ForegroundColor Cyan

<#
.SYNOPSIS
Remove PowerShell Profile
#>
if (Test-Path $PROFILE) {
    Remove-Item $PROFILE -Force -ErrorAction SilentlyContinue
    Write-Host " -> Removed PowerShell Profile ($PROFILE)" -ForegroundColor Green
} else {
    Write-Host " -> PowerShell Profile not found, skipping." -ForegroundColor DarkGray
}

<#
.SYNOPSIS
Remove Windows Terminal Settings
#>
$WTSettingsDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$WTSettingsPath = Join-Path $WTSettingsDir "settings.json"

if (Test-Path $WTSettingsPath) {
    Remove-Item $WTSettingsPath -Force -ErrorAction SilentlyContinue
    Write-Host " -> Removed Windows Terminal settings ($WTSettingsPath)" -ForegroundColor Green
} else {
    Write-Host " -> Windows Terminal settings not found, skipping." -ForegroundColor DarkGray
}

<#
.SYNOPSIS
Remove psmux config
#>
$PsmuxConfigTarget = Join-Path $HOME ".psmux.conf"

if (Test-Path $PsmuxConfigTarget) {
    Remove-Item $PsmuxConfigTarget -Force -ErrorAction SilentlyContinue
    Write-Host " -> Removed psmux config ($PsmuxConfigTarget)" -ForegroundColor Green
} else {
    Write-Host " -> psmux config not found, skipping." -ForegroundColor DarkGray
}

<#
.SYNOPSIS
Optionally Handle Scoop and Cargo Package Uninstallation
#>
if ($RemovePackages) {
    Write-Host "Removing installed packages (-RemovePackages flag detected)..." -ForegroundColor Magenta
    
    # Scoop
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        $ScoopFile = Join-Path $RepoRoot "scoopfile.json"
        if (Test-Path $ScoopFile) {
            Write-Host "Checking for Scoop apps to remove..." -ForegroundColor Cyan
            try {
                $scoopData = Get-Content -Path $ScoopFile -ErrorAction Stop | ConvertFrom-Json
                if ($scoopData.apps) {
                    foreach ($app in $scoopData.apps) {
                        $appName = $app.Name
                        Write-Host "Uninstalling Scoop app: $appName..." -ForegroundColor Yellow
                        scoop uninstall $appName
                    }
                }
            } catch {
                Write-Warning "Could not parse scoopfile.json or uninstall Scoop apps."
            }
        }
    }

    # Cargo
    if (Get-Command cargo -ErrorAction SilentlyContinue) {
        $CargoFile = Join-Path $RepoRoot "cargofile.json"
        if (Test-Path $CargoFile) {
            Write-Host "Checking for Cargo packages to remove..." -ForegroundColor Cyan
            try {
                $cargoData = Get-Content -Path $CargoFile -ErrorAction Stop | ConvertFrom-Json
                if ($cargoData.packages) {
                    foreach ($pkg in $cargoData.packages) {
                        Write-Host "Uninstalling Cargo package: $pkg..." -ForegroundColor Yellow
                        cargo uninstall $pkg
                    }
                }
            } catch {
                Write-Warning "Could not parse cargofile.json or uninstall Cargo packages."
            }
        }
    }
} else {
    Write-Host "Skipping package removal. Use -RemovePackages to uninstall apps and binaries." -ForegroundColor DarkGray
}

Write-Host "Uninstallation complete!" -ForegroundColor Green
