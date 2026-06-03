$ScriptItem = Get-Item $PSCommandPath
if ($ScriptItem.Target) {
    $DotfilesDir = Split-Path -Parent $ScriptItem.Target
} else {
    $DotfilesDir = $PSScriptRoot
}

$Modules = @(
    "env.ps1",
    "aliases.ps1",
    "functions.ps1",
    "keybindings.ps1"
)

foreach ($file in $Modules) {
    $filePath = Join-Path $DotfilesDir $file
    if (Test-Path $filePath) {
        . $filePath
    } else {
        Write-Warning "Profile module not found: $filePath"
    }
}

# =============================================================================
# Tools
# =============================================================================

# Starship
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# Zoxide
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}