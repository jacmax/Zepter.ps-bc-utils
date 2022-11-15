param (
    [validateset('BC190', 'BC200', 'BC201', 'BC+', 'BC++')]
    [String] $Type = 'BC200',
    [validateset('W1', 'IT', 'CZ')]
    [String] $Country = 'W1'
)

. (Join-path $PSScriptRoot '_Settings.ps1')

$clean190 = $Type -eq 'BC190'
$clean200 = $Type -eq 'BC200'
$clean201 = $Type -eq 'BC201'
$newVersion = $Type -eq 'BC+'
$newVersionLive = $Type -eq 'BC++'

if ($newVersion -or $newVersionLive) {
    $clean200 = $true
}

Write-Host $Country -NoNewline

$SettingsJson = Get-ObjectFromJSON (Join-Path $Workspace "ps-bc-utils/_SecretSettings.json")
if ($clean190) {
    $SettingsJson.version = '19.5'
}
if ($clean200) {
    $SettingsJson.version = '20.0'
}
if ($clean201) {
    $SettingsJson.version = '20.1'
}
$SettingsJson.country = $Country.ToLower()

Write-Host " " $SettingsJson.version -NoNewline
Write-Host " " $SettingsJson.country

$mainWorkspace = $Workspace
$currentLocation = Get-Location
foreach ($Target in $AppJsons) {
    $AppJson = Get-ObjectFromJSON (Join-Path $target.directory.FullName "app.json")
    if ((($AppJson.application -eq '19.0.0.0') -or ($AppJson.application -eq '20.0.0.0')) -and $AppJson.name.Contains('ZS ')) {

        $versionOld = [version]$AppJson.version
        $versionOldMajor = 19
        $versionOldMinor = 1

        if ($clean190) {
            $versionOldMajor = 19
            $versionOldMinor = 1
            $AppJson.runtime = '8.0'
            $AppJson.application = '19.0.0.0'
            $AppJson.platform = '19.0.0.0'
            $AppJson.preprocessorSymbols[0] = 'CLEAN19'
            $AppJson.preprocessorSymbols[1] = $Country
        }
        elseif (($clean200) -or ($clean201)) {
            $versionOldMajor = 20
            $versionOldMinor = 0
            if ($clean201) {
                $versionOldMinor = 1
            }
            $AppJson.runtime = '9.0'
            $AppJson.application = '20.0.0.0'
            $AppJson.platform = '20.0.0.0'
            $AppJson.preprocessorSymbols = 'CLEAN20', 'W1'
        }

        if (($AppJson.name -eq 'ZS Integration IT')) {
            $versionOldMajor = 19
            $AppJson.preprocessorSymbols[0] = 'CLEAN19'
            $versionOldMinor = 1
            $AppJson.application = '19.0.0.0'
            $AppJson.platform = '19.0.0.0'
            $AppJson.preprocessorSymbols[1] = 'IT'
        }

        if ((($AppJson.name -eq 'ZS Sales Contract') -or ($AppJson.name -eq 'ZS Data Migration')) -and ($Country -eq 'CZ')) {
            $AppJson.preprocessorSymbols += $Country
        }

        $versionOld = [version]::New($versionOldMajor, $versionOldMinor, $versionOld.Build, $versionOld.Revision)
        if ($newVersion) {
            $versionNew = [version]::New($versionOld.Major, $versionOld.Minor, $versionOld.Build, $versionOld.Revision + 1)
        }
        elseif ($newVersionLive) {
            $versionNew = [version]::New($versionOld.Major, $versionOld.Minor, $versionOld.Build + 1, 0)
        }
        else {
            $versionNew = [version]::New($versionOld.Major, $versionOld.Minor, $versionOld.Build, $versionOld.Revision)
        }
        $AppJson.version = $versionNew.ToString()

        foreach ($app in $AppJson.dependencies) {
            if ($app.publisher -eq 'Zepter IT') {
                $app.version = $AppJson.version
            }
        }

        foreach ($app in $AppJson.dependencies) {
            if ($app.publisher -eq 'Microsoft') {
                $app.version = $AppJson.platform
            }
        }

        $AppJson.propagateDependencies = $false
        $AppJson | ConvertTo-Json -depth 32 | set-content (Join-Path $target.directory.FullName "app.json")

        Write-Host $AppJson.application $AppJson.version $AppJson.name
    }
}

if (($versionOld) -and ($versionNew)) {
    Write-Host $versionOld.ToString() $versionNew.ToString()
    $Extenstion = Get-Content -Path (Join-Path $mainWorkspace 'ps-bc-utils\NavExtensions.ps1')
    $Extenstion = $Extenstion.replace($versionOld.ToString(), $versionNew.ToString())
    if ($clean190) {
        $versionOldMajor = 20
        $versionOldMinor = 0
    }
    elseif (($clean200) -or ($clean201)) {
        $versionOldMajor = 19
        $versionOldMinor = 1
    }
    $versionOld = [version]::New($versionOldMajor, $versionOldMinor, $versionOld.Build, $versionOld.Revision)
    $Extenstion = $Extenstion.replace($versionOld.ToString(), $versionNew.ToString())
    $Extenstion | set-content (Join-Path $mainWorkspace 'ps-bc-utils\NavExtensions.ps1')
}

$SettingsJson.ZepterSoftVersion = "$($versionNew.Build.ToString()).$($versionNew.Revision.ToString())"
$SettingsJson | ConvertTo-Json -depth 32 | set-content (Join-Path $Workspace "ps-bc-utils/_SecretSettings.json")

if (($clean18) -or ($clean19)) {
    Start-Process "cmd.exe" "/c d:\DEV-EXT\BaseAppCopyBC190.bat" -WindowStyle Hidden
}
elseif (($clean200) -or ($clean201)) {
    if ($Country -eq 'W1') {
        Start-Process "cmd.exe" "/c d:\DEV-EXT\BaseAppCopyBC200.bat" -WindowStyle Hidden
    }
    elseif ($Country -eq 'IT') {
        Start-Process "cmd.exe" "/c d:\DEV-EXT\BaseAppCopyBC200-IT.bat" -WindowStyle Hidden
    }
    elseif ($Country -eq 'CZ') {
        Start-Process "cmd.exe" "/c d:\DEV-EXT\BaseAppCopyBC200-CZ.bat" -WindowStyle Hidden
    }
}

Set-Location $currentLocation
