param (
    [String] $DeleteBranch = '',
    [bool] $DeleteMerged = $false
)
. (Join-path $PSScriptRoot '_Settings.ps1')

$currentLocation = Get-Location
foreach ($Target in $Targets) {
    $AppJsonFile = Get-ChildItem -Path $Target 'app.json'
    $AppJson = Get-ObjectFromJSON $AppJsonFile.FullName
    if ((($AppJson.application -eq '14.0.0.0') -or ($AppJson.application -eq '19.0.0.0') -or ($AppJson.application -eq '20.0.0.0')) -and $AppJson.name.Contains('ZS ')) {
        $TargetGit = $AppJsonFile.Directory.Parent.FullName
        $TargetGit = (Get-ChildItem $TargetGit -Recurse -Hidden -Include '.git').Parent.FullName
        if (-not $TargetGit) {
            $TargetGit = $AppJsonFile.Directory.Parent.Parent.FullName
            $TargetGit = (Get-ChildItem $TargetGit -Recurse -Hidden -Include '.git').Parent.FullName
        }
        write-host $AppJson.name $TargetGit -ForegroundColor Green
        if ($TargetGit -ne $TargetGitBefore) {
            $TargetGitBefore = $TargetGit
            Set-Location $TargetGit
            if ($DeleteMerged) {
                & git checkout -q "master"
                $branches = git branch --list --merged | Where-Object { ($_ -ne '* master') -and ($_ -ne '  master') }
                foreach ($branch in $branches) {
                    Write-Host $branch -ForegroundColor Red
                    & git branch -d $branch.TrimStart()
                }
            }
            if (($DeleteBranch) -and (git show-ref --heads origin "$DeleteBranch")) {
                Write-Host $DeleteBranch -ForegroundColor Red
                & git checkout -q "master"
                & git branch -D $DeleteBranch
            }
            if (-not $DeleteMerged) {
                $branches = git branch --list --no-merged | Where-Object { ($_ -ne '* master') -and ($_ -ne '  master') }
                foreach ($branch in $branches) {
                    Write-Host $branch -ForegroundColor Yellow
                }

            }
        }
    }
}
Set-Location $currentLocation