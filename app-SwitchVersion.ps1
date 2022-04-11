param (
    [validateset('BC19', 'BC20', 'BC+')]
    [String] $Type = 'BC19'
)

. (Join-path $PSScriptRoot '_Settings.ps1')

$clean19 = $Type -eq 'BC19'
$clean20 = $Type -eq 'BC20'
$newVersion = $Type -eq 'BC+'

if ($newVersion) {
    $clean19 = $true
}

$mainWorkspace = $Workspace
$currentLocation = Get-Location
foreach ($Target in $AppJsons) {
    $AppJson = Get-ObjectFromJSON (Join-Path $target.directory.FullName "app.json")
    if ((($AppJson.application -eq '19.0.0.0') -or ($AppJson.application -eq '20.0.0.0')) -and $AppJson.name.Contains('ZS ')) { 
        
        $versionOld = [version]$AppJson.version
        $versionOldMajor = 19
        $versionOldMinor = 1
        
        if ($clean19) {
            $versionOldMajor = 19
            $versionOldMinor = 1
            $AppJson.application = '19.0.0.0'
            $AppJson.platform = '19.0.0.0'
            $AppJson.preprocessorSymbols[0] = 'CLEAN19'
            $AppJson.preprocessorSymbols[1] = 'IT'
        }
        elseif ($clean20) {
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

        $AppJson.propagateDependencies = $false
        $AppJson | ConvertTo-Json -depth 32 | set-content (Join-Path $target.directory.FullName "app.json")
        
        Write-Host $AppJson.application $AppJson.version $AppJson.name 
    }
}

if (($versionOld) -and ($versionNew)) {
    $Extenstion = Get-Content -Path (Join-Path $mainWorkspace 'ps-bc-utils\NavExtensions.ps1')
    $Extenstion = $Extenstion.replace($versionOld.ToString(), $versionNew.ToString())
    $Extenstion | set-content (Join-Path $mainWorkspace 'ps-bc-utils\NavExtensions.ps1')
}

if ($clean19) {
    Start-Process "cmd.exe" "/c d:\DEV-EXT\BaseAppCopyBC190.bat" -WindowStyle Hidden
}
elseif ($clean20) {
    Start-Process "cmd.exe" "/c d:\DEV-EXT\BaseAppCopyBC200.bat" -WindowStyle Hidden
}

Set-Location $currentLocation
