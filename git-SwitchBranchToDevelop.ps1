param (
	[String] $ToBranch = 'develop'
)
. (Join-path $PSScriptRoot '_Settings.ps1')

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

			write-host $AppJson.name $TargetGit "$ToBranch" -ForegroundColor Yellow
			git branch --list

			if (git ls-remote --heads origin "$ToBranch") {
				Write-Host $ToBranch -ForegroundColor Cyan
				#& git checkout -q "master"
				#& git branch -d "$ToBranch"
				& git checkout -q "$ToBranch"
				& git pull -q origin "$ToBranch"
				& git reset --hard origin/$ToBranch
				& git fetch --all --prune
			}
			elseif (git show-ref --heads origin "$ToBranch") {
				Write-Host $ToBranch -ForegroundColor Red
				#& git branch -d "$ToBranch"
				#& git checkout -b "$ToBranch" master
				& git checkout "$ToBranch"
			}
			elseif (git branch --list "$ToBranch") {
				Write-Host $ToBranch
				& git checkout "$ToBranch"
			}
		}
	}
}
Set-Location $currentLocation