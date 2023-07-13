docker run --name SqlServer --hostname=devSQL --user=mssql --mac-address=02:42:ac:11:00:02 --env=SA_PASSWORD=ZitP@ssword1 --env=MSSQL_PID=Developer --env=ACCEPT_EULA=Y --env=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin -p 1433:1433 --restart=no --label='com.microsoft.product=Microsoft SQL Server' --label='com.microsoft.version=15.0.4312.2' --label='org.opencontainers.image.ref.name=ubuntu' --label='org.opencontainers.image.version=20.04' --label='vendor=Microsoft' --runtime=runc -d mcr.microsoft.com/mssql/server:2019-latest

#docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=ZitP@ssword1" -e 'MSSQL_PID=Developer' -p 1433:1433 --name SqlServer --hostname devSQL -d mcr.microsoft.com/mssql/server:2019-latest

#wsl --shutdown
#wsl --export docker-desktop-data D:\docker\docker-desktop-data.tar
#wsl --unregister docker-desktop-data
#wsl --import docker-desktop-data D:\docker\DockerDesktopWSL D:\docker\docker-desktop-data.tar --version 2
