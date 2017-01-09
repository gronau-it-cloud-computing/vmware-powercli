Add-PSSnapin VMware.VimAutomation.Core
Add-PSSnapin VMware.VimAutomation.VDS

# ------------------------------------------------
# Specify exclusion PortGroupName (value is $true)
# ------------------------------------------------
$exclusionVDPortgroup = @{
    "PortGroupName1" = $true;
}

# ------------------------------------
# Specify dvSwitch Name
# ------------------------------------
$dvSwitch = "dvSwitchName"

# ----------------------
# Specify vCenter Server
# ----------------------
$vc = $env:VCENTER_SERVER

$vi = Connect-VIServer -Server $vc

Write-Host "Connect vCenter : " $vi.IsConnected

$results = @()

$results = Get-VDSwitch -Name "$dvSwitch" | Get-VDPortgroup | Get-VDUplinkTeamingPolicy | Select-Object VDPortgroup,
        LoadBalancingPolicy,
        FailoverDetectionPolicy,
        NotifySwitches,
        FailBack,
        ActiveUplinkPort | Where-Object { -not $exclusionVDPortgroup.ContainsKey($_.VDPortgroup.ToString()) -and (
                                            $_.LoadBalancingPolicy -ne "LoadBalanceIP" -or
                                            $_.FailoverDetectionPolicy -ne "LinkStatus" -or
                                            $_.NotifySwitches -ne $true -or
                                            $_.FailBack -ne $false)}

$results | ft -AutoSize
