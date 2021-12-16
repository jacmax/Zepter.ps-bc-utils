. (Join-path $PSScriptRoot '_Settings.ps1')

$ToBranch = 'JAM-Built-19.1.0.18'
$CommitMsg = 'Update built 19.1.0.18'
#$ToBranch = 'JAM-ZSFieldRenamed-20211216'
#$CommitMsg = 'Update ZS field renamed'

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
            & git add *
            & git commit -m "$CommitMsg"
            & git push origin "$ToBranch"
        }
    }
}
Set-Location $currentLocation
