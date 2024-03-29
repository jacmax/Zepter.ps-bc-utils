. (Join-Path $PSScriptRoot '.\_Settings.ps1')

$ServerInstance = 'BC'
$ContainerName = "$ZepterCountry-live"

Write-Host '>>>' -ForegroundColor Yellow
Invoke-ScriptInBcContainer -containerName $ContainerName -scriptblock { Param( $ServerInstance )
    Set-NAVServerConfiguration `
        -ServerInstance $ServerInstance `
        -KeyName EnableTaskScheduler `
        -KeyValue true `
        -verbose

    Set-NAVServerInstance -ServerInstance $ServerInstance -Restart -verbose
} -ArgumentList $ServerInstance
Write-Host '<<<' -ForegroundColor Yellow
