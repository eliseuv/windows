<#
.SYNOPSIS
PSReadLine keybindings configuration.
.DESCRIPTION
Configures terminal input behavior, history search shortcuts, and editing modes using PSReadLine.
#>

# Enable Vi-mode for command-line editing
Set-PSReadLineOption -EditMode Vi

# Bind Ctrl+r to reverse search through command history
Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory

# Bind Up/Down arrows to search history based on current prefix
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward