function reload { & $PROFILE }

function scoop-sync {
    Write-Host "Syncing current Scoop state to ~\dotfiles\scoopfile.json..." -ForegroundColor Cyan
    scoop export > ~\dotfiles\scoopfile.json
    Write-Host "State saved." -ForegroundColor Green
}