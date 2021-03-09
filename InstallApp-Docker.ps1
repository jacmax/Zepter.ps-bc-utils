Import-Module 'C:\Program Files\Microsoft Dynamics NAV\170\Service\NavAdminTool.ps1'

function InstallExtension
{
    param ($instance, $name, $version, $path)
    #Write-Host -ForegroundColor Yellow "$instance"
    #Write-Host -ForegroundColor Yellow "$name"
    #Write-Host -ForegroundColor Yellow "$version"
    #Write-Host -ForegroundColor Yellow "$path"
    $oldErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'
    Try
    {
        Publish-NAVApp          -ServerInstance "$instance" -Path "$path" -SkipVerification
        Sync-NAVApp             -ServerInstance "$instance" -Name "$name" -Version "$version" -Mode ForceSync -Tenant 'Default' -force 
        Sync-NAVApp             -ServerInstance "$instance" -Name "$name" -Version "$version" -Tenant 'Default' 
        #Start-NAVAppDataUpgrade -ServerInstance "$instance" -Name "$name" -Version "$version" -Tenant 'Default' 
        Install-NAVApp          -ServerInstance "$instance" -Name "$name" -Version "$version"
    }
    Catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Host -ForegroundColor Red "Instalation of $name on $instance failed! $ErrorMessage"
        Break
    }
    Finally
    {
        Write-Host -ForegroundColor Yellow "Installed ..."
        $ErrorActionPreference = $oldErrorActionPreference
    }
}

Start-NAVServerInstance -ServerInstance BC

################
# 17.0.16993.0 #
###############################################################################################################
#############
# Uninstall #
#############
<#
Uninstall-NAVApp -ServerInstance BC -Name "AMC Banking 365 Fundamentals" -Version 17.0.16993.0
Uninstall-NAVApp -ServerInstance BC -Name "Company Hub" -Version 17.0.16993.0
Uninstall-NAVApp -ServerInstance BC -Name "Essential Business Headlines" -Version 17.0.16993.0
Uninstall-NAVApp -ServerInstance BC -Name "Late Payment Prediction" -Version 17.0.16993.0
Uninstall-NAVApp -ServerInstance BC -Name "PayPal Payments Standard" -Version 17.0.16993.0
Uninstall-NAVApp -ServerInstance BC -Name "Sales and Inventory Forecast" -Version 17.0.16993.0
Uninstall-NAVApp -ServerInstance BC -Name "Send To Email Printer" -Version 17.0.16993.0
Uninstall-NAVApp -ServerInstance BC -Name "WorldPay Payments Standard" -Version 17.0.16993.0
Uninstall-NAVApp -ServerInstance BC -Name "_Exclude_APIV2_" -Version 17.0.16993.0
Uninstall-NAVApp -ServerInstance BC -Name "_Exclude_APIV1_" -Version 17.0.16993.0
Uninstall-NAVApp -ServerInstance BC -Name "_Exclude_ClientAddIns_" -Version 17.0.16993.0
#>

Get-NAVAppInfo -ServerInstance BC -Tenant Default | Where Name -like 'ZS*' | Uninstall-NAVApp -ServerInstance BC -Tenant Default -Force

Unpublish-NAVApp -ServerInstance BC -Name 'ZS Service' -Version 0.1.0.0
Unpublish-NAVApp -ServerInstance BC -Name 'ZS Sample' -Version 0.1.0.0
Unpublish-NAVApp -ServerInstance BC -Name 'ZS Import Purchase' -Version 0.1.0.0
Unpublish-NAVApp -ServerInstance BC -Name 'ZS Commission' -Version 0.1.0.0
Unpublish-NAVApp -ServerInstance BC -Name 'ZS GDPR' -Version 0.1.0.0
Unpublish-NAVApp -ServerInstance BC -Name 'ZS Personal Voucher' -Version 0.1.0.0
Unpublish-NAVApp -ServerInstance BC -Name 'ZS Payment' -Version 0.1.0.0
Unpublish-NAVApp -ServerInstance BC -Name 'ZS Sales Contract' -Version 0.1.0.0
Unpublish-NAVApp -ServerInstance BC -Name 'ZS Representative' -Version 0.1.0.0
Unpublish-NAVApp -ServerInstance BC -Name 'ZS Sales Item' -Version 0.1.0.0
Unpublish-NAVApp -ServerInstance BC -Name 'ZS Common' -Version 0.1.0.0

#Unpublish-NAVApp -ServerInstance BC170 -Name 'Designer_31940ea7-4480-4e99-94fd-04f9b8463a48' -Version 1.0.0.0	

<#
Uninstall-NAVApp -ServerInstance BC170 -Name "Application" -Version 17.0.16993.0
Uninstall-NAVApp -ServerInstance BC170 -Name "Base Application" -Version 17.0.16993.0
#>
#Uninstall-NAVApp -ServerInstance BC170 -Name "System Application" -Version 17.0.16993.0

################
# 17.0.16993.1 #
###############################################################################################################
####################
# Base Application #
####################
<#
Uninstall-NAVApp -ServerInstance BC -Name "Base Application" -Version 17.0.16993.1
Unpublish-NAVApp -ServerInstance BC -Name "Base Application" -Version 17.0.16993.1

Publish-NAVApp          -ServerInstance BC -Path 'C:\AppZS\Microsoft_Base Application_17.0.16993.1.app' -SkipVerification
Sync-NAVApp             -ServerInstance BC -Name 'Base Application' -Version 17.0.16993.1 -Mode ForceSync -Tenant 'Default' -Force
Start-NAVAppDataUpgrade -ServerInstance BC -Name 'Base Application' -Version 17.0.16993.1 -Tenant 'Default'
Install-NAVApp          -ServerInstance BC -Name "Base Application" -Version 17.0.16993.1
Install-NAVApp          -ServerInstance BC -Name "Application" -Version 17.0.16993.0

Install-NAVApp -ServerInstance BC -Name "AMC Banking 365 Fundamentals" -Version 17.0.16993.0
Install-NAVApp -ServerInstance BC -Name "Company Hub" -Version 17.0.16993.0
Install-NAVApp -ServerInstance BC -Name "Essential Business Headlines" -Version 17.0.16993.0
Install-NAVApp -ServerInstance BC -Name "Late Payment Prediction" -Version 17.0.16993.0
Install-NAVApp -ServerInstance BC -Name "PayPal Payments Standard" -Version 17.0.16993.0
Install-NAVApp -ServerInstance BC -Name "Sales and Inventory Forecast" -Version 17.0.16993.0
Install-NAVApp -ServerInstance BC -Name "Send To Email Printer" -Version 17.0.16993.0
Install-NAVApp -ServerInstance BC -Name "WorldPay Payments Standard" -Version 17.0.16993.0
Install-NAVApp -ServerInstance BC -Name "_Exclude_APIV2_" -Version 17.0.16993.0
Install-NAVApp -ServerInstance BC -Name "_Exclude_APIV1_" -Version 17.0.16993.0
Install-NAVApp -ServerInstance BC -Name "_Exclude_ClientAddIns_" -Version 17.0.16993.0
#>

##############
# Extensions #
##############
InstallExtension -instance 'BC' -name 'ZS Common'           -version '0.1.0.0' -path 'C:\AppZS\Zepter IT_ZS Common_0.1.0.0.app'
InstallExtension -instance 'BC' -name 'ZS Sales Item'       -version '0.1.0.0' -path 'C:\AppZS\Zepter IT_ZS Sales Item_0.1.0.0.app'
InstallExtension -instance 'BC' -name 'ZS Representative'   -version '0.1.0.0' -path 'C:\AppZS\Zepter IT_ZS Representative_0.1.0.0.app'
InstallExtension -instance 'BC' -name 'ZS Sales Contract'   -version '0.1.0.0' -path 'C:\AppZS\Zepter IT_ZS Sales Contract_0.1.0.0.app'
InstallExtension -instance 'BC' -name 'ZS Payment'          -version '0.1.0.0' -path 'C:\AppZS\Zepter IT_ZS Payment_0.1.0.0.app'
InstallExtension -instance 'BC' -name 'ZS Personal Voucher' -version '0.1.0.0' -path 'C:\AppZS\Zepter IT_ZS Personal Voucher_0.1.0.0.app'
InstallExtension -instance 'BC' -name 'ZS GDPR'             -version '0.1.0.0' -path 'C:\AppZS\Zepter IT_ZS GDPR_0.1.0.0.app'
InstallExtension -instance 'BC' -name 'ZS Commission'       -version '0.1.0.0' -path 'C:\AppZS\Zepter IT_ZS Commission_0.1.0.0.app'
InstallExtension -instance 'BC' -name 'ZS Import Purchase'  -version '0.1.0.0' -path 'C:\AppZS\Zepter IT_ZS Import Purchase_0.1.0.0.app'
InstallExtension -instance 'BC' -name 'ZS Sample'           -version '0.1.0.0' -path 'C:\AppZS\Zepter IT_ZS Sample_0.1.0.0.app'
InstallExtension -instance 'BC' -name 'ZS Service'          -version '0.1.0.0' -path 'C:\AppZS\Zepter IT_ZS Service_0.1.0.0.app'

####################
# Restart Services #
###############################################################################################################
$fn = "C:\AppZS\ZITBC170.flf";
Import-NAVServerLicense -ServerInstance BC -LicenseFile $fn
Sync-NAVTenant -ServerInstance BC -Mode ForceSync -Force

#Restart-NAVServerInstance -ServerInstance BC170
#Stop-NAVServerInstance -ServerInstance BC170
#Start-NAVServerInstance -ServerInstance BC170

#& "C:\Program Files\internet explorer\iexplore.exe" 'http://localhost:8080/BC170'