$a = Get-Content 'd:\DEV-EXT\bc-sales-items\Sales Items - App\app.json' -raw | ConvertFrom-Json
$v = [version]$a.version
$v = [version]::New($v.Major, $v.Minor, $v.Build + 1, 0)
$a.version = $v.ToString()
foreach ($app in $a.dependencies) {
    if ($app.publisher -eq 'Zepter IT') {
        $app.version = $a.version
    }
}
$a

#$a | ConvertTo-Json -depth 32 | set-content 'd:\DEV-EXT\bc-integration-hu\Integration HU - App\app-new.json'
