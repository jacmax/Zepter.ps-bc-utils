. (Join-path $PSScriptRoot '_Settings.ps1')

$mainWorkspace = $Workspace
$currentLocation = Get-Location
foreach ($Target in $AppJsons) {
    $AppJson = Get-ObjectFromJSON (Join-Path $target.directory.FullName "app.json")
    #if (($AppJson.application -eq '19.0.0.0') -and $AppJson.name.Contains('ZS ') -and $AppJson.description.Contains('JAM')) {
    if (($AppJson.application -eq '19.0.0.0') -and $AppJson.name.Contains('ZS ')) { 
        
        $versionOld = [version]$AppJson.version
        $versionNew = [version]::New($versionOld.Major, $versionOld.Minor, $versionOld.Build, $versionOld.Revision + 1)
        $AppJson.version = $versionNew.ToString()

        foreach ($app in $AppJson.dependencies) {
            if ($app.publisher -eq 'Zepter IT') {
                $app.version = $AppJson.version
            }
        }

        #$AppJson.application = '19.0.0.0'
        #$AppJson.propagateDependencies = $false
        #$AppJson.preprocessorSymbols[1] = 'IT'

        $AppJson | ConvertTo-Json -depth 32 | set-content (Join-Path $target.directory.FullName "app.json")
        
        $ToBranch = "JAM-Build-$($AppJson.version)"
        $CommitMsg = "Update Build $($AppJson.version)"

        #$ToBranch = "JAM-AlRules-20220329A"
        #$CommitMsg = "Update AL rules 2"

        #$ToBranch = "JAM-AlRules-OverflowWarnings-20220330"
        #$CommitMsg = "Overflow warnings fix"

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
