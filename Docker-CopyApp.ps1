$DockerID = '003ff780b816'

$Workspace = 'DEV-EXT'

if ($Workspace -eq 'DEV-EXT') {
    $BaseAppVer            = '18.0.23013.23796'
    $CommonAppVer          = '0.1.0.1'
    $SalesItemAppVer       = '0.1.0.1'
    $RepresentativeAppVer  = '0.1.0.0'
    $SalesContractAppVer   = '0.1.0.1'
    $PaymentAppVer         = '0.1.0.0'
    $PersonalVoucherAppVer = '0.1.0.1'
    $CommissionAppVer      = '0.1.0.3'
    $GDPRAppVer            = '0.1.0.1'
    $ImportPurchaseAppVer  = '0.1.0.1'
    $SampleAppVer          = '0.1.0.0'
    $ServiceAppVer         = '0.1.0.2'
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
docker cp "D:\DEV-EXT\ps-bc-utils\Docker-Database-CRONUS.ps1" "$($DockerID):/AppZS/"
docker cp "D:\DEV-EXT\ps-bc-utils\Docker-Database-NAV-ITA-TEST-180.ps1" "$($DockerID):/AppZS/"

docker start $($DockerID)
Write-Host 'Docker has started'

docker exec $($DockerID) powershell -command "C:\AppZS\Docker-InstallApp.ps1"
