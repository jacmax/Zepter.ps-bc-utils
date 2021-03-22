Import-Module 'C:\Program Files\Microsoft Dynamics NAV\170\Service\NavAdminTool.ps1'

Set-NAVServerConfiguration -ServerInstance "BC" -KeyName "DatabaseInstance" -KeyValue "SQLEXPRESS"
Set-NAVServerConfiguration -ServerInstance "BC" -KeyName "DatabaseServer" -KeyValue "localhost"
Set-NAVServerConfiguration -ServerInstance "BC" -KeyName "DatabaseName" -KeyValue "CRONUS"

Restart-NAVServerInstance -ServerInstance "BC" -Verbose
Get-NAVServerConfiguration -ServerInstance "BC"
