$a = Get-Content 'd:\DEV-EXT\bc-integration-hu\Integration HU - App\app.json' -raw | ConvertFrom-Json
$v = [version]$a.version
$v = [version]::New($v.Major,$v.Minor,$v.Build,$v.Revision+1)
$a.version = $v.ToString()
$a | ConvertTo-Json -depth 32| set-content 'd:\DEV-EXT\bc-integration-hu\Integration HU - App\app-new.json'
