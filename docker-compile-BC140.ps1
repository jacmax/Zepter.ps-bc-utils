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

$EndMs = Get-Date
$Interval = $EndMs - $StartMs

Write-host
Write-host "This script took $($Interval.ToString()) to run"
