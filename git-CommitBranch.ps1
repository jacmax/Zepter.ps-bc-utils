. (Join-path $PSScriptRoot '_Settings.ps1')

$Commit = 'Update settings 20210309'

$currentLocation = Get-Location
foreach ($Target in $TargetRepos) {
    write-host $Target -ForegroundColor Green
    Set-Location $Target
    & git add --all
    & git commit -m "$Commit"
}
Set-Location $currentLocation
