& $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchLinuxEngine -Verbose
$env:DOCKER_CONTEXT = 'desktop-linux'
docker run `
    -e "ACCEPT_EULA=Y"  `
    -e "SA_PASSWORD=ZitP@ssword1" `
    -e 'MSSQL_PID=Developer' `
    -p 1433:1433 `
    --name SqlServer `
    --hostname devSQL `
    -d mcr.microsoft.com/mssql/server:2022-latest
