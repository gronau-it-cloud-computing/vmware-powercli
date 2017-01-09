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
        @{Name="ToolsVersion"; Expression={($_ | Get-View).config.tools.toolsVersion}},
        @{Name="ToolStatus"; Expression={($_ | Get-View).Guest.ToolsVersionStatus -replace "guestTools", ""}}
}

$results | Where-Object {$_.ToolStatus -notin ("Current", "Unmanaged")} | sort ResourcePool,Name | ft -AutoSize
