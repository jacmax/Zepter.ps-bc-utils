
param (
    [validateset('Version', 'Fix')]
    [String] $Type = 'Fix'
)

. (Join-path $PSScriptRoot '_Settings.ps1')

$ToFixDate = $(Get-Date -Format "yyyyMMdd-HHmm")
#$ToFixBranch = $("JAM-Upgrade-BC20-{0}" -f $ToFixDate)
$ToFixBranch = $("JAM-Update-BC20-{0}" -f $ToFixDate)
#$ToFixBranch = $("JAM-BC17-348-{0}" -f $ToFixDate)
#$ToFixBranch = "JAM-Upgrade-BC20-20220413-0920"
#$ToFixBranch = "JAM-AlRules-20220406"
#$ToFixBranch = "JAM-gitignore-20220329"
#$ToFixBranch = "JAM-Migration-20220405"

#$FixCommitMsg = "Upgrade for BC20"
#$FixCommitMsg = "New fields were added in setup page"
#$FixCommitMsg = "Update AL rules"
#$FixCommitMsg = "Update gitignore"
#$FixCommitMsg = "AA0194,AA0231,AL0603,AL0719 warnings fix"
#$FixCommitMsg = "Personal Voucher, Commission excluded"
#$FixCommitMsg = "AS0011, prefix in enums was added, warnings fix"
$FixCommitMsg = "The Caption field was updated"
$FixCommitMsg = "AA0021 warnings fix"
$FixCommitMsg = "Update the 'Closed Base Calendar Unit' field"
$FixCommitMsg = "Code cleaning"
$FixCommitMsg = "Update for Tool Update Prices on Ctr."

if ($Type -eq 'Fix') {
    $ToBranch = $ToFixBranch
    $CommitMsg = $FixCommitMsg
}
$currentLocation = Get-Location
foreach ($Target in $AppJsons) {
    $AppJson = Get-ObjectFromJSON (Join-Path $target.directory.FullName "app.json")
    #if ((($AppJson.application -eq '19.0.0.0') -or ($AppJson.application -eq '20.0.0.0')) -and $AppJson.name.Contains('ZS ') -and $AppJson.description.Contains('JAM')) {
    if ((($AppJson.application -eq '19.0.0.0') -or ($AppJson.application -eq '20.0.0.0')) -and $AppJson.name.Contains('ZS ')) {

        if ($Type -eq 'Version') {
            $ToBranch = "JAM-Build-$($AppJson.version)-$ToFixDate"
            $CommitMsg = "Update Build $($AppJson.version)"
        }

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
