function Remove-NavDatabaseRDPR {
    Param (
        [Parameter(Mandatory = $true)]
        [string] $DatabaseName,
        [Parameter(Mandatory = $true)]
        [string] $DatabaseServer,
        [Parameter(Mandatory = $false)]
        [PSCredential] $sqlCredential = $null
    )

    $params = @{ 'ErrorAction' = 'Ignore'; 'ServerInstance' = $databaseServer; 'TrustServerCertificate' = $true }
    if ($sqlCredential) {
        $params += @{ 'Username' = $sqlCredential.UserName; 'Password' = ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sqlCredential.Password))) }
    }

    $tables = Invoke-Sqlcmd @params -Query "USE [$DatabaseName]
        SELECT [TABLE_NAME], [COLUMN_NAME]
            FROM [$DatabaseName].INFORMATION_SCHEMA.COLUMNS
            WHERE (COLUMN_NAME like '%Address%' OR COLUMN_NAME like '%Phone%' OR COLUMN_NAME like '%E-mail%')
                AND (CHARACTER_MAXIMUM_LENGTH > 10)
            ORDER BY [TABLE_NAME]"
    $tables
    #$tables | ForEach-Object {
    #    Write-Host "TRUNCATE TABLE dbo.[$($_.Item(0))]"
    #    Invoke-Sqlcmd @params -Query "USE [$DatabaseName] TRUNCATE TABLE dbo.[$($_.Item(0))]"
    #}


    #$companies = Invoke-Sqlcmd @params -Query "USE [$DatabaseName] SELECT Name FROM dbo.Company"
    #$companies | ForEach-Object {
    #    $tables = Invoke-Sqlcmd @params -Query "USE [$DatabaseName] SELECT max([Creation Date]) 'Version' FROM dbo.[$($_.Name.Replace('.','_'))$("$")G_L Register$extensionGUID]"
    #    foreach ($row in $tables) {
    #        Write-Host 'Version: ' -ForegroundColor Green -NoNewline
    #        Write-Host $row.Item(0) -ForegroundColor Green
    #    }
    #}

    #Remove-NetworkServiceUser -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName -sqlCredential $sqlCredential
}


. (Join-Path $PSScriptRoot '_Settings.ps1')
& $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchLinuxEngine -Verbose
#Start-Sleep -Seconds 30
&docker start SqlServer

$sqlCredential = $ContainerSqlCredential
$databaseServerInstance = 'sql.host.internal'
$sqlServer = 'SqlServer'

Remove-NavDatabaseRDPR -DatabaseServer $databaseServerInstance -DatabaseName $tempDatabaseName -sqlCredential $sqlCredential
