function reload { & $PROFILE }

function scoop-sync {
    Write-Host "Syncing current Scoop state to ~\dotfiles\scoopfile.json..." -ForegroundColor Cyan
    scoop export > "$HOME\dotfiles\scoopfile.json"
    Write-Host "State saved." -ForegroundColor Green
}

function cargo-sync {
    if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
        Write-Warning "Cargo is not available in the current PATH."
        return
    }
    Write-Host "Syncing current Cargo binaries to ~\dotfiles\cargofile.json..." -ForegroundColor Cyan
    $packages = @()
    $cargoList = cargo install --list | Out-String
    foreach ($line in ($cargoList -split "`r?`n")) {
        if ($line -match "^([a-zA-Z0-9\-_]+)\s+v") {
            $packages += $matches[1]
        }
    }
    
    $exportData = @{
        packages = $packages
    }
    
    $exportData | ConvertTo-Json -Depth 3 | Out-File (Join-Path $HOME "dotfiles\cargofile.json") -Encoding utf8
    Write-Host "State saved." -ForegroundColor Green
}

function cargo-bootstrap {
    if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
        Write-Warning "Cargo is not available in the current PATH."
        return
    }
    Write-Host "Bootstrapping Cargo binaries from ~\dotfiles\cargofile.json..." -ForegroundColor Cyan
    $cargofile = Join-Path $HOME "dotfiles\cargofile.json"
    if (Test-Path $cargofile) {
        $data = Get-Content $cargofile | ConvertFrom-Json
        if ($data.packages) {
            foreach ($pkg in $data.packages) {
                Write-Host "Installing Cargo package: $pkg..." -ForegroundColor Cyan
                cargo install $pkg
            }
        }
    } else {
        Write-Warning "cargofile.json not found."
    }
}

function Update-CargoBinaries {
    <#
    .SYNOPSIS
    Smartly updates all globally installed Cargo binaries using cargo-update.
    #>
    if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
        Write-Warning "Cargo is not available in the current PATH."
        return
    }

    $cargoList = cargo install --list | Out-String
    if ($cargoList -notmatch "cargo-update v") {
        Write-Host "Installing 'cargo-update' (required for smart upgrades)..." -ForegroundColor Cyan
        cargo install cargo-update
    }

    Write-Host "Checking registry for Cargo binary updates..." -ForegroundColor Cyan
    cargo install-update -a
}

function update-all {
    Write-Host "=== Updating Scoop Packages ===" -ForegroundColor Magenta
    scoop update *
    
    Write-Host "`n=== Updating Cargo Binaries ===" -ForegroundColor Magenta
    Update-CargoBinaries
    
    Write-Host "`n=== Syncing Declarative State ===" -ForegroundColor Magenta
    scoop export > "$HOME\dotfiles\scoopfile.json"
    Write-Host "scoopfile.json updated." -ForegroundColor Green
}