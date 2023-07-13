. (Join-path $PSScriptRoot '_Settings.ps1')

$ToBranch = 'master'

$currentLocation = Get-Location
foreach ($Target in $Targets) {
	$AppJsonFile = Get-ChildItem -Path $Target 'app.json'
	$AppJson = Get-ObjectFromJSON $AppJsonFile.FullName
	if ((($AppJson.application -eq '14.0.0.0') -or ($AppJson.application -eq '19.0.0.0') -or ($AppJson.application -eq '20.0.0.0')) -and $AppJson.name.Contains('ZS ')) {
		$TargetGit = $AppJsonFile.Directory.Parent.FullName
		$TargetGit = (Get-ChildItem $TargetGit -Recurse -Hidden -Include '.git').Parent.FullName
		if ($null -eq $TargetGit) {
			$TargetGit = $AppJsonFile.Directory.Parent.Parent.FullName
			$TargetGit = (Get-ChildItem $TargetGit -Recurse -Hidden -Include '.git').Parent.FullName
		}
		write-host $AppJson.name $TargetGit -ForegroundColor Green
		if ($TargetGit -ne $TargetGitBefore) {
			$TargetGitBefore = $TargetGit
			Set-Location $TargetGit
			& git checkout -q "$ToBranch"
			& git pull -q origin "$ToBranch"
			& git fetch --all --prune
		}
	}
}
Set-Location $currentLocation
