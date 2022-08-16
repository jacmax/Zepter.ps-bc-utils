. (Join-path $PSScriptRoot '_Settings.ps1')

$currentLocation = Get-Location

$target = Get-ChildItem -Path 'd:\DEV-EXT\bc-integration-hu\Integration HU - App' -Filter 'app.json'
$AppJson = Get-ObjectFromJSON (Join-Path $target.directory.FullName "app.json")

$Workspace = $target.directory.parent.FullName
$TargetGit = (Get-ChildItem $Workspace -Recurse -Hidden -Include '.git').Parent.FullName

if ($TargetGit) {
    Set-Location $TargetGit

    $CurrentBranch = git branch --show-current
    write-host 'Current Branch:' $CurrentBranch -ForegroundColor Green
    
    $version = [version]$AppJson.version
    if ($CurrentBranch -eq 'master')
    {
        $version = [version]::New($version.Major, $version.Minor, $version.Build + 1, 0)
    }
    if ($CurrentBranch -eq 'develop')
    {
        #$version = [version]::New($version.Major, $version.Minor, $version.Build + 1, 1)
    }
    $AppJson.version = $version.ToString()

    $AppJson | ConvertTo-Json -depth 32 | set-content (Join-Path $target.directory.FullName "app.json")

    $ToBranch = "JAM-Build-$($AppJson.version)"
    $CommitMsg = "Update Build $($AppJson.version)"

    write-host $TargetGit -ForegroundColor Green
    write-host 'New Branch:' $ToBranch -ForegroundColor Green
    & git checkout -q -b "$ToBranch" $CurrentBranch
    & git add *
    & git commit -m "$CommitMsg"
    & git push origin "$ToBranch"
}

Set-Location $currentLocation
