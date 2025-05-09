param (
    [validateset('w1', 'at', 'ca', 'ch', 'cz', 'de', 'fr', 'pl', 'ru', 'us')]
    [String] $CountryParam = 'w1',
    [validateset('OnPrem', 'Sandbox')]
    [String] $ContainerType = 'Sandbox',
    [ValidateSet('Latest', 'First', 'All', 'Closest', 'SecondToLastMajor', 'Current', 'NextMinor', 'NextMajor', 'Daily', 'Weekly')]
    [String] $ContainerSelect = 'Weekly'
)
. (Join-Path $PSScriptRoot '.\docker-newimg-sqlfile.ps1')
Docker-NewImg-Sqlfile -CountryParam $CountryParam -ContainerVersionParam '26.0' -ContainerType $ContainerType -ContainerSelect $ContainerSelect
