
Write-Host "Make data directory"
# create data directory
New-Item -ItemType File -Path ${HOME}\.repos.csv -ErrorAction SilentlyContinue

Write-Host "you need add bin directory to PATH manually"
