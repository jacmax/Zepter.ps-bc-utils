param (
    [validateset('', 'at', 'ca', 'ch', 'cz', 'de', 'fr', 'ru', 'us')]
    [String] $CountryParam = 'w1'
)
. (Join-Path $PSScriptRoot '.\docker-newimg-sqlfile.ps1')
Docker-NewImg-Sqlfile -CountryParam $CountryParam -ContainerVersionParam '22.0'
