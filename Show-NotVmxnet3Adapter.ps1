Add-PSSnapin VMware.VimAutomation.Core

# ------------------------------------------------
# Specify exclusion VM Name (value is $true)
# ------------------------------------------------
$exclusionVM = @{
    "VM_NAME" = $true;
}

# ----------------------
# Specify vCenter Server
# ----------------------
$vc = $env:VCENTER_SERVER

$vi = Connect-VIServer -Server $vc

Write-Host "Connect vCenter : " $vi.IsConnected

$uidPattern = "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"

$results = @()

foreach ($vm in Get-VM){

    $adapters = Get-NetworkAdapter -VM $vm

    if ($exclusionVM.ContainsKey(($vm.Name -replace  " \($uidPattern\)", ""))) {
        continue
    }

    foreach ($adp in $adapters){

        if ($adp.Type -ieq "vmxnet3"){
            continue
        }

        $results += $vm | Select-Object @{Name="ResourcePool"; Expression={$_.ResourcePool -replace " \($uidPattern\)", ""}},
            @{Name="VM Name"; Expression={$_.Name -replace  " \($uidPattern\)", ""}},
            @{Name="PowerState"; Expression={$_.PowerState -replace "Powered", ""}},
            @{Name="Type"; Expression={$adp.Type}},
            @{Name="Adapter #"; Expression={$adp.Name -replace "ネットワーク アダプタ ", ""}},
            @{Name="Network"; Expression={$adp.NetworkName}},
            @{Name="MAC"; Expression={$adp.MacAddress}}
    }
}

$results | Sort-Object "ResourcePool", "VM Name", "Adapter #" | ft -AutoSize
