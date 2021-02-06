. (Join-path $PSScriptRoot '_Settings.ps1')

$ToBranch = 'master'

$currentLocation = Get-Location
foreach ($Target in $targetRepos) {
    write-host $Target -ForegroundColor Green
<#
    Set-Location $Target
    & git checkout -q "$ToBranch"
#>
}
Set-Location $currentLocation
