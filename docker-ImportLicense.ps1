. (Join-Path $PSScriptRoot '.\_Settings.ps1')

function docker-Import-NAVServerLicense {
    param (
        [validateset('w1', 'zsi', 'zmk', 'zba', 'zcz', 'zsk', 'zfr', 'zby', 'zpl')]
        [String] $ZepterCountryParam = 'w1'
    )
    $ContainerName = "$ZepterCountryParam-live"

    $containerLicenseFile = $SecretSettings.containerLicenseFileBC200
    if ($ZepterCountryParam -eq 'zpl') {
        $containerLicenseFile = $SecretSettings.containerLicenseFileBC240
    }

    Write-Host '>>>' -ForegroundColor Yellow
    Import-BcContainerLicense -containerName $ContainerName -licenseFile $containerLicenseFile -restart
    Write-Host '<<<' -ForegroundColor Yellow
}