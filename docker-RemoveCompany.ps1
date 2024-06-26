param (
    [validateset('zpl')]
    [String] $ZepterCountryParam = 'zpl',
    [String] $CompanyName
)
. (Join-Path $PSScriptRoot '.\_Settings.ps1')

$ServerInstance = 'BC'
$ContainerName = "$ZepterCountryParam-live"

Write-Host '>>>' -ForegroundColor Yellow
Write-Host $ServerInstance
Write-Host $ContainerName
Write-Host $CompanyName

Invoke-ScriptInBcContainer -containerName $ContainerName -scriptblock { Param( $ServerInstance, $CompanyName )
    Remove-NAVCompany `
        -ServerInstance $ServerInstance `
        -CompanyName $CompanyName `
        -verbose
} -ArgumentList $ServerInstance, $CompanyName
    
Write-Host '<<<' -ForegroundColor Yellow
