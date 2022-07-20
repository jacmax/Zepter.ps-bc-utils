& 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchLinuxEngine
Start-Sleep -Seconds 10
docker start SqlServer
$sqlBackup = get-item -path d:\TEMP\SqlServer\*.bak
foreach($fileBak in $sqlBackup){
    write-host $fileBak.name
    docker cp $fileBak.FullName SqlServer:/var/backups
    Remove-Item $fileBak
}
