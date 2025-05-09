param
(
    [Parameter(Mandatory = $true)]
    [validateset('w1', 'zsi', 'zmk', 'zba', 'zcz', 'zsk', 'zfr', 'zby', 'zpl')]
    [String]$Country,
    [validateset('client', 'development')]
    [String]$Type = 'development'
)

. (Join-Path $PSScriptRoot '.\_Settings.ps1')

function docker-Import-NAVServerLicense {
    param (
        [validateset('w1', 'zsi', 'zmk', 'zba', 'zcz', 'zsk', 'zfr', 'zby', 'zpl')]
        [String] $ZepterCountryParam = 'w1'
    )
    $ContainerName = "$ZepterCountryParam-live"

    $containerLicenseFile = $SecretSettings.containerLicenseFileBC200
    if ($ZepterCountryParam -eq 'zpl') {
        $containerLicenseFile = $SecretSettings.containerLicenseFileBC250
    }

    Write-Host '>>>' -ForegroundColor Yellow
    Import-BcContainerLicense -containerName $ContainerName -licenseFile $containerLicenseFile -restart
    Write-Host '<<<' -ForegroundColor Yellow
}

if ($Type -eq 'development') {
    docker-Import-NAVServerLicense -ZepterCountryParam $Country
}
else {
    if ($Country -eq 'zpl') {
        Import-BcContainerLicense `
            -containerName 'zpl-live' `
            -licenseFile "d:\ZEPTER\FLF\ZPL\ZPL.bclicense" `
            -restart
    }
}

#Import-BcContainerLicense `
#    -containerName 'w1-bc250' `
#    -licenseFile $SecretSettings.containerLicenseFileBC250 `
#    -restart