param (
    [validateset('zsi', 'zmk', 'zba', 'zcz', 'zsk', 'zfr', 'zby', 'zpl')]
    [String] $ZepterCountryParam = ''
)

. (Join-Path $PSScriptRoot '.\_Settings.ps1')
. (Join-Path $PSScriptRoot '.\docker-publish.ps1')
. (Join-Path $PSScriptRoot '.\docker-ExportLicenseInformation.ps1')

if ($ZepterCountryParam) {
    $ZepterCountry = $ZepterCountryParam
    if ($ZepterCountry) {
        $ContainerName = "$ZepterCountry-live"
        #if ($ZepterCountry -eq 'zcz') {
        #    $ContainerName = "cz-bc220"
        #}
    }
}

$StartMs = Get-Date

Write-host
Write-host "ZepterSoft extensions ($ContainerName):"
Write-host

if ($ZepterCountry -eq 'zsi') {
    Import-BcContainerLicense `
        -containerName $ContainerName `
        -licenseFile "d:\ZEPTER\FLF\ZIT\ZITBC200.bclicense" `
        -restart
}
if ($ZepterCountry -eq 'zmk') {
    Import-BcContainerLicense `
        -containerName $ContainerName `
        -licenseFile "d:\ZEPTER\FLF\ZIT\ZITBC200.bclicense" `
        -restart
}
if ($ZepterCountry -eq 'zcz') {
    Import-BcContainerLicense `
        -containerName $ContainerName `
        -licenseFile "d:\ZEPTER\FLF\ZIT\ZITBC200.bclicense" `
        -restart
}
if ($ZepterCountry -eq 'zpl') {
    $System = '23.'
    Import-BcContainerLicense `
        -containerName $ContainerName `
        -licenseFile "d:\ZEPTER\FLF\ZIT\ZITBC230.bclicense" `
        -restart
}

Write-host
Write-host "UnPublishing ($ContainerName)"  -ForegroundColor Yellow
Write-host

for (($i = $AppToInstall.Count - 1); $i -gt -1; $i--) {
    Write-Host $AppToInstall[$i] -ForegroundColor Yellow
    [string] $AppToUnInstall = $AppToInstall[$i]
    $AppToUnInstall = $AppToUnInstall.Replace('_CLEANBINCODE', '')
    UnpublishExtension `
        -containerName $ContainerName `
        -appName $AppToUnInstall
}


Write-host
Write-host $SyncMode -ForegroundColor Yellow
Write-host

for (($i = 0); $i -lt $AppToInstallCount; $i++) {
    Write-Host $AppToInstall[$i] -ForegroundColor Blue
    $AppName = $AppToInstall[$i]
    PublishExtension `
        -containerName $ContainerName `
        -appName $AppName `
        -country $ContainerCountry `
        -system $System
}

if ($AppToInstall2.Count -gt 0) {
    for (($i = 0); $i -lt $AppToInstallCount; $i++) {
        Write-Host $AppToInstall2[$i] -ForegroundColor Blue
        $AppName = $AppToInstall2[$i]
        $file = Get-Item -Path "$BCZSFolder\*" -filter "${AppName}" | Sort-Object -Property CreationTime | Select-Object -Last 1
        Write-Host $file.FullName

        <#
        [string] $AppToUnInstall = $AppToInstall2[$i]
        UnpublishExtension `
        -containerName $ContainerName `
        -appName $AppToUnInstall
        #>

        Publish-BcContainerApp `
            -containerName $ContainerName `
            -appFile $file.FullName `
            -install `
            -upgrade `
            -sync `
            -syncMode $SyncMode `
            -SkipVerification
    }
}

if ($ZepterCountry -eq 'zsi') {
    Import-BcContainerLicense `
        -containerName $ContainerName `
        -licenseFile "d:\ZEPTER\FLF\ZIT\ZITBC200.bclicense" `
        -restart
}
if ($ZepterCountry -eq 'zmk') {
    Import-BcContainerLicense `
        -containerName $ContainerName `
        -licenseFile "d:\ZEPTER\FLF\ZIT\ZITBC200.bclicense" `
        -restart
}

if ($ZepterCountry -in 'zsi', 'zmk') {
    docker-Export-NAVServerLicenseInformation $ZepterCountry
}

$EndMs = Get-Date
$Interval = $EndMs - $StartMs

Write-host
Write-host "This script took $($Interval.ToString()) to run"
