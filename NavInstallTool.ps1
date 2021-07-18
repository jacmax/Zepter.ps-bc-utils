Import-Module 'C:\Program Files\Microsoft Dynamics 365 Business Central\180\Service\NavAdminTool.ps1'

function InstallExtension
{
    param ($instance, $name, $version, $path)
    #Write-Host -ForegroundColor Yellow "$instance"
    Write-Host -ForegroundColor Yellow "$name $version ... "
    #Write-Host -ForegroundColor Yellow "$path"
    $oldErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'
    Try
    {
        Try
        {      
            Publish-NAVApp -ServerInstance "$instance" -Path "$path" -SkipVerification
        }
        Catch {}
        Sync-NAVApp -ServerInstance "$instance" -Name "$name" -Version "$version" -Mode ForceSync -Tenant 'Default' -force 
        Try
        {      
            Start-NAVAppDataUpgrade -ServerInstance "$instance" -Name "$name" -Version "$version" -Tenant 'Default' 
        }
        Catch
        {
            Install-NAVApp -ServerInstance "$instance" -Name "$name" -Version "$version"
        }    
    }
    Catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Host -ForegroundColor Red "Instalation of $name on $instance failed! $ErrorMessage"
        Write-Host -ForegroundColor Yellow "$FailedItem"
        Break
    }
    Finally
    {
        Write-Host -ForegroundColor Yellow "Installed"
        Write-Host
        $ErrorActionPreference = $oldErrorActionPreference
    }
}

function UnpublishExtension
{
    param ($Instance, $Name)
    $oldErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'
    Try
    {
        Get-NAVAppInfo -ServerInstance $Instance -Tenant Default -TenantSpecificPrope | `
            Where Name -like $Name | `
            ForEach-Object {
                Try
                {
                    #Write-Host -ForegroundColor Green "$instance"
                    Write-Host -ForegroundColor Green $_.Name $_.Version " ... " -NoNewline
                    if ($_.IsInstalled) {
                        Uninstall-NAVApp -ServerInstance $Instance -Name $_.Name -Tenant Default -Force
                        Write-Host -ForegroundColor Green "Uninstalled ... " -NoNewline
                    }
                    Unpublish-NAVApp -ServerInstance $Instance -Name $_.Name -Version $_.Version
                }
                Finally
                {
                    Write-Host -ForegroundColor Green "Unpublished"
                }
            }
    }
    Catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Host -ForegroundColor Red "Unpublished of $name on $instance failed! $ErrorMessage"
        Write-Host -ForegroundColor Yellow "$FailedItem"
        Break
    }
    Finally
    {
        $ErrorActionPreference = $oldErrorActionPreference
    }
}
