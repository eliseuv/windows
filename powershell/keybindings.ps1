Set-PSReadLineOption -EditMode Vi

Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory

Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward