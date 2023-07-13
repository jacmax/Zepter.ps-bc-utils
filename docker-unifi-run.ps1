docker run -d --init `
    --restart=unless-stopped `
    -p 8080:8080 -p 8443:8443 -p 3478:3478/udp `
    -e TZ='Europe/Warsaw' `
    -v ~/unifi:/unifi `
    --user unifi `
    --name unifi `
    jacobalberty/unifi