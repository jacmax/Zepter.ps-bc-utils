param (
    [validateset('BC18', 'BC19', 'BC20', 'BC+')]
    [String] $Type = 'BC19',
    [validateset('W1', 'IT')]
    [String] $Country = 'W1'
)

. (Join-path $PSScriptRoot '_Settings.ps1')

$clean18 = $Type -eq 'BC18'
$clean19 = $Type -eq 'BC19'
$clean20 = $Type -eq 'BC20'
$newVersion = $Type -eq 'BC+'

if ($newVersion) {
    $clean19 = $true
}

Write-Host $Country -NoNewline

$SettingsJson = Get-ObjectFromJSON (Join-Path $Workspace "ps-bc-utils/_SecretSettings.json")
if ($clean18) {
    $SettingsJson.version = '18.0'
}
if ($clean19) {
    $SettingsJson.version = '19.5'
}
if ($clean20) {
    $SettingsJson.version = '20.0'
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

        if ($clean18) {
            $versionOldMajor = 18
            $versionOldMinor = 1
            $AppJson.application = '19.0.0.0'
            $AppJson.platform = '19.0.0.0'
            $AppJson.preprocessorSymbols[0] = 'CLEAN18'
            $AppJson.preprocessorSymbols[1] = $Country
        }
        elseif ($clean19) {
            $versionOldMajor = 19
            $versionOldMinor = 1
            $AppJson.runtime = '8.0'
            $AppJson.application = '19.0.0.0'
            $AppJson.platform = '19.0.0.0'
            $AppJson.preprocessorSymbols[0] = 'CLEAN19'
            $AppJson.preprocessorSymbols[1] = $Country
        }
        elseif ($clean20) {
            $versionOldMajor = 20
            $versionOldMinor = 0
            $AppJson.runtime = '9.0'
            $AppJson.application = '20.0.0.0'
            $AppJson.platform = '20.0.0.0'
            $AppJson.preprocessorSymbols[0] = 'CLEAN20'
            $AppJson.preprocessorSymbols[1] = $Country
        }


        if (($AppJson.name -eq 'ZS Integration IT') -and ($Country -eq 'W1')) {
            if ($clean18) {
                $versionOldMajor = 18
                $AppJson.preprocessorSymbols[0] = 'CLEAN18'
            }
            else {
                $versionOldMajor = 19
                $AppJson.preprocessorSymbols[0] = 'CLEAN19'
            }
            $versionOldMinor = 1
            $AppJson.application = '19.0.0.0'
            $AppJson.platform = '19.0.0.0'
            $AppJson.preprocessorSymbols[1] = 'IT'
        }

        $versionOld = [version]::New($versionOldMajor, $versionOldMinor, $versionOld.Build, $versionOld.Revision)
        if ($newVersion) {
            $versionNew = [version]::New($versionOld.Major, $versionOld.Minor, $versionOld.Build, $versionOld.Revision + 1)
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
    if ($clean19) {
        $versionOldMajor = 20
        $versionOldMinor = 0
    }
    elseif ($clean20) {
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
elseif ($clean20) {
    if ($Country -eq 'W1') {
        Start-Process "cmd.exe" "/c d:\DEV-EXT\BaseAppCopyBC200.bat" -WindowStyle Hidden
    }
    else {
        Start-Process "cmd.exe" "/c d:\DEV-EXT\BaseAppCopyBC200-IT.bat" -WindowStyle Hidden
    }
}

Set-Location $currentLocation
