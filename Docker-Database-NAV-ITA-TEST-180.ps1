Import-Module 'C:\Program Files\Microsoft Dynamics NAV\180\Service\NavAdminTool.ps1'

Set-NAVServerConfiguration -ServerInstance "BC" -KeyName "DatabaseInstance" -KeyValue "SQLEXPRESS"
Set-NAVServerConfiguration -ServerInstance "BC" -KeyName "DatabaseServer" -KeyValue "localhost"
Set-NAVServerConfiguration -ServerInstance "BC" -KeyName "DatabaseName" -KeyValue "NAV_ITA_TEST_180"

Restart-NAVServerInstance -ServerInstance "BC" -Verbose
Get-NAVServerConfiguration -ServerInstance "BC"