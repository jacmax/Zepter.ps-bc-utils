. (Join-Path $PSScriptRoot 'docker-NewNavServerUser.ps1')

param (
    [validateset('zhu', 'zjo', 'zuz', 'zbg', 'zch', 'zde', 'zlt', 'zus', 'zeg')]
    [String] $ZepterCountryParam
)

Docker-NewNavServerUser $ZepterCountryParam