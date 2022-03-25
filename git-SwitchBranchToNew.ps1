. (Join-path $PSScriptRoot '_Settings.ps1')

$currentLocation = Get-Location
foreach ($Target in $AppJsons) {
    $AppJson = Get-ObjectFromJSON (Join-Path $target.directory.FullName "app.json")
    if (($AppJson.application -eq '19.0.0.0') -and $AppJson.name.Contains('ZS ') -and $AppJson.description.Contains('JAM')) {    
        <#         
        $version = [version]$AppJson.version
        $version = [version]::New($version.Major, $version.Minor, $version.Build, 19) #$version.Revision + 1)
        $AppJson.version = $version.ToString()

        foreach ($app in $AppJson.dependencies) {
            if ($app.publisher -eq 'Zepter IT') {
                $app.version = $AppJson.version
            }
        }
        $AppJson.application = '19.0.0.0'

        $AppJson | ConvertTo-Json -depth 32 | set-content (Join-Path $target.directory.FullName "app.json")
        
        $ToBranch = "JAM-Build-$($AppJson.version)"
        $CommitMsg = "Update Build $($AppJson.version)"
        #>

        $ToBranch = "JAM-AlRules-20220324"
        $CommitMsg = "Update AL rules"

        $ToBranch = "JAM-AlRules-UnusedVaraible-20220325"
        $CommitMsg = "Unused variable fix"

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
Set-Location $currentLocation
