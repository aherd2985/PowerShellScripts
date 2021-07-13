$Users = Get-ADUser -Filter * -Properties EmailAddress
$Username = ($Users | Where {$_.UserPrincipalName -match "andrew.herd"}).SamAccountName
    $Params = @{
        Identity = $Username
        OfficePhone = '9995550100'
        MobilePhone = '9995550100'
        HomePhone = '9995550100'
    }
If ($Username) {Set-ADUser @Params; Write-Host "Set new phone info for $Username"}
