param (
    [validateset('', 'zhu', 'zjo', 'zuz', 'ita')]
    [String] $ZepterCountryParam = 'w1'
)
. (Join-Path $PSScriptRoot '.\docker-newimg-sqlfile.ps1')
if ($ZepterCountryParam -eq 'w1') {
    Docker-NewImg-Sqlfile -ZepterCountryParam $ZepterCountryParam -ContainerVersionParam '14.0'
}
else {
    Docker-NewImg-Sqlfile -ZepterCountryParam $ZepterCountryParam
}