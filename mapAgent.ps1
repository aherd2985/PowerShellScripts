Import-Module PSAtera
Import-Module PSWriteHTML

function Map-Agents($CustomerID) {
  # Get all Atera Agents for the customer
  $Agents = Get-AteraAgents -CustomerID $CustomerID
  New-Html -TitleText "Atera Agent Map" -Online -FilePath $PSScriptRoot\Atera-Agents.html {
    New-HTMLTabStyle -SlimTabs
    New-HTMLTab -Name "Atera Agents" {
      New-HTMLSection -HeaderText "Atera Networks" {
        New-HTMLPanel {
          New-HTMLDiagram -Height 'calc(85vh)' {
            New-DiagramOptionsPhysics -RepulsionNodeDistance 150 -Solver repulsion
            # Generate Level 1: Public network
            $Agents | Select-Object ReportedFromIP -Unique | ForEach-Object {
              New-DiagramNode -Label $_.ReportedFromIP -Level 1 -ColorBackground Red
            }

            $PrivateNetworks = @()
            foreach($Agent in $Agents) {
              # Ignore any self-assigned IP addresses
              $Agent.IPAddresses | Where-Object { !($_.StartsWith("169.254.")) } | ForEach-Object {
                $Address = [IPAddress]$_
                $AddressBytes = $Address.GetAddressBytes()
                $Network = ""
                # Stupidly get the Network ID based on the Class of IP address
                if ($AddressBytes[0] -eq 10) { # Class A
                  $Network = "10.0.0.0/8"
                } elseif ($AddressBytes[0] -eq 172 -and $AddressBytes[1] -ge 16 -and $AddressBytes[1] -le 31) { # Class B
                  $Network = "172.16.$($AddressBytes[2]).0/16"
                } elseif ($AddressBytes[0] -eq 192 -and $AddressBytes[1] -eq 168) {
                  $Network = "192.168.$($AddressBytes[2]).0/24"                
                }
                # Create the Diagram node for the network ID under the public IP address
                if ($PrivateNetworks -notcontains "$Network,$($Agent.ReportedFromIP)") { 
                  $PrivateNetworks += "$Network,$($Agent.ReportedFromIP)"
                  New-DiagramNode -Label $Network -Id "$Network,$($Agent.ReportedFromIP)" -To $Agent.ReportedFromIP -Level 2 -ArrowsToEnabled -ColorBackground Green
                }
                # Create the Diagram node for the agent under it's corrent network ID
                New-DiagramNode -Label "$($Agent.MachineName)`t$($Address.IPAddressToString)" -Level 3 -To "$Network,$($Agent.ReportedFromIP)" -ArrowsToEnabled
              }
            }
          }
        }
      }
    }
  } -ShowHTML
}