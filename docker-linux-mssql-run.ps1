& 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchLinuxEngine
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=ZitP@ssword1" -e 'MSSQL_PID=Developer' -p 1433:1433 --name SqlServer --hostname devSQL -d mcr.microsoft.com/mssql/server:2019-latest
