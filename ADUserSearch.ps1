﻿Get-ADUser -Filter {name -like "*and*"} -Properties Description,info | Select Name,samaccountname,Description,info | Sort Name