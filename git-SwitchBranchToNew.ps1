. (Join-path $PSScriptRoot '_Settings.ps1')

$ToBranch = 'JAM-Update-TableNameRenamed-202111'
#Update gitignore setup 20210319
#$ToBranch = 'JAM-update-develop-17.4-20210301'
#Assembly BOM error
#Repr Contract: "Commissions Calculated" cannot be found
$currentLocation = Get-Location
foreach ($Target in $AppJsons) {
    $AppJson = Get-ObjectFromJSON (Join-Path $target.directory.FullName "app.json")
    if (($AppJson.application -eq '19.0.0.0') -and $AppJson.name.Contains('ZS ')) {
        $Workspace = $Target.directory.parent.FullName
        $TargetGit = (Get-ChildItem $Workspace -Recurse -Hidden -Include '.git').Parent.FullName
        if ($TargetGit) {
            Set-Location $TargetGit
            write-host $TargetGit -ForegroundColor Green
            & git checkout -q -b "$ToBranch"
        }
    }
}
Set-Location $currentLocation
