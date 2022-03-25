. (Join-path $PSScriptRoot '_Settings.ps1')

$ToBranch = 'develop'

$currentLocation = Get-Location
foreach ($Target in $AppJsons) {
	$AppJson = Get-ObjectFromJSON (Join-Path $target.directory.FullName "app.json")
	if (($AppJson.application -eq '19.0.0.0') -and $AppJson.name.Contains('ZS ')) {
		$Workspace = $Target.directory.parent.FullName
		$TargetGit = (Get-ChildItem $Workspace -Recurse -Hidden -Include '.git').Parent.FullName
		write-host $TargetGit -ForegroundColor Green
		Set-Location $TargetGit
		& git checkout -q "$ToBranch"
		& git pull -q origin "$ToBranch"
	}
}
Set-Location $currentLocation