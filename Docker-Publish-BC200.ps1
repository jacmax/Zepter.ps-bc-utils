param (
    [validateset('zsi', 'zmk', 'zba', 'zcz', 'zsk', 'zfr', 'zby', 'zpl', 'w1-bc260')]
    [String] $ZepterCountryParam = '',
    [validateset(0, 1)]
    [Int16] $UnPublish
)

. (Join-Path $PSScriptRoot '.\_Settings.ps1')
. (Join-Path $PSScriptRoot '.\docker-publish.ps1')
. (Join-Path $PSScriptRoot '.\docker-ExportLicenseInformation.ps1')

$StartMs = Get-Date
$System = '20.'
$Country = 'w1'

Write-host
Write-host "ZepterSoft extensions ($ContainerName):"
Write-host

Write-Host "Container $ContainerName is checking" -ForegroundColor Green
$containers = docker images $ContainerName
if ($containers.count -gt 1) {
    $status = docker inspect -f '{{.State.Status}}' $ContainerName
    if ($status -eq "running") {
        Write-Host "Container $ContainerName is running" -ForegroundColor Green
    }
    else {
        Write-Host "Container $ContainerName is not running" -ForegroundColor Red
        & Docker start $ContainerName
        Write-Host "Container $ContainerName is starting" -ForegroundColor Green
        & Start-Sleep -Seconds 60
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
if ($ZepterCountry -eq 'zcz') {
    $Country = 'cz'
    Import-BcContainerLicense `
        -containerName $ContainerName `
        -licenseFile "d:\ZEPTER\FLF\ZIT\ZITBC200.bclicense" `
        -restart

}
if ($ZepterCountry -eq 'zpl') {
    $System = '25.'
    $Country = 'pl'
    Import-BcContainerLicense `
        -containerName $ContainerName `
        -licenseFile "d:\ZEPTER\FLF\ZIT\ZITBC250.bclicense" `
        -restart
}

$SecretSettings = Get-ObjectFromJSON (Join-Path $PSScriptRoot "_SecretSettings.json")
$SecretSettings.Country = $Country
$SecretSettings | ConvertTo-Json -depth 32 | set-content (Join-Path $PSScriptRoot "_SecretSettings.json")

Write-host
Write-host "UnPublishing ($ContainerName) for Country ($Country)"  -ForegroundColor Yellow
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
    if (-not (($ZepterCountry -eq 'zpl') -and ($AppName -eq 'ZS Holding Report'))) {
        PublishExtension `
            -containerName $ContainerName `
            -appName $AppName `
            -country $Country `
            -system $System
    }
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
if ($ZepterCountry -eq 'zpl') {
    Import-BcContainerLicense `
        -containerName $ContainerName `
        -licenseFile "d:\ZEPTER\FLF\ZPL\ZPL.bclicense" `
        -restart
}

if ($ZepterCountry -in 'zsi', 'zmk', 'zpl') {
    docker-Export-NAVServerLicenseInformation $ZepterCountry
}

$EndMs = Get-Date
$Interval = $EndMs - $StartMs

Write-host
Write-host "This script took $($Interval.ToString()) to run"
