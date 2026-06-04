function reload { & $PROFILE }

function scoop-sync {
    Write-Host "Syncing current Scoop state to ~\dotfiles\scoopfile.json..." -ForegroundColor Cyan
    scoop export > "$HOME\dotfiles\scoopfile.json"
    Write-Host "State saved." -ForegroundColor Green
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