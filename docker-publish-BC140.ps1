param (
    [validateset('zhu', 'zjo')]
    [String] $ZepterCountryParam = ''
)

. (Join-Path $PSScriptRoot '.\_Settings.ps1')
. (Join-Path $PSScriptRoot '.\docker-publish.ps1')
. (Join-Path $PSScriptRoot '.\docker-ExportLicenseInformation.ps1')

if ($ZepterCountryParam) {
    $ZepterCountry = $ZepterCountryParam
    if ($ZepterCountry) {
        $ContainerName = "$ZepterCountry-live"
    }
}

$StartMs = Get-Date

Write-host
Write-host "ZepterSoft extensions ($ContainerName):"
Write-host

Import-BcContainerLicense `
    -containerName $ContainerName `
    -licenseFile "d:\ZEPTER\FLF\ZIT\ZITBC140.flf" `
    -restart

Write-host
Write-host "UnPublishing ($ContainerName)"  -ForegroundColor Yellow
Write-host

if ($ZepterCountry = 'zhu') {
    $AppName = 'ZS Integration HU';
}
if ($ZepterCountry = 'zjo') {
    $AppName = 'ZS Integration JO';
}

UnpublishExtension `
    -containerName $ContainerName `
    -appName $Appname

Write-host
Write-host $SyncMode -ForegroundColor Yellow
Write-host

PublishExtension `
    -containerName $ContainerName `
    -appName $AppName `
    -country $ContainerCountry `
    -system '14.'

Import-BcContainerLicense `
    -containerName $ContainerName `
    -licenseFile "d:\ZEPTER\FLF\ZJO\ZJO.flf" `
    -restart

$EndMs = Get-Date
$Interval = $EndMs - $StartMs

Write-host
Write-host "This script took $($Interval.ToString()) to run"
