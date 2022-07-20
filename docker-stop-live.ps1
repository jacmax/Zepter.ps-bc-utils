& 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchWindowsEngine
Start-Sleep -Seconds 10
docker stop zsi-live
docker stop zmk-live
docker stop zcz-live
docker stop zsk-live
docker stop zjo-live
& 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchLinuxEngine
Start-Sleep -Seconds 10
docker stop SqlServer
