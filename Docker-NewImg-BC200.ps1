param (
    [validateset('', 'zsi', 'zmk', 'zba', 'zcz', 'zsk', 'zfr', 'zby')]
    [String] $ZepterCountryParam = 'w1'
)
. (Join-Path $PSScriptRoot '.\docker-newimg-sqlfile.ps1')
if ($ZepterCountryParam -eq 'w1') {
    Docker-NewImg-Sqlfile -ZepterCountryParam $ZepterCountryParam -ContainerVersionParam '20.0'
}
else {
    Docker-NewImg-Sqlfile -ZepterCountryParam $ZepterCountryParam
}