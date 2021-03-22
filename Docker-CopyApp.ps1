$DickerID = '146d0a79be9c'

docker stop $($DickerID)

#docker mkdir $($DickerID):/AppZS/

docker cp "D:\DEV-EXT\APP\Microsoft_Base Application_17.0.16993.1.app" "$($DickerID):/AppZS/"

docker cp "D:\DEV-EXT\APP\Zepter IT_ZS Common_0.1.0.0.app" "$($DickerID):/AppZS/"
docker cp "D:\DEV-EXT\APP\Zepter IT_ZS Sales Item_0.1.0.1.app" "$($DickerID):/AppZS/"
docker cp "D:\DEV-EXT\APP\Zepter IT_ZS Representative_0.1.0.0.app" "$($DickerID):/AppZS/"
docker cp "D:\DEV-EXT\APP\Zepter IT_ZS Sales Contract_0.1.0.0.app" "$($DickerID):/AppZS/"
docker cp "D:\DEV-EXT\APP\Zepter IT_ZS Payment_0.1.0.0.app" "$($DickerID):/AppZS/"
docker cp "D:\DEV-EXT\APP\Zepter IT_ZS Personal Voucher_0.1.0.0.app" "$($DickerID):/AppZS/"
docker cp "D:\DEV-EXT\APP\Zepter IT_ZS Commission_0.1.0.0.app" "$($DickerID):/AppZS/"
docker cp "D:\DEV-EXT\APP\Zepter IT_ZS GDPR_0.1.0.0.app" "$($DickerID):/AppZS/"
docker cp "D:\DEV-EXT\APP\Zepter IT_ZS Import Purchase_0.1.0.0.app" "$($DickerID):/AppZS/"
docker cp "D:\DEV-EXT\APP\Zepter IT_ZS Sample_0.1.0.0.app" "$($DickerID):/AppZS/"
docker cp "D:\DEV-EXT\APP\Zepter IT_ZS Service_0.1.0.0.app" "$($DickerID):/AppZS/"

docker cp "D:\DEV-EXT\APP\NAV_ITA_TEST_170.bak" "$($DickerID):/AppZS/"

docker cp "D:\DEV-EXT\APP\ZITBC170.flf" "$($DickerID):/AppZS/"
docker cp "D:\DEV-EXT\ps-bc-utils\Docker-InstallApp.ps1" "$($DickerID):/AppZS/"
docker cp "D:\DEV-EXT\ps-bc-utils\Docker-Database-CRONUS.ps1" "$($DickerID):/AppZS/"
docker cp "D:\DEV-EXT\ps-bc-utils\Docker-Database-NAV-ITA-TEST-170.ps1" "$($DickerID):/AppZS/"

docker start $($DickerID)
