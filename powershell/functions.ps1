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