<#
.SYNOPSIS
General utility functions for the dotfiles environment.
.DESCRIPTION
Contains general-purpose commands that don't fit into a specific category like maintenance or aliases.
#>

<#
.SYNOPSIS
Reloads the PowerShell profile.
.DESCRIPTION
Dot-sources the current PowerShell profile script to apply any changes made to the configuration
without needing to restart the terminal.
#>
function reload { & $PROFILE }

<#
.SYNOPSIS
Installs a compiled tool into the user's home bin directory (~/bin).
.DESCRIPTION
Can be used to copy an existing executable to ~/bin, or if run in a Rust 
project directory without arguments, will use cargo to install the binary to ~/bin.
#>
function Install-LocalTool {
    param (
        [Parameter(Mandatory=$false)]
        [string]$Path
    )

    $binDir = Join-Path $HOME "bin"
    if (-not (Test-Path $binDir)) {
        New-Item -ItemType Directory -Path $binDir | Out-Null
    }

    if ([string]::IsNullOrWhiteSpace($Path)) {
        if (Test-Path "Cargo.toml") {
            Write-Host "Cargo.toml found. Installing via cargo to $binDir..."
            cargo install --path . --root $HOME
        } else {
            Write-Warning "Please provide a path to an executable, or run this in a Cargo project directory."
        }
    } else {
        if (Test-Path $Path -PathType Leaf) {
            $dest = Join-Path $binDir (Split-Path $Path -Leaf)
            Copy-Item -Path $Path -Destination $dest -Force
            Write-Host "Installed $(Split-Path $Path -Leaf) to $binDir"
        } else {
            Write-Error "Executable file not found: $Path"
        }
    }
}