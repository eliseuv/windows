<#
.SYNOPSIS
Environment variable configuration for the dotfiles environment.
.DESCRIPTION
Sets up essential environment variables, default editors, paths, and tool-specific configurations.
#>

# Set the default editor to Visual Studio Code (wait for file to close)
$env:EDITOR = "code --wait"
$env:VISUAL = $env:EDITOR

# Set the default pager to 'bat' with the 'tokyonight_night' theme
$env:PAGER = "bat"
$env:BAT_THEME = "tokyonight_night" 

# -----------------------------------------------------------------------------
# Tool-Specific Configuration
# -----------------------------------------------------------------------------

# Enable backtraces for Rust applications
$env:RUST_BACKTRACE = "1"

# Optimize Python execution by preventing bytecode compilation and unbuffering output
$env:PYTHONDONTWRITEBYTECODE = "1"
$env:PYTHONUNBUFFERED = "1"

# Configure fzf to use ripgrep for faster search, ignoring .git directories
$env:FZF_DEFAULT_COMMAND = "rg --files --hidden --follow --glob '!.git/*'"

# -----------------------------------------------------------------------------
# PATH
# -----------------------------------------------------------------------------

<#
.SYNOPSIS
Helper function to add directories to the system PATH.
.DESCRIPTION
Safely adds a directory to the PATH environment variable only if it exists
and is not already present, preventing duplicate entries.
#>
function Add-ToPath {
    param ([string]$Dir)
    if (Test-Path $Dir) {
        if (($env:PATH -split ';') -notcontains $Dir) {
            $env:PATH = "$Dir;$env:PATH"
        }
    }
}

# Add common local bin directories to the PATH
Add-ToPath (Join-Path $HOME "bin")
Add-ToPath (Join-Path $HOME ".local\bin")

# Add language package managers and toolchains
Add-ToPath (Join-Path $HOME ".cargo\bin")
Add-ToPath (Join-Path $HOME "AppData\Roaming\cabal\bin")
Add-ToPath (Join-Path $HOME "AppData\Local\Programs\Python\Python311\Scripts")