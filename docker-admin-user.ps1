. (Join-Path $PSScriptRoot 'docker-NewNavServerUser.ps1')

param (
    [validateset('zhu', 'zjo', 'zuz', 'zbg', 'zch', 'zde', 'zlt', 'zus')]
    [String] $ZepterCountryParam
)

Docker-NewNavServerUser $ZepterCountryParam