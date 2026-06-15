<#
.SYNOPSIS
Maintenance, synchronization, and bootstrapping functions for the dotfiles environment.
#>

function scoop-sync {
    <#
    .SYNOPSIS
    Syncs the current Scoop state.
    .DESCRIPTION
    Exports the current list of installed Scoop apps and buckets to scoopfile.json
    located in the dotfiles directory, allowing for declarative restorations later.
    #>
    Write-Host "Syncing current Scoop state to ~\dotfiles\scoopfile.json..." -ForegroundColor Cyan
    scoop export > "$HOME\dotfiles\scoopfile.json"
    Write-Host "State saved." -ForegroundColor Green
}

function cargo-sync {
    <#
    .SYNOPSIS
    Syncs the current Cargo binaries state.
    .DESCRIPTION
    Parses the output of 'cargo install --list' to find all installed binaries and saves
    the package names to cargofile.json located in the dotfiles directory.
    #>
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
    <#
    .SYNOPSIS
    Bootstraps Cargo binaries from declarative state.
    .DESCRIPTION
    Reads the list of packages stored in cargofile.json and installs each of them
    using 'cargo install'. Helpful for setting up a fresh environment.
    #>
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
    Smartly updates all globally installed Cargo binaries.
    .DESCRIPTION
    Uses 'cargo-update' to check for updates and upgrade installed Cargo binaries. 
    It will automatically install 'cargo-update' if it is not present.
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

function update-rustup {
    <#
    .SYNOPSIS
    Updates rustup and installed Rust toolchains.
    .DESCRIPTION
    Runs 'rustup self update' to update the rustup executable itself, followed by
    'rustup update' to ensure all installed toolchains are fully updated.
    #>
    if (-not (Get-Command rustup -ErrorAction SilentlyContinue)) {
        Write-Warning "Rustup is not available in the current PATH."
        return
    }
    Write-Host "`n=== Updating Rustup and Toolchains ===" -ForegroundColor Magenta
    Write-Host "Updating Rustup itself..." -ForegroundColor Cyan
    rustup self update
    Write-Host "Updating Rust toolchains..." -ForegroundColor Cyan
    rustup update
}

function Update-LocalTools {
    <#
    .SYNOPSIS
    Updates all local tools tracked in localtools.json.
    .DESCRIPTION
    Reads localtools.json and updates each tracked tool. Cargo projects are rebuilt and reinstalled,
    while binary paths are simply re-copied to ~/bin.
    #>
    Write-Host "`n=== Updating Local Tools ===" -ForegroundColor Magenta
    $lockfile = Join-Path $HOME "dotfiles\localtools.json"
    $binDir = Join-Path $HOME "bin"
    
    if (-not (Test-Path $lockfile)) {
        Write-Host "No local tools to update (localtools.json not found)."
        return
    }

    $content = Get-Content $lockfile -Raw
    if ([string]::IsNullOrWhiteSpace($content)) {
        Write-Host "localtools.json is empty."
        return
    }

    $localTools = $content | ConvertFrom-Json
    if ($localTools -isnot [array]) { $localTools = @($localTools) }

    foreach ($tool in $localTools) {
        if ($tool.type -eq 'cargo') {
            if (Test-Path $tool.path) {
                Write-Host "Updating local Cargo tool from: $($tool.path)" -ForegroundColor Cyan
                Push-Location $tool.path
                try {
                    cargo install --path . --root $HOME
                } finally {
                    Pop-Location
                }
            } else {
                Write-Warning "Cargo project path not found: $($tool.path)"
            }
        } elseif ($tool.type -eq 'binary') {
            if (Test-Path $tool.path -PathType Leaf) {
                Write-Host "Updating local binary tool from: $($tool.path)" -ForegroundColor Cyan
                $dest = Join-Path $binDir (Split-Path $tool.path -Leaf)
                Copy-Item -Path $tool.path -Destination $dest -Force
            } else {
                Write-Warning "Binary path not found: $($tool.path)"
            }
        }
    }
    Write-Host "Local tools updated." -ForegroundColor Green
}

function update-all {
    <#
    .SYNOPSIS
    Runs all system updates and syncs declarative state.
    .DESCRIPTION
    A comprehensive maintenance script that updates Scoop packages, Rust toolchains,
    and Cargo binaries. It then syncs the newly updated state to scoopfile.json and
    cargofile.json.
    #>
    Write-Host "=== Updating Scoop Packages ===" -ForegroundColor Magenta
    scoop update *
    
    update-rustup
    
    Write-Host "`n=== Updating Cargo Binaries ===" -ForegroundColor Magenta
    Update-CargoBinaries
    
    Update-LocalTools
    
    Write-Host "`n=== Syncing Declarative State ===" -ForegroundColor Magenta
    scoop export > "$HOME\dotfiles\scoopfile.json"
    Write-Host "scoopfile.json updated." -ForegroundColor Green
    
    cargo-sync
}
