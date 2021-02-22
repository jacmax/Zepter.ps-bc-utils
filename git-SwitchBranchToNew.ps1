. (Join-path $PSScriptRoot '_Settings.ps1')

$ToBranch = 'JAM-update-RepContractListPage-20210222'

$currentLocation = Get-Location
foreach ($Target in $TargetRepos) {
    write-host $Target -ForegroundColor Green
    Set-Location $Target
    & git checkout -q -b "$ToBranch"
}
Set-Location $currentLocation
