param (
	[String] $ToBranch = 'develop',
	[bool] $Merge = $false
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

				if (git branch --list "JAM-ZSCacheBinCodeField") {
					& git checkout master
					Write-Host 'Deleted: ' $ToBranch -ForegroundColor Red
					& git branch -D develop
				}
			}
			elseif (git branch --list "$ToBranch") {
				Write-Host $ToBranch -ForegroundColor Yellow
				& git checkout "$ToBranch"
			}
			elseif (-not (git branch --list "$ToBranch") -and $Merge) {
				if (git branch --list 'JAM-ZSCacheBinCodeField') {
					Write-Host '>>> JAM-ZSCacheBinCodeField to TEMP / ' $ToBranch -ForegroundColor Red
					& git checkout -B temp master
					& git merge 'JAM-ZSCacheBinCodeField'
					$NewVersion += 1;
					if (git branch --list 'JAM-CtrLedgerEntriesEdit') {
						& git merge 'JAM-CtrLedgerEntriesEdit'
						$NewVersion += 1;
					}
					Write-Host '>>> TEMP to' $ToBranch -ForegroundColor Red
					& git checkout -B $ToBranch master
					& git merge --squash temp
					& git commit -am 'Cache Bin Code field init'
					& git branch -D temp

					$AppJsonFile2 = Get-ChildItem -Path $Target 'app.json'
					$AppJson2 = Get-ObjectFromJSON $AppJsonFile2.FullName
					<#
					if (-not ( Get-Member -InputObject $AppJson2 -Name "preprocessorSymbols" )) {
						Add-Member -InputObject $AppJson2 NoteProperty "preprocessorSymbols" Object[]
						$AppJson2.preprocessorSymbols = @('CLEANBINCODE')
					}
					#>
					$version = New-Object -TypeName System.Version -ArgumentList $AppJson2.version
					$versionNew = [version]::New($version.Major, $version.Minor, $version.Build, $version.Revision + $NewVersion)
					$AppJson2.version = $versionNew.ToString()
					$AppJson2 | ConvertTo-Json -depth 32 | set-content $AppJsonFile2.FullName
					& git commit -am "Update Build $($versionNew.ToString())"
				}
			}
		}
	}
}
Set-Location $currentLocation