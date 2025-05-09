. (Join-Path $PSScriptRoot '.\_Settings.ps1')

function docker-Export-NAVServerLicenseInformation {
    param (
        [validateset('w1', 'zsi', 'zmk', 'zba', 'zcz', 'zsk', 'zfr', 'zby', 'zpl')]
        [String] $ZepterCountryParam = 'w1'
    )
    $ServerInstance = 'BC'
    $ContainerName = "$ZepterCountryParam-live"

    Write-Host '>>>' -ForegroundColor Yellow
    Invoke-ScriptInBcContainer -containerName $ContainerName -scriptblock { Param( $ServerInstance )
        Export-NAVServerLicenseInformation `
            -ServerInstance $ServerInstance `
    } -ArgumentList $ServerInstance
    Write-Host '<<<' -ForegroundColor Yellow
}