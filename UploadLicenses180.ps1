#Exit

Import-Module 'C:\Program Files\Microsoft Dynamics 365 Business Central\180\Service\NavAdminTool.ps1'

#=======#
# BC180 #
#=======#

$fn = "Z:\APP\ZITBC180.flf";
Import-NAVServerLicense -ServerInstance BC180 -LicenseFile $fn

Sync-NAVTenant -ServerInstance BC180 -Mode ForceSync -Force

Restart-NAVServerInstance -ServerInstance BC180