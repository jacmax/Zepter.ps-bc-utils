Import-Module 'd:\DEV-EXT\ps-bc-utils\NavExtensions.ps1'

$DockerID = '003ff780b816'

$Workspace = 'DEV-EXT'

if ($Workspace -eq 'DEV-EXT') {
    #$BaseAppVerOld         = '18.0.23013.23795'
    $BaseAppVer            = '18.0.23013.23796'

    $CommonAppVer          = (GetNavExtensions | Where-Object name -eq 'Common').version
    $SalesItemAppVer       = (GetNavExtensions | Where-Object name -eq 'SalesItem').version
    $RepresentativeAppVer  = (GetNavExtensions | Where-Object name -eq 'Representative').version
    $SalesContractAppVer   = (GetNavExtensions | Where-Object name -eq 'SalesContract').version
    $PaymentAppVer         = (GetNavExtensions | Where-Object name -eq 'Payment').version
    $PersonalVoucherAppVer = (GetNavExtensions | Where-Object name -eq 'PersonalVoucher').version
    $CommissionAppVer      = (GetNavExtensions | Where-Object name -eq 'Commission').version
    $GDPRAppVer            = (GetNavExtensions | Where-Object name -eq 'GDPR').version
    $ImportPurchaseAppVer  = (GetNavExtensions | Where-Object name -eq 'ImportPurchase').version
    $SampleAppVer          = (GetNavExtensions | Where-Object name -eq 'Sample').version
    $ServiceAppVer         = (GetNavExtensions | Where-Object name -eq 'Service').version
} else {
    $BaseAppVer            = '18.5.22500.1'
    $CommonAppVer          = '0.1.0.5'
    $SalesItemAppVer       = '0.1.0.5'
    $RepresentativeAppVer  = '0.1.0.0'
    $SalesContractAppVer   = '0.1.0.5'
    $PaymentAppVer         = '0.1.0.0'
    $PersonalVoucherAppVer = '0.1.0.5'
    $CommissionAppVer      = '0.1.0.5'
    $GDPRAppVer            = '0.1.0.5'
    $ImportPurchaseAppVer  = '0.1.0.5'
    $SampleAppVer          = '0.1.0.0'
    $ServiceAppVer         = '0.1.0.5'
}

docker stop $($DockerID)

#docker mkdir $($DockerID):/AppZS/

docker cp "D:\$Workspace\APP\BC180\Microsoft_Base Application_$BaseAppVer.app" "$($DockerID):/AppZS/"

docker cp "D:\$Workspace\APP\Zepter IT_ZS Common_$CommonAppVer.app" "$($DockerID):/AppZS/"
docker cp "D:\$Workspace\APP\Zepter IT_ZS Sales Item_$SalesItemAppVer.app" "$($DockerID):/AppZS/"
docker cp "D:\$Workspace\APP\Zepter IT_ZS Representative_$RepresentativeAppVer.app" "$($DockerID):/AppZS/"
docker cp "D:\$Workspace\APP\Zepter IT_ZS Sales Contract_$SalesContractAppVer.app" "$($DockerID):/AppZS/"
docker cp "D:\$Workspace\APP\Zepter IT_ZS Payment_$PaymentAppVer.app" "$($DockerID):/AppZS/"
docker cp "D:\$Workspace\APP\Zepter IT_ZS Personal Voucher_$PersonalVoucherAppVer.app" "$($DockerID):/AppZS/"
docker cp "D:\$Workspace\APP\Zepter IT_ZS Commission_$CommissionAppVer.app" "$($DockerID):/AppZS/"
docker cp "D:\$Workspace\APP\Zepter IT_ZS GDPR_$GDPRAppVer.app" "$($DockerID):/AppZS/"
docker cp "D:\$Workspace\APP\Zepter IT_ZS Import Purchase_$ImportPurchaseAppVer.app" "$($DockerID):/AppZS/"
docker cp "D:\$Workspace\APP\Zepter IT_ZS Sample_$SampleAppVer.app" "$($DockerID):/AppZS/"
docker cp "D:\$Workspace\APP\Zepter IT_ZS Service_$ServiceAppVer.app" "$($DockerID):/AppZS/"

#docker cp "D:\$Workspace\APP\NAV_ITA_TEST_180.bak" "$($DockerID):/AppZS/"

docker cp "D:\$Workspace\APP\ZITBC180.flf" "$($DockerID):/AppZS/"
docker cp "D:\DEV-EXT\ps-bc-utils\Docker-InstallApp.ps1" "$($DockerID):/AppZS/"
docker cp "D:\DEV-EXT\ps-bc-utils\NavInstallTool.ps1" "$($DockerID):/AppZS/"
docker cp "D:\DEV-EXT\ps-bc-utils\NavExtensions.ps1" "$($DockerID):/AppZS/"
docker cp "D:\DEV-EXT\ps-bc-utils\Docker-Database-CRONUS.ps1" "$($DockerID):/AppZS/"
docker cp "D:\DEV-EXT\ps-bc-utils\Docker-Database-NAV-ITA-TEST-180.ps1" "$($DockerID):/AppZS/"

docker start $($DockerID)
Write-Host 'Docker has started'

docker exec $($DockerID) powershell -command "C:\AppZS\Docker-InstallApp.ps1"
