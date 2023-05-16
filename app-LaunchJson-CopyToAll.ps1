param (
    [validateset('', 'BC200', 'BC220')]
    [String] $VersionParam = 'BC200',
    [validateset('w1', 'at', 'ca', 'ch', 'cz', 'de', 'fr', 'ru', 'us')]
    [String] $CountryParam = 'w1'
)

. (Join-path $PSScriptRoot '_Settings.ps1')

$LaunchJson = Get-ChildItem -Path $AppFolder launch.json -Recurse
$SettingsJson = Get-ChildItem -Path $AppFolder settings.json -Recurse
$AppFiles = Get-ChildItem -Path "$AppFolder/$VersionParam/$CountryParam" *.app
$AppTestFiles = Get-ChildItem -Path "$AppFolder/$VersionParam/Extension" *.app

Write-host "Base folder: $($AppFolder)"

Write-Host $LaunchJson

Write-Host $AppFiles

if ($LaunchJson) {
    foreach ($Target in $Targets) {
        if ($Target -ne $BaseFolder) {
            $AppJson = Get-ObjectFromJSON (Join-Path $Target "app.json")
            if ($AppJson.application -eq '20.0.0.0') {
                $LaunchJson, $SettingsJson | Copy-Item -Destination (join-path $Target ".vscode") -Force -Verbose
                Remove-Item "$(join-path $Target ".alpackages")\*.app" -Recurse -Force -Verbose
                $AppFiles | Copy-Item -Destination (join-path $Target ".alpackages") -Force -Verbose
                $AppTestFiles | Copy-Item -Destination (join-path $Target ".alpackages") -Force -Verbose
            }
        }
    }
    foreach ($Target in $TestTargets) {
        if ($Target -ne $BaseFolder) {
            $AppJson = Get-ObjectFromJSON (Join-Path $Target "app.json")
            if ($AppJson.application -in '19.0.0.0', '20.0.0.0') {
                $LaunchJson, $SettingsJson | Copy-Item -Destination (join-path $Target ".vscode") -Force -Verbose
            }
        }
    }
}