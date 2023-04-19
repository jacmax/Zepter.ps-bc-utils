function Restore-Database {
    Param (
        [Parameter(Mandatory=$true)]
        [string] $bakFile,
        [Parameter(Mandatory=$true)]
        [string] $DatabaseName,
        [Parameter(Mandatory=$true)]
        [string] $DatabaseServer,
        [Parameter(Mandatory=$false)]
        [PSCredential] $sqlCredential = $null
    )

    $params = @{ 'ErrorAction' = 'Ignore'; 'ServerInstance' = $databaseServer; 'TrustServerCertificate' = $true }
    if ($sqlCredential) {
        $params += @{ 'Username' = $sqlCredential.UserName; 'Password' = ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sqlCredential.Password))) }
    }

    Write-Host "Restore database $DatabaseName"
    $RestoreDatabase = "RESTORE DATABASE [$DatabaseName] 
      FROM  DISK = N'/var/backups/$bakfile' WITH FILE = 1, 
      MOVE N'Demo Database NAV (14-0)_Data' TO N'/var/opt/mssql/data/" + $DatabaseName + "_Data.mdf', 
      MOVE N'Demo Database NAV (14-0)_Log' TO N'/var/opt/mssql/data/" + $DatabaseName + "_log.ldf', 
      NOUNLOAD, REPLACE"
    Invoke-Sqlcmd @params -Query $RestoreDatabase

    Write-Host "Shrink database $DatabaseName"
    Invoke-Sqlcmd @params -Query "DBCC SHRINKDATABASE(N'$DatabaseName')"
    Invoke-Sqlcmd @params -Query "ALTER DATABASE [$DatabaseName] SET MULTI_USER"
    Invoke-Sqlcmd @params -Query "ALTER DATABASE [$DatabaseName] SET RECOVERY SIMPLE WITH NO_WAIT"
}

function Remove-NetworkServiceUser {
    Param (
        [Parameter(Mandatory=$true)]
        [string] $DatabaseName,
        [Parameter(Mandatory=$true)]
        [string] $DatabaseServer,
        [Parameter(Mandatory=$false)]
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

    Write-Host "Remove LiveToolService User from $DatabaseName"
    Invoke-Sqlcmd @params -Query "USE [$DatabaseName]
    IF EXISTS (SELECT 'X' FROM sysusers WHERE name = 'LiveToolService' and isntuser = 0)
      BEGIN DROP USER [LiveToolService] END"

    Write-Host "Remove raporter User from $DatabaseName"
    Invoke-Sqlcmd @params -Query "USE [$DatabaseName]
    IF EXISTS (SELECT 'X' FROM sysusers WHERE name = 'raporter' and isntuser = 0)
      BEGIN DROP USER [raporter] END"

    Write-Host "Remove QlikRS User from $DatabaseName"
    Invoke-Sqlcmd @params -Query "USE [$DatabaseName]
    IF EXISTS (SELECT 'X' FROM sysusers WHERE name = 'QlikRS' and isntuser = 0)
      BEGIN DROP USER [QlikRS] END"

    Write-Host "Remove jodataexport User from $DatabaseName"
    Invoke-Sqlcmd @params -Query "USE [$DatabaseName]
    IF EXISTS (SELECT 'X' FROM sysusers WHERE name = 'jodataexport' and isntuser = 0)
      BEGIN DROP USER [jodataexport] END"
}

function Remove-WindowsUsers {
    Param (
        [Parameter(Mandatory=$true)]
        [string] $DatabaseName,
        [Parameter(Mandatory=$true)]
        [string] $DatabaseServer,
        [Parameter(Mandatory=$false)]
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
        [Parameter(Mandatory=$true)]
        [string] $DatabaseName,
        [Parameter(Mandatory=$true)]
        [string] $DatabaseServer,
        [Parameter(Mandatory=$false)]
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
        [Parameter(Mandatory=$true)]
        [string] $DatabaseName,
        [Parameter(Mandatory=$true)]
        [string] $DatabaseServer,
        [Parameter(Mandatory=$false)]
        [PSCredential] $sqlCredential = $null
    )
 
    $params = @{ 'ErrorAction' = 'Ignore'; 'ServerInstance' = $databaseServer; 'TrustServerCertificate' = $true }
    if ($sqlCredential) {
        $params += @{ 'Username' = $sqlCredential.UserName; 'Password' = ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sqlCredential.Password))) }
    }

    Write-Host "Remove data from System Tables database $DatabaseName"
    'Server Instance','$ndo$cachesync','$ndo$tenants','Object Tracking' | % {
        Invoke-Sqlcmd @params -Query "USE [$DatabaseName] DELETE FROM dbo.[$_]"
    }
    Invoke-Sqlcmd @params -Query "USE [$DatabaseName] UPDATE [dbo].[`$ndo`$dbproperty] SET [license] = NULL"

    Invoke-Sqlcmd @params -Query "USE [$DatabaseName]
      IF EXISTS ( SELECT 'X' FROM [sys].[tables] WHERE name = 'Active Session' AND type = 'U' )
        BEGIN Delete from dbo.[Active Session] END" 
    
    Invoke-Sqlcmd @params -Query "USE [$DatabaseName]
      IF EXISTS ( SELECT 'X' FROM [sys].[tables] WHERE name = 'Session Event' AND type = 'U' )
        BEGIN Delete from dbo.[Session Event] END" 

    $companies = Invoke-Sqlcmd @params -Query "USE [$DatabaseName] SELECT Name FROM dbo.Company"
    $companies | % {
        Write-Host "TRUNCATE TABLE dbo.[$($_.Name)$("$")Change Log Entry]"
        Invoke-Sqlcmd @params -Query "USE [$DatabaseName] TRUNCATE TABLE dbo.[$($_.Name)$("$")Change Log Entry]"
        Write-Host "TRUNCATE TABLE dbo.[$($_.Name)$("$")Event Log]"
        Invoke-Sqlcmd @params -Query "USE [$DatabaseName] TRUNCATE TABLE dbo.[$($_.Name)$("$")Event Log]"
    }

    Remove-NetworkServiceUser -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName -sqlCredential $sqlCredential
}

function Remove-NavTenantDatabaseUserData {
    Param (        
        [Parameter(Mandatory=$true)]
        [string] $DatabaseName,
        [Parameter(Mandatory=$true)]
        [string] $DatabaseServer,
        [Parameter(Mandatory=$false)]
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
        'User Plan' | % {
            Invoke-Sqlcmd @params -Query "USE [$DatabaseName] DELETE FROM dbo.[$_]"
        }

        $tables = Invoke-Sqlcmd @params -Query "USE [$DatabaseName] SELECT name FROM sysobjects WHERE (xtype = 'U' ) AND (name LIKE '%User Login')"
        $tables | % {
            Write-Host "DELETE FROM dbo.[$($_.Name)]"
            Invoke-Sqlcmd @params -Query "USE [$DatabaseName] DELETE FROM dbo.[$($_.Name)]"
        }
    }

    Invoke-Sqlcmd @params -Query "USE [$DatabaseName] UPDATE [dbo].[$("$")ndo$("$")tenantproperty] SET [license] = NULL"

    'Tenant License State',
    'Active Session',
    'Session Event' | % {
        Invoke-Sqlcmd @params -Query "USE [$DatabaseName] DELETE FROM dbo.[$_]"
    }

    Write-Host "Drop triggers from $DatabaseName"
    Invoke-Sqlcmd @params -Query "USE [$DatabaseName] DROP TRIGGER [dbo].[RemoveOnLogoutActiveSession]" 
    Invoke-Sqlcmd @params -Query "USE [$DatabaseName] DROP TRIGGER [dbo].[DeleteActiveSession]" 
    
    Write-Host "Drop Views from $DatabaseName"
    Invoke-Sqlcmd @Params -Query "USE [$DatabaseName] DROP VIEW IF EXISTS [dbo].[deadlock_report_ring_buffer_view]"

    Remove-NetworkServiceUser -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName -sqlCredential $sqlCredential
}

$UserName = 'sa'
$Password = ConvertTo-SecureString 'ZitP@ssword1' -AsPlainText -Force
$sqlCredential = New-Object System.Management.Automation.PSCredential ($UserName, $Password)

$databaseServerInstance = 'sql.host.internal'
$tempDatabaseName = 'NAV_ZJO_LIVE_140'
$bakFile = 'NAV_ZJO_LIVE_140-230416-2230.bak'

Restore-Database -DatabaseServer $databaseServerInstance -DatabaseName $tempDatabaseName -sqlCredential $sqlCredential -BakFile $bakFile 
Remove-WindowsUsers -DatabaseServer $databaseServerInstance -DatabaseName $tempDatabaseName -sqlCredential $sqlCredential
Remove-ApplicationRoles -DatabaseServer $databaseServerInstance -DatabaseName $tempDatabaseName -sqlCredential $sqlCredential
Remove-NavDatabaseSystemTableData -DatabaseServer $databaseServerInstance -DatabaseName $tempDatabaseName -sqlCredential $sqlCredential
#Remove-NavTenantDatabaseUserData -DatabaseServer $databaseServerInstance -DatabaseName $tempDatabaseName -sqlCredential $sqlCredential