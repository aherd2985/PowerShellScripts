Get-AdUser -Filter * -Properties OfficePhone,MobilePhone,HomePhone |

Where-Object {$_.UserPrincipalName -match "andrew.herd"} |

Format-Table UserPrincipalName,OfficePhone,MobilePhone,HomePhone
