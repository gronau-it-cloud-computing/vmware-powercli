Add-PSSnapin VMware.VimAutomation.Core

# ----------------------
# Specify vCenter Server
# ----------------------
$vc = $env:VCENTER_SERVER

$vi = Connect-VIServer -Server $vc

Write-Host "Connect vCenter : " $vi.IsConnected

$uidPattern = "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"

$results = @()

foreach ($snapshot in Get-Snapshot -VM *){

    $results += $snapshot | Select-Object @{Name="ResourcePool"; Expression={$_.VM.ResourcePool -replace " \($uidPattern\)", ""}},
        @{Name="Name"; Expression={$_.VM.Name -replace  " \($uidPattern\)", ""}},
        @{Name="PowerState"; Expression={$_.PowerState -replace "Powered", ""}},
        @{Name="Created"; Expression={([Datetime]$_.Created).ToString("yyyy/MM/dd HH:mm:ss")}},
        @{Name="SizeGB"; Expression={"{0:F2}" -f $_.SizeGB}}

}

$results | sort ResourcePool,Name,Created | ft -AutoSize
