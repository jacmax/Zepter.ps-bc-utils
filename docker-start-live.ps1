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
docker stop zcz-live
docker stop zfr-live

docker stop zbg-live
docker stop zch-live
docker stop zde-live
docker stop zeg-live
docker stop zlt-live
docker stop zus-live

docker stop zhu-live
docker stop zjo-live
docker stop zuz-live
docker stop ita-live

docker stop zba-live
docker stop zby-live

docker stop w1-bc250
docker stop cz-bc250
docker stop fr-bc250
docker stop de-bc250
docker stop at-bc250

Read-Host -Prompt 'Press any key to continue. . .'
