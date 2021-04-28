$securePassword = ConvertTo-SecureString 'ZitP@ssword1' -AsPlainText -Force
New-NavServerUser -ServerInstance "BC" -Tenant 'Default' -Username 'admin-backup' -Password $securePassword 
New-NavServerUserPermissionSet -ServerInstance "BC" -Tenant 'Default' -username 'admin-backup' -PermissionSetId SUPER
