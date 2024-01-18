& $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchWindowsEngine -Verbose
#Start-Sleep -Seconds 10
docker stop zsi-live
docker stop zmk-live
docker stop zcz-live
docker stop zsk-live
docker stop zjo-live
& $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchLinuxEngine -Verbose
#Start-Sleep -Seconds 10
docker stop SqlServer
