Add-PSSnapin VMware.VimAutomation.Core
Add-PSSnapin VMware.VimAutomation.VDS

# ------------------------------------
# Specify dvPortNumber & dvSwitch Name
# ------------------------------------
$dvPortNumber = "123"
$dvSwitch = "dvSwitchName"

# ----------------------
# Specify vCenter Server
# ----------------------
$vc = $env:VCENTER_SERVER

$vi = Connect-VIServer -Server $vc

Write-Host "Connect vCenter : " $vi.IsConnected

$dvPort = Get-VDPort -VDSwitch $dvSwitch -Key $dvPortNumber

$vm = (Get-VM -Id ($dvPort.ExtensionData.Connectee.ConnectedEntity.ToString()) | Select-Object @{Name="Name"; Expression={$_.Name -replace  " \([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\)", ""}},
    PowerState,
    VMHost,
    @{Name="ResourcePool"; Expression={$_.ResourcePool -replace  " \([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\)", ""}})

$vm | Add-Member -MemberType NoteProperty -Name IsLinkUp -Value $dvPort.IsLinkUp
$vm | Add-Member -MemberType NoteProperty -Name MacAddress -Value $dvPort.MacAddress
$vm | Add-Member -MemberType NoteProperty -Name VlanId -Value $dvPort.VlanConfiguration.VlanId

$vm
