function Get-SQLTable {
    [CmdletBinding()]
    param(

        [Parameter(Mandatory = $true)]
        [string] $SourceSQLInstance,

        [Parameter(Mandatory = $true)]
        [string] $SourceDatabase,

        [Parameter(Mandatory = $true)]
        [string] $TargetSQLInstance,

        [Parameter(Mandatory = $true)]
        [string] $TargetDatabase,

        [Parameter(Mandatory = $true)]
        [string[]] $Tables,

        [Parameter(Mandatory = $false)]
        [int] $BulkCopyBatchSize = 10000,

        [Parameter(Mandatory = $false)]
        [int] $BulkCopyTimeout = 600

    )

    $sourceConnStr = "Data Source=$SourceSQLInstance;Initial Catalog=$SourceDatabase;Integrated Security=True;"
    $TargetConnStr = "Data Source=$TargetSQLInstance;Initial Catalog=$TargetDatabase;Integrated Security=True;"

    try {

        Import-Module -Name SQLServer
        write-host 'module loaded'
        $sourceSQLServer = New-Object Microsoft.SqlServer.Management.Smo.Server $SourceSQLInstance
        $sourceDB = $sourceSQLServer.Databases[$SourceDatabase]
        $sourceConn = New-Object System.Data.SqlClient.SQLConnection($sourceConnStr)

        $sourceConn.Open()

        foreach ($table in $sourceDB.Tables) {

            $tableName = $table.Name
            $schemaName = $table.Schema
            $tableAndSchema = "$schemaName.$tableName"

            if ($Tables.Contains($tableAndSchema)) {
                $Tablescript = ($table.Script() | Out-String)
                $Tablescript

                Invoke-Sqlcmd `
                    -ServerInstance $TargetSQLInstance `
                    -Database $TargetDatabase `
                    -Query $Tablescript


                $sql = "SELECT * FROM $tableAndSchema"
                $sqlCommand = New-Object system.Data.SqlClient.SqlCommand($sql, $sourceConn)
                [System.Data.SqlClient.SqlDataReader] $sqlReader = $sqlCommand.ExecuteReader()
                $bulkCopy = New-Object Data.SqlClient.SqlBulkCopy($TargetConnStr, [System.Data.SqlClient.SqlBulkCopyOptions]::KeepIdentity)
                $bulkCopy.DestinationTableName = $tableAndSchema
                $bulkCopy.BulkCopyTimeOut = $BulkCopyTimeout
                $bulkCopy.BatchSize = $BulkCopyBatchSize
                $bulkCopy.WriteToServer($sqlReader)
                $sqlReader.Close()
                $bulkCopy.Close()
            }
        }

        $sourceConn.Close()

    }
    catch {
        [Exception]$ex = $_.Exception
        write-host $ex.Message
    }
    finally {
        #Return value if any
    }
}

[string[]] $tables = @(
    'dbo.ZEPTER POLAND SETUP ONLY !!!$No_ Series$437dbf0e-84ff-417a-965d-ed2bb9650972',
    'dbo.ZEPTER POLAND SETUP ONLY !!!$No_ Series$437dbf0e-84ff-417a-965d-ed2bb9650972$ext',
    'dbo.ZEPTER POLAND SETUP ONLY !!!$No_ Series Relationship$437dbf0e-84ff-417a-965d-ed2bb9650972',
    'dbo.ZEPTER POLAND SETUP ONLY !!!$No_ Series Line$437dbf0e-84ff-417a-965d-ed2bb9650972')

Get-SQLTable `
    -SourceSQLInstance hqdbt01 `
    -SourceDatabase AdventureWorks2016 `
    -TargetSQLInstance hqdbt01\sql2017 `
    -TargetDatabase AdventureWorks2012 `
    -Tables $tables `
    -BulkCopyBatchSize 5000