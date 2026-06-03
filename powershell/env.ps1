$env:EDITOR = "code --wait"
$env:VISUAL = $env:EDITOR

$env:PAGER = "bat"
$env:BAT_THEME = "tokyonight_night" 

# -----------------------------------------------------------------------------
# Tool-Specific Configuration
# -----------------------------------------------------------------------------
$env:RUST_BACKTRACE = "1"

$env:PYTHONDONTWRITEBYTECODE = "1"
$env:PYTHONUNBUFFERED = "1"

$env:FZF_DEFAULT_COMMAND = "rg --files --hidden --follow --glob '!.git/*'"

# -----------------------------------------------------------------------------
# PATH
# -----------------------------------------------------------------------------
function Add-ToPath {
    param ([string]$Dir)
    if (Test-Path $Dir) {
        if (($env:PATH -split ';') -notcontains $Dir) {
            $env:PATH = "$Dir;$env:PATH"
        }
    }
}

Add-ToPath (Join-Path $HOME ".local\bin")

Add-ToPath (Join-Path $HOME ".cargo\bin")
Add-ToPath (Join-Path $HOME "AppData\Roaming\cabal\bin")
Add-ToPath (Join-Path $HOME "AppData\Local\Programs\Python\Python311\Scripts")