Add-PSSnapin VMware.VimAutomation.Core

# ----------------------
# Specify vCenter Server
# ----------------------
$vc = $env:VCENTER_SERVER

$vi = Connect-VIServer -Server $vc

Write-Host "Connect vCenter : " $vi.IsConnected

$uidPattern = "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"

$hosts = Get-Cluster | Get-VMHost

$results = @()

$Datastores = @{}
Get-Datastore | Select-Object Id, Name | foreach { $Datastores.Add($_.Id, $_.Name) }

function Join-DatastoreName {

    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [String[]] $datastoreIdList
    )

    begin{
    }

    process{
        [String] $datastoreNameCSV  = ""

        foreach ($id in $datastoreIdList)
        {
            $datastoreNameCSV  += $Datastores[$id] + ","
        }

        $datastoreNameCSV -replace ".$"
    }

    end{
    }
}

Foreach ($h in $hosts) {

    $results += Get-VMHost $h | Get-VM | Select-Object @{Name="VMHost"; Expression={$_.VMHost.NetworkInfo.HostName}},
        @{Name="ResourcePool"; Expression={$_.ResourcePool -replace  " \($uidPattern\)", ""}},
        @{Name="Name"; Expression={$_.Name -replace  " \($uidPattern\)", ""}},
        @{Name="PowerState"; Expression={$_.PowerState -replace "Powered", ""}},
        @{Name="Datastore"; Expression={Join-DatastoreName ($_ | Select-Object DatastoreIdList).DatastoreIdList}}
}

$results | Sort-Object -Property VMHost,ResourcePool,Name,PowerState,Datastore
