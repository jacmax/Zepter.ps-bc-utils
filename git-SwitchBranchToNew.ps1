. (Join-path $PSScriptRoot '_Settings.ps1')

$currentLocation = Get-Location
foreach ($Target in $AppJsons) {
    $AppJson = Get-ObjectFromJSON (Join-Path $target.directory.FullName "app.json")
    #if ((($AppJson.application -eq '19.0.0.0') -or ($AppJson.application -eq '20.0.0.0')) -and $AppJson.name.Contains('ZS ') -and $AppJson.description.Contains('JAM')) {
    if ((($AppJson.application -eq '19.0.0.0') -or ($AppJson.application -eq '20.0.0.0')) -and $AppJson.name.Contains('ZS ')) { 
        
        <#
        $ToBranch = "JAM-Build-$($AppJson.version)"
        $CommitMsg = "Update Build $($AppJson.version)"
        #>
        
        #$ToBranch = "JAM-AlRules-20220406"
        #$CommitMsg = "Update AL rules"

        #$ToBranch = "JAM-gitignore-20220329"
        #$CommitMsg = "Update gitignore"

        $ToBranch = "JAM-AlRules-Warnings-20220411"
        #$CommitMsg = "AA0194,AA0231,AL0603,AL0719 warnings fix"
        #$CommitMsg = "AL0432 warnings fix"
        $CommitMsg = "Update Build 19.1.0.29"

        #$ToBranch = "JAM-Migration-20220405"
        #$CommitMsg = "Personal Voucher, Commission excluded"

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
