param (
    [validateset('', 'zbg', 'zch', 'zde', 'zlt', 'zus')]
    [String] $ZepterCountryParam = 'w1'
)
. (Join-Path $PSScriptRoot '.\docker-newimg-sqlfile.ps1')
if ($ZepterCountryParam -eq 'w1') {
    Docker-NewImg-Sqlfile -ZepterCountryParam $ZepterCountryParam -ContainerVersionParam '10.0'
}
else {
    Docker-NewImg-Sqlfile -ZepterCountryParam $ZepterCountryParam
}