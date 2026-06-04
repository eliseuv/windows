<#
.SYNOPSIS
Defines terminal aliases and shortcuts.
.DESCRIPTION
This script sets up convenient aliases for common commands, making terminal usage faster and more efficient.
#>

# Clear terminal screen
Set-Alias c clear

<#
.SYNOPSIS
Navigates up one directory.
#>
function .. { Set-Location .. }

<#
.SYNOPSIS
Navigates to the user's home directory.
#>
function ~ { Set-Location ~ }

# Standard Unix-like aliases for file management
Set-Alias touch New-Item
Set-Alias rm Remove-Item
Set-Alias mv Move-Item

# Map 'l' and 'll' to use 'eza' for modern directory listing
Set-Alias l eza

<#
.SYNOPSIS
Provides a detailed directory listing using eza.
#>
function Get-DetailedList { eza -lah }
Set-Alias ll Get-DetailedList

# Map standard utilities to their Windows equivalents or modern alternatives
Set-Alias grep findstr
Set-Alias gg lazygit

# Cargo update shortcut
Set-Alias cup Update-CargoBinaries

<#
.SYNOPSIS
psmux shortcuts
#>
function Invoke-PsmuxDefault { psmux attach || psmux new-session }
Set-Alias t Invoke-PsmuxDefault

function Invoke-PsmuxAttach { psmux attach -t $args }
Set-Alias ta Invoke-PsmuxAttach

function Invoke-PsmuxNew { psmux new-session }
Set-Alias tn Invoke-PsmuxNew

function Invoke-PsmuxList { psmux list-sessions }
Set-Alias tl Invoke-PsmuxList