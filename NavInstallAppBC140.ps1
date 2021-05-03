Exit

Import-Module 'C:\Program Files\Microsoft Dynamics 365 Business Central\140\Service\NavAdminTool.ps1'
Import-Module 'C:\NAV\Powershell\NavRestoreTool.ps1'
#Remove-Module 'C:\NAV\Powershell\NavRestoreTool.ps1'

Get-NAVAppInfo -ServerInstance N140_ITA_TEST_14015_TOOL -Tenant Default
#Get-NAVAppRuntimePackage -ServerInstance N140_ITA_TEST_14015_TOOL -Name 'Company Hub' -Version 17.0.16993.0 -Path 'C:\NAV\Install_App\Company Hub_17.0.16993.0_runtime.app'


################
# 14.0.16993.0 #
###############################################################################################################

###########
# Publish #
###########
Sync-NAVApp      -ServerInstance N140_ITA_TEST_14015_TOOL -Name 'AL Translate Tool' -Tenant 'Default' -Mode Clean
Unpublish-NAVApp -ServerInstance N140_ITA_TEST_14015_TOOL -Name "AL Translate Tool" -Version 1.0.0.0
Publish-NAVApp   -ServerInstance N140_ITA_TEST_14015_TOOL -Path "C:\NAV\Install_App\Bech-Andersen Consult ApS_AL Translate Tool_1.0.0.0.app" -SkipVerification
Sync-NAVApp      -ServerInstance N140_ITA_TEST_14015_TOOL -Name "AL Translate Tool" -Version 1.0.0.0 -Mode ForceSync -Tenant 'Default' -Force

###########
# Install #
###########
Uninstall-NAVApp -ServerInstance N140_ITA_TEST_14015_TOOL -Name "AL Translate Tool" -Version 1.0.0.0
Install-NAVApp -ServerInstance N140_ITA_TEST_14015_TOOL -Name "AL Translate Tool" -Version 1.0.0.0

