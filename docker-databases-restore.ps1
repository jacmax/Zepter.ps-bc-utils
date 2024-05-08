function Restore-Database {
    Param (
        [Parameter(Mandatory = $true)]
        [string] $bakFile,
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

    $CheckDatabase = "SELECT DB_ID('$DatabaseName') AS [Database ID]"
    Write-Host "Check database $DatabaseName"
    Write-Host $CheckDatabase -ForegroundColor Green
    $table = Invoke-Sqlcmd @params -Query $CheckDatabase -Verbose
    foreach ($row in $table) {
        [string]$tableID = $row.item(0)
    }

    if ($tableID -ne '') {
        $DropDatabase = "ALTER DATABASE [$DatabaseName] SET SINGLE_USER"
        $DropDatabase += "; DROP DATABASE IF EXISTS [$DatabaseName]"
        Write-Host "Drop database $DatabaseName"
        Write-Host $DropDatabase.Replace(';', ";`n") -ForegroundColor Green
        Invoke-Sqlcmd @params -Query $DropDatabase.ToString() -Verbose
    }

    $FileListDatabase = "RESTORE FILELISTONLY FROM DISK = N'/var/backups/$bakfile'"
    $table = Invoke-Sqlcmd @params -Query $FileListDatabase -Verbose
    $RestoreDatabase = "RESTORE DATABASE [$DatabaseName]"
    $RestoreDatabase += " FROM DISK = N'/var/backups/$bakfile' WITH FILE = 1"
    foreach ($row in $table) {
        [String]$logicalName = $row.item(0)
        if ($logicalName.EndsWith('_Data')) {
            $RestoreDatabase += ", MOVE N'$logicalName' TO N'/var/opt/mssql/data/" + $DatabaseName + "_Data.mdf'"
        }
        if ($logicalName.EndsWith('_Log')) {
            $RestoreDatabase += ", MOVE N'$logicalName' TO N'/var/opt/mssql/data/" + $DatabaseName + "_Log.ldf'"
        }
    }
    $RestoreDatabase += ', NOUNLOAD, REPLACE'

    Write-Host "Restore database $DatabaseName"
    Write-Host $RestoreDatabase.Replace(',', ",`n") -ForegroundColor Green
    Invoke-Sqlcmd @params -Query $RestoreDatabase.ToString() -Verbose
}

function Shrink-Database {
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

    Write-Host "Shrink database $DatabaseName"
    Invoke-Sqlcmd @params -Query "DBCC SHRINKDATABASE(N'$DatabaseName')"
    Invoke-Sqlcmd @params -Query "ALTER DATABASE [$DatabaseName] SET MULTI_USER"
    Invoke-Sqlcmd @params -Query "ALTER DATABASE [$DatabaseName] SET RECOVERY SIMPLE WITH NO_WAIT"
}

function Remove-NetworkServiceUser {
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


    Write-Host "Remove Network Service User from $DatabaseName"
    Invoke-Sqlcmd @params -Query "USE [$DatabaseName]
    IF EXISTS (SELECT 'X' FROM sysusers WHERE name = 'NT AUTHORITY\NETWORK SERVICE' and isntuser = 1)
    BEGIN DROP USER [NT AUTHORITY\NETWORK SERVICE] END"

    Write-Host "Remove System User from $DatabaseName"
    Invoke-Sqlcmd @params -Query "USE [$DatabaseName]
    IF EXISTS (SELECT 'X' FROM sysusers WHERE name = 'NT AUTHORITY\SYSTEM' and isntuser = 1)
    BEGIN DROP USER [NT AUTHORITY\SYSTEM] END"

    'LiveToolService',
    'raporter',
    'QlikRS',
    'ZIT_Reporting',
    'bgdataexport',
    'ltdataexport',
    'jodataexport',
    'hudataexport',
    'mkdataexport',
    'czdataexport' | ForEach-Object {
        Write-Host "Remove $_ User from $DatabaseName"
        Invoke-Sqlcmd @params -Query "USE [$DatabaseName]
        IF EXISTS (SELECT 'X' FROM sysusers WHERE name = '$_' and isntuser = 0)
        BEGIN DROP USER [$_] END"
    }
}

function Remove-WindowsUsers {
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

    Write-Host "Remove Windows Users from $DatabaseName"
    Invoke-Sqlcmd @params -Query "USE [$DatabaseName]
    declare @sql nvarchar(max)
    set @sql = ''

    SELECT @sql = @sql+'
            drop user [' + name + ']
        'FROM
    sys.database_principals
    WHERE
    sys.database_principals.authentication_type = 3 and sys.database_principals.name != 'dbo'

    execute ( @sql )"
}

function Remove-ApplicationRoles {
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

    Write-Host "Remove Application Roles from $DatabaseName"
    Invoke-Sqlcmd @params -Query "USE [$DatabaseName]
    declare @sql nvarchar(max)
    set @sql = ''

    SELECT @sql = @sql+'
            drop application role [' + name + ']
        'FROM
    sys.database_principals
    WHERE
    sys.database_principals.type = 'A'

    execute ( @sql )"
}

function Remove-NavDatabaseSystemTableData {
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

    Write-Host "Remove data from System Tables database $DatabaseName"
    'Server Instance', '$ndo$cachesync', '$ndo$tenants', 'Object Tracking' | ForEach-Object {
        Invoke-Sqlcmd @params -Query "USE [$DatabaseName] DELETE FROM dbo.[$_]"
    }
    Invoke-Sqlcmd @params -Query "USE [$DatabaseName] UPDATE [dbo].[`$ndo`$dbproperty] SET [license] = NULL"
    if ($DatabaseName.EndsWith('200')) {
        $extensionGUID = '$437dbf0e-84ff-417a-965d-ed2bb9650972'
    }
    Invoke-Sqlcmd @params -Query "USE [$DatabaseName]
    IF EXISTS ( SELECT 'X' FROM [sys].[tables] WHERE name = 'Active Session' AND type = 'U' )
    BEGIN Delete from dbo.[Active Session] END"

    Invoke-Sqlcmd @params -Query "USE [$DatabaseName]
    IF EXISTS ( SELECT 'X' FROM [sys].[tables] WHERE name = 'Session Event' AND type = 'U' )
    BEGIN Delete from dbo.[Session Event] END"

    '%$Change Log Entry%', '%$ZS Event Log%', '%$Event Log%' | ForEach-Object {
        $tables = Invoke-Sqlcmd @params -Query "USE [$DatabaseName]
        SELECT [TABLE_NAME] FROM [$DatabaseName].INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME like '$_'"
        $tables | ForEach-Object {
            Write-Host "TRUNCATE TABLE dbo.[$($_.Item(0))]"
            Invoke-Sqlcmd @params -Query "USE [$DatabaseName] TRUNCATE TABLE dbo.[$($_.Item(0))]"
        }
    }

    $companies = Invoke-Sqlcmd @params -Query "USE [$DatabaseName] SELECT Name FROM dbo.Company"
    $companies | ForEach-Object {
        $tables = Invoke-Sqlcmd @params -Query "USE [$DatabaseName] SELECT max([Creation Date]) 'Version' FROM dbo.[$($_.Name.Replace('.','_'))$("$")G_L Register$extensionGUID]"
        foreach ($row in $tables) {
            Write-Host 'Version: ' -ForegroundColor Green -NoNewline
            Write-Host $row.Item(0) -ForegroundColor Green
        }
    }
    Remove-NetworkServiceUser -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName -sqlCredential $sqlCredential
}

function Remove-NavTenantDatabaseUserData {
    Param (
        [Parameter(Mandatory = $true)]
        [string] $DatabaseName,
        [Parameter(Mandatory = $true)]
        [string] $DatabaseServer,
        [Parameter(Mandatory = $false)]
        [PSCredential] $sqlCredential = $null,
        [switch] $KeepUserData
    )

    $params = @{ 'ErrorAction' = 'Ignore'; 'ServerInstance' = $databaseServer }
    if ($sqlCredential) {
        $params += @{ 'Username' = $sqlCredential.UserName; 'Password' = ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sqlCredential.Password))) }
    }

    if (!($KeepUserData)) {
        Write-Host "Remove data from User table and related tables in $DatabaseName database."
        'Access Control',
        'User Property',
        'User Personalization',
        'User Metadata',
        'User Default Style Sheet',
        'User',
        'User Group Member',
        'User Group Access Control',
        'User Plan' | ForEach-Object {
            Invoke-Sqlcmd @params -Query "USE [$DatabaseName] DELETE FROM dbo.[$_]"
        }

        $tables = Invoke-Sqlcmd @params -Query "USE [$DatabaseName] SELECT name FROM sysobjects WHERE (xtype = 'U' ) AND (name LIKE '%User Login')"
        $tables | ForEach-Object {
            Write-Host "DELETE FROM dbo.[$($_.Name)]"
            Invoke-Sqlcmd @params -Query "USE [$DatabaseName] DELETE FROM dbo.[$($_.Name)]"
        }
    }

    Invoke-Sqlcmd @params -Query "USE [$DatabaseName] UPDATE [dbo].[$("$")ndo$("$")tenantproperty] SET [license] = NULL"

    'Tenant License State',
    'Active Session',
    'Session Event' | ForEach-Object {
        Invoke-Sqlcmd @params -Query "USE [$DatabaseName] DELETE FROM dbo.[$_]"
    }

    Write-Host "Drop triggers from $DatabaseName"
    Invoke-Sqlcmd @params -Query "USE [$DatabaseName] DROP TRIGGER [dbo].[RemoveOnLogoutActiveSession]"
    Invoke-Sqlcmd @params -Query "USE [$DatabaseName] DROP TRIGGER [dbo].[DeleteActiveSession]"

    Write-Host "Drop Views from $DatabaseName"
    Invoke-Sqlcmd @Params -Query "USE [$DatabaseName] DROP VIEW IF EXISTS [dbo].[deadlock_report_ring_buffer_view]"

    Remove-NetworkServiceUser -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName -sqlCredential $sqlCredential
}

function Set-Docker-For-Restart {
    param (
        [String] $containerName
    )

    Write-Host '>>>' -ForegroundColor Yellow
    Write-Host "Checking StartCount.txt file in $containerName" -ForegroundColor Green
    Invoke-ScriptInBcContainer -containerName $ContainerName -scriptblock {
        $startCountFile = 'C:\Run\StartCount.txt'
        if (Test-Path $startCountFile) {
            Remove-Item $startCountFile
        }
    }
    Write-Host '<<<' -ForegroundColor Yellow
}

. (Join-Path $PSScriptRoot '_Settings.ps1')
. (Join-Path $PSScriptRoot 'docker-newimg-sqlfile.ps1')
. (Join-Path $PSScriptRoot 'docker-import-NAVEncryptionKey.ps1')

& $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchLinuxEngine -Verbose
$env:DOCKER_CONTEXT = 'desktop-linux'
#Start-Sleep -Seconds 30
&docker start SqlServer

$sqlCredential = $ContainerSqlCredential
$databaseServerInstance = 'sql.host.internal'
$sqlBackupFiles = Get-ChildItem -Path 'D:\Temp\SqlServer' -Filter '*.bak'
$sqlServer = 'SqlServer'

foreach ($file in $sqlBackupFiles) {
    $result = $file.Name -match 'NAV_(?<country>[A-Z]{3})_.*_(?<version>\d{3})'
    if ($result) {
        $country = $Matches['country']
        $version = $Matches['version']

        & $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchWindowsEngine -Verbose
        $env:DOCKER_CONTEXT = 'desktop-windows'

        $container = $country.ToLower() + '-live'
        Write-Host "Container $container is checking" -ForegroundColor Green
        $containers = docker images $container
        if ($containers.count -gt 1) {
            Write-Host "Container $container is stopping" -ForegroundColor Green
            & Docker stop $container
        }

        $tempDatabaseName = "NAV_" + $country + "_LIVE_" + $version
        $bakFile = $file.Name

        Write-Host 'Restore database' $file.Name 'on' $sqlServer -ForegroundColor Red

        & $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchLinuxEngine -Verbose
        $env:DOCKER_CONTEXT = 'desktop-linux'
        #<#
        & docker cp $file.FullName $($sqlServer + ':/var/backups')
        Restore-Database -DatabaseServer $databaseServerInstance -DatabaseName $tempDatabaseName -sqlCredential $sqlCredential -BakFile $bakFile
        Remove-WindowsUsers -DatabaseServer $databaseServerInstance -DatabaseName $tempDatabaseName -sqlCredential $sqlCredential
        Remove-ApplicationRoles -DatabaseServer $databaseServerInstance -DatabaseName $tempDatabaseName -sqlCredential $sqlCredential
        Remove-NavDatabaseSystemTableData -DatabaseServer $databaseServerInstance -DatabaseName $tempDatabaseName -sqlCredential $sqlCredential
        #Shrink-Database -DatabaseServer $databaseServerInstance -DatabaseName $tempDatabaseName -sqlCredential $sqlCredential
        #Remove-NavTenantDatabaseUserData -DatabaseServer $databaseServerInstance -DatabaseName $tempDatabaseName -sqlCredential $sqlCredential

        $fileName = '/var/backups/' + $file.Name
        Write-Host 'Remove' $fileName -ForegroundColor Yellow
        docker exec -u 0 $($sqlServer) rm -rf $fileName
        #>
        <#
        & $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchWindowsEngine -Verbose
        $env:DOCKER_CONTEXT = 'desktop-windows'

        $containers = docker images $container
        if ($containers.count -eq 1) {
            & Docker-NewImg-Sqlfile -ZepterCountryParam $country.ToLower()
        }
        else {
            switch ($version) {
                '100' {
                    $licenseFile = $SecretSettings.containerLicenseFileBC100;
                    break;
                }
                '140' {
                    $licenseFile = $SecretSettings.containerLicenseFileBC140;
                    break;
                }
                '200' {
                    $licenseFile = $SecretSettings.containerLicenseFileBC200;
                    break;
                }
                Default {
                    $licenseFile = $SecretSettings.containerLicenseFile;
                    break;
                }
            }
            Write-Host ">>> Start update docker" -ForegroundColor Yellow
            Write-Host "Docker start $container"
            & Docker start $container
            & Docker-Import-NAVEncryptionKey -ZepterCountryParam $country.ToLower()
            & Start-Sleep -Seconds 20
            & Set-Docker-For-Restart $container
            & Docker restart $container
            & Start-Sleep -Seconds 120
            & Import-BcContainerLicense -containerName $container -licenseFile $licenseFile -restart
            if ($version -in '100', '140') {
                & Docker-NewNavServerUser -ZepterCountryParam $country.ToLower()
            }
            #& Set-Docker-For-Restart $container
            & Docker restart $container
            Write-Host "<<< End update docker" -ForegroundColor Yellow
            & Docker stop $container
        }
        #>        
    }
}