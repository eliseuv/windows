function .. {
    Set-Location ..
}
Set-Alias touch New-Item
Set-Alias rm Remove-Item
Set-Alias mv Move-Item
Set-Alias l eza
function Get-DetailedList {
    eza -lah
}
Set-Alias ll Get-DetailedList
Set-Alias grep findstr
Set-Alias gg lazygit