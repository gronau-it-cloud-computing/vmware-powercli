Add-PSSnapin VMware.VimAutomation.Core

# ----------------------
# Specify vCenter Server
# ----------------------
$vc = $env:VCENTER_SERVER

$vi = Connect-VIServer -Server $vc

Write-Host "Connect vCenter : " $vi.IsConnected

$uidPattern = "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"

$results = @()

Foreach ($vm in Get-VM) {

    $results += $vm | Select-Object @{Name="ResourcePool"; Expression={$_.ResourcePool -replace " \($uidPattern\)", ""}},
        @{Name="Name"; Expression={$_.Name -replace  " \($uidPattern\)", ""}},
        @{Name="PowerState"; Expression={$_.PowerState -replace "Powered", ""}},
        @{Name="ToolsInstallerMounted"; Expression={($_ | Get-View).Summary.Runtime.ToolsInstallerMounted}},
        @{Name="ISO"; Expression={ $(if (($_ | Get-CDDrive).IsoPath -ne $null){(($_ | Get-CDDrive).IsoPath)}else{("")}) }}
}

$results | Where-Object {$_.PowerState -eq "On" -and ($_.ToolsInstallerMounted -eq $True -or $_.ISO -ne "")} | sort ResourcePool,Name,PowerState | ft -AutoSize
