& 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchLinuxEngine
Start-Sleep -Seconds 10
docker stop SqlServer
docker start SqlServer
& 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchWindowsEngine
Start-Sleep -Seconds 10

docker stop zsi-live
docker start zsi-live

docker stop zmk-live
docker start zmk-live

docker stop zcz-live
#docker start zcz-live

docker stop zsk-live
#docker start zsk-live

docker stop zjo-live
#docker start zjo-live