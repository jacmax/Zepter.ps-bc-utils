. (Join-path $PSScriptRoot '_Settings.ps1')

$ToBranch = 'JAM-update-20210315'
#$ToBranch = 'JAM-update-develop-17.4-20210301'
#Assembly BOM error
#Repr Contract: "Commissions Calculated" cannot be found
#Update 20210315
$currentLocation = Get-Location
foreach ($Target in $TargetRepos) {
    write-host $Target -ForegroundColor Green
    Set-Location $Target
    & git checkout -q -b "$ToBranch"
}
Set-Location $currentLocation
