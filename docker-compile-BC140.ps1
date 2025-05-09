param (
    [validateset('zhu', 'zjo', 'zbg', 'zlt', 'zus')]
    [String] $ZepterCountryParam = ''
)

. (Join-Path $PSScriptRoot '.\_Settings.ps1')

if ($ZepterCountryParam) {
    $ZepterCountry = $ZepterCountryParam
    if ($ZepterCountry) {
        $ContainerName = "$ZepterCountry-live"
    }
}

$StartMs = Get-Date

Compile-ObjectsInNavContainer -containerName $ContainerName -sqlCredential $ContainerSqlCredential

Invoke-ScriptInNavContainer -containerName $ContainerName -ScriptBlock {
    Get-NAVTenant NAV | Sync-NavTenant -Mode Sync -Force
}

$EndMs = Get-Date
$Interval = $EndMs - $StartMs

Write-host
Write-host "This script took $($Interval.ToString()) to run"
