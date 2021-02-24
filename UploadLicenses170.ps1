#Exit

Import-Module 'C:\Program Files\Microsoft Dynamics 365 Business Central\170\Service\NavAdminTool.ps1'

#=======#
# BC170 #
#=======#

$fn = "Z:\APP\ZITBC170.flf";
Import-NAVServerLicense -ServerInstance BC170 -LicenseFile $fn

Sync-NAVTenant -ServerInstance BC170 -Mode ForceSync -Force

Restart-NAVServerInstance -ServerInstance BC170