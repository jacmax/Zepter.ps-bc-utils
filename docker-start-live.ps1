& 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchLinuxEngine
Start-Sleep -Seconds 10
docker start SqlServer
& 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchWindowsEngine
Start-Sleep -Seconds 10
docker start zsi-live
docker start zmk-live
docker start zcz-live
docker start zsk-live
#docker start zjo-live