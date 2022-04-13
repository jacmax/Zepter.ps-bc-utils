. (Join-path $PSScriptRoot '_Settings.ps1')

$ToFixBranch = $("JAM-Upgrade-BC20-{0}" -f $(Get-Date -Format "yyyyMMdd-HHmm"))
#$ToFixBranch = "JAM-Upgrade-BC20-20220413-0920"
#$ToFixBranch = "JAM-AlRules-20220406"
#$ToFixBranch = "JAM-gitignore-20220329"
#$ToFixBranch = "JAM-Migration-20220405"

$FixCommitMsg = "Upgrade for BC20"
#$FixCommitMsg = "Update AL rules"
#$FixCommitMsg = "Update gitignore"
#$FixCommitMsg = "AA0194,AA0231,AL0603,AL0719 warnings fix"
#$FixCommitMsg = "AL0432 warnings fix"
#$FixCommitMsg = "Personal Voucher, Commission excluded"

$currentLocation = Get-Location
foreach ($Target in $AppJsons) {
    $AppJson = Get-ObjectFromJSON (Join-Path $target.directory.FullName "app.json")
    #if ((($AppJson.application -eq '19.0.0.0') -or ($AppJson.application -eq '20.0.0.0')) -and $AppJson.name.Contains('ZS ') -and $AppJson.description.Contains('JAM')) {
    if ((($AppJson.application -eq '19.0.0.0') -or ($AppJson.application -eq '20.0.0.0')) -and $AppJson.name.Contains('ZS ')) { 
        
        $ToBranch = $ToFixBranch
        $CommitMsg = $FixCommitMsg

        <#
        $ToBranch = "JAM-Build-$($AppJson.version)"
        $CommitMsg = "Update Build $($AppJson.version)"
        #>
        
        $Workspace = $Target.directory.parent.FullName
        $TargetGit = (Get-ChildItem $Workspace -Recurse -Hidden -Include '.git').Parent.FullName
        if ($TargetGit) {
            Set-Location $TargetGit
            if ($(git status --porcelain)) {
                write-host $TargetGit ' Branch:' $ToBranch -ForegroundColor Green
                
                & git checkout -q -b "$ToBranch"
                & git stage .
                & git commit -m "$CommitMsg"
                & git push origin "$ToBranch"
                
            }
        }

    }
}
Set-Location $currentLocation
