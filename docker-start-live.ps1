& $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchLinuxEngine -Verbose
$env:DOCKER_CONTEXT = 'desktop-linux'
#Start-Sleep -Seconds 30
&docker restart SqlServer
&docker restart dockers
&docker restart mapa

& $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchWindowsEngine -Verbose
$env:DOCKER_CONTEXT = 'desktop-windows'
#Start-Sleep -Seconds 30

docker stop zsi-live
docker stop zmk-live

docker stop zbg-live
docker stop zch-live
docker stop zde-live
docker stop zlt-live
docker stop zus-live

docker stop zhu-live
docker stop zjo-live
docker stop zuz-live

docker stop zba-live
docker stop zby-live
docker stop zcz-live
docker stop zsk-live
docker stop zfr-live

docker stop cz-bc220
docker stop fr-bc220
docker stop ru-bc220

docker stop w1-bc100
docker stop w1-bc200
docker stop w1-bc230

#Read-Host -Prompt 'Press any key to continue. . .'
