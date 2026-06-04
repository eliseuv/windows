<#
.SYNOPSIS
Main entry point for the PowerShell profile.
.DESCRIPTION
This script orchestrates the loading of all other profile modules and initializes core tools
like Starship and Zoxide. It is typically dot-sourced from the user's primary profile.
#>

# Determine the dotfiles directory robustly
$ScriptItem = Get-Item $PSCommandPath
if ($ScriptItem.Target) {
    # If symlinked, resolve to the actual target directory
    $DotfilesDir = Split-Path -Parent $ScriptItem.Target
} else {
    # Otherwise, use the script's directory
    $DotfilesDir = $PSScriptRoot
}

# Define the list of modules to load
$Modules = @(
    "env.ps1",
    "aliases.ps1",
    "functions.ps1",
    "maintenance.ps1",
    "keybindings.ps1"
)

# Load each module sequentially
foreach ($file in $Modules) {
    $filePath = Join-Path $DotfilesDir $file
    if (Test-Path $filePath) {
        . $filePath
    } else {
        Write-Warning "Profile module not found: $filePath"
    }
}

# =============================================================================
# Tools Initialization
# =============================================================================

# Initialize Starship prompt if installed
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# Initialize Zoxide (smarter cd) if installed
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}