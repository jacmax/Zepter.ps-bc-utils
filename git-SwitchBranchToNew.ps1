. (Join-path $PSScriptRoot '_Settings.ps1')

$ToBranch = 'JAM-update-RoleCenter-20210302'
#$ToBranch = 'JAM-update-develop-17.4-20210301'
#Assembly BOM error
#Repr Contract: "Commissions Calculated" cannot be found

$currentLocation = Get-Location
foreach ($Target in $TargetRepos) {
    write-host $Target -ForegroundColor Green
    Set-Location $Target
    & git checkout -q -b "$ToBranch"
}
Set-Location $currentLocation
