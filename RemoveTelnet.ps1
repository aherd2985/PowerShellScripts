<# 
  Better to remove telnet if it it not neccessary
#>

Import-Module ServerManager

Remove-WindowsFeature telnet-client
