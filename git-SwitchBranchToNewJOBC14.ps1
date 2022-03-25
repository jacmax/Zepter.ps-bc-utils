. (Join-path $PSScriptRoot '_Settings.ps1')

$currentLocation = Get-Location

$target = Get-ChildItem -Path 'd:\DEV-EXT\bc-integration-jo\Integration JO - App' -Filter 'app.json'
$AppJson = Get-ObjectFromJSON (Join-Path $target.directory.FullName "app.json")

$version = [version]$AppJson.version
$version = [version]::New($version.Major, $version.Minor, $version.Build + 1, 0)
$AppJson.version = $version.ToString()

$AppJson | ConvertTo-Json -depth 32 | set-content (Join-Path $target.directory.FullName "app.json")

$ToBranch = "JAM-Build-$($AppJson.version)"
$CommitMsg = "Update Build $($AppJson.version)"

$Workspace = $target.directory.parent.FullName
$TargetGit = (Get-ChildItem $Workspace -Recurse -Hidden -Include '.git').Parent.FullName

if ($TargetGit) {
    Set-Location $TargetGit
    write-host $TargetGit ' Branch:' $ToBranch -ForegroundColor Green
    & git checkout -q -b "$ToBranch"
    & git add *
    & git commit -m "$CommitMsg"
    & git push origin "$ToBranch"
}

Set-Location $currentLocation
