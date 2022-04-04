. (Join-path $PSScriptRoot '_Settings.ps1')

$clean19 = $application -eq '19.0.0.0'
$mainWorkspace = $Workspace
$currentLocation = Get-Location
foreach ($Target in $AppJsons) {
    $AppJson = Get-ObjectFromJSON (Join-Path $target.directory.FullName "app.json")
    #if ((($AppJson.application -eq '19.0.0.0') -or ($AppJson.application -eq '20.0.0.0')) -and $AppJson.name.Contains('ZS ') -and $AppJson.description.Contains('JAM')) {
    if ((($AppJson.application -eq '19.0.0.0') -or ($AppJson.application -eq '20.0.0.0')) -and $AppJson.name.Contains('ZS ')) { 
        
        $versionOld = [version]$AppJson.version

        if ($clean19) {
            $versionOldMajor = 19
            $versionOldMinor = 1
            $AppJson.application = '19.0.0.0'
            $AppJson.platform = '19.0.0.0'
            $AppJson.preprocessorSymbols[0] = 'CLEAN19'
            $AppJson.preprocessorSymbols[1] = 'IT'
        }
        else {
            $versionOldMajor = 20
            $versionOldMinor = 0
            $AppJson.application = '20.0.0.0'
            $AppJson.platform = '20.0.0.0'
            $AppJson.preprocessorSymbols[0] = 'CLEAN20'
            $AppJson.preprocessorSymbols[1] = 'W1'
        }

        if ($AppJson.name -eq 'ZS Integration IT') {
            $versionOldMajor = 19
            $versionOldMinor = 1
            $AppJson.application = '19.0.0.0'
            $AppJson.platform = '19.0.0.0'
            $AppJson.preprocessorSymbols[0] = 'CLEAN19'
            $AppJson.preprocessorSymbols[1] = 'IT'
        }

        $versionOld = [version]::New($versionOldMajor, $versionOldMinor, $versionOld.Build, $versionOld.Revision)
        $versionNew = [version]::New($versionOld.Major, $versionOld.Minor, $versionOld.Build, $versionOld.Revision)
        
        $AppJson.version = $versionNew.ToString()

        foreach ($app in $AppJson.dependencies) {
            if ($app.publisher -eq 'Zepter IT') {
                $app.version = $AppJson.version
            }
        }

        $AppJson.propagateDependencies = $false
        $AppJson | ConvertTo-Json -depth 32 | set-content (Join-Path $target.directory.FullName "app.json")

        <#
        $ToBranch = "JAM-Build-$($AppJson.version)"
        $CommitMsg = "Update Build $($AppJson.version)"
        #>
        
        #$ToBranch = "JAM-AlRules-20220329A"
        #$CommitMsg = "Update AL rules 2"

        $ToBranch = "JAM-AlRules-Warnings-20220404"
        $CommitMsg = "AA0194,AL0603 warnings fix"

        #$ToBranch = "JAM-gitignore-20220329"
        #$CommitMsg = "Update gitignore"

        $Workspace = $Target.directory.parent.FullName
        $TargetGit = (Get-ChildItem $Workspace -Recurse -Hidden -Include '.git').Parent.FullName
        if ($TargetGit) {
            Set-Location $TargetGit
            write-host $TargetGit ' Branch:' $ToBranch -ForegroundColor Green
            
            & git checkout -q -b "$ToBranch"
            & git add *
            & git commit -m "$CommitMsg"
            & git push origin "$ToBranch"
            
        }

    }
}

if (($versionOld) -and ($versionNew)) {
    $Extenstion = Get-Content -Path (Join-Path $mainWorkspace 'ps-bc-utils\NavExtensions.ps1')
    $Extenstion = $Extenstion.replace($versionOld.ToString(), $versionNew.ToString())
    $Extenstion | set-content (Join-Path $mainWorkspace 'ps-bc-utils\NavExtensions.ps1')
}

Set-Location $currentLocation
