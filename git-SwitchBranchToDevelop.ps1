. (Join-path $PSScriptRoot '_Settings.ps1')

$ToBranch = 'develop'

$currentLocation = Get-Location
foreach ($Target in $TargetRepos) {
	write-host $Target -ForegroundColor Green
	Set-Location $Target
	& git checkout -q "$ToBranch"
	& git pull -q origin "$ToBranch"
}
Set-Location $currentLocation