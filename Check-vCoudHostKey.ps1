Add-PSSnapin VMware.VimAutomation.Core

# ----------------------
# Specify vCenter Server
# ----------------------
$vc = $env:VCENTER_SERVER

$vi = Connect-VIServer -Server $vc

Write-Host "Connect vCenter : " $vi.IsConnected

$results = @()

foreach ($h in Get-VMHost){

    try{
        $mp = ($h | Get-EsxCli).vcloud.fence.getfenceinfo() | Select-Object ModuleParameters | Select "ModuleParameters"
        $isException = ""
    }
    catch [Exception]{
        $isException = "Exception!!"
    }
    finally{
        if ($mp -match "Host key: (0x0)"){
            $hostKey = $Matches[1]
            $result = "NG"
        }
        elseif ($mp -match "Host key: (.+)"){
            $hostKey = $Matches[1]
            $result = "OK"
        }
        else{
            $hostKey = "0x0"
            $result = "NG"
        }
        $results += [PSCustomObject] @{ "Host" = $h.Name; "Host key" = $hostKey; "Result" = $result; "Exception" = $isException }
    }
}
$results | Sort-Object "Host" | ft -AutoSize
