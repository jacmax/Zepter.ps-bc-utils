& $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchLinuxEngine -Verbose
$env:DOCKER_CONTEXT = 'desktop-linux'
docker run -d --name=unifi-network-application
<#
-e PUID=1000 `
-e PGID=1000 `
-e TZ=Etc/UTC `
-e MONGO_USER=unifi `
-e MONGO_PASS= `
-e MONGO_HOST=unifi-db `
    -e MONGO_PORT=27017 `
    -e MONGO_DBNAME=unifi `
    -e MONGO_AUTHSOURCE=admin `
    -e MEM_LIMIT=1024 '#optional' `
    -e MEM_STARTUP=1024 '#optional' `
    -e MONGO_TLS= '#optional' `
    -p 8443:8443 `
    -p 3478:3478/udp `
    -p 10001:10001/udp `
    -p 8080:8080 `
    -p 1900:1900/udp '#optional' `
    -p 8843:8843 '#optional' `
    -p 8880:8880 '#optional' `
    -p 6789:6789 '#optional' `
    -p 5514:5514/udp '#optional' `
    -v /path/to/unifi-network-application/data:/config `
    --restart unless-stopped `
    lscr.io/linuxserver/unifi-network-application:latest
#>