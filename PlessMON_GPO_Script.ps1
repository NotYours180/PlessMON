import-module \\192.168.5.230\Pless_Data\490_Tech_Projects\440_Scripts\Pless_MON\PlessMON-Agent.psm1
Get-Reports_PMA
$hostname = hostname
$rep = Get-childitem -path "C:\PlessMON_Agent\Reports"
If(test-path "\\192.168.5.230\Pless_Data\490_Tech_Projects\440_Scripts\Pless_MON\$hostname")
{
    foreach($file in $rep.Name)
        {
            If(test-path "\\192.168.5.230\Pless_Data\490_Tech_Projects\440_Scripts\Pless_MON\$hostname\$file")
            {}
            Else
            {
                Copy-Item -Path C:\PlessMON_Agent\Reports\$file -Destination \\192.168.5.230\Pless_Data\490_Tech_Projects\440_Scripts\Pless_MON\$hostname\$file
            }
        }
}
Else
{
    New-Item -ItemType Directory \\192.168.5.230\Pless_Data\490_Tech_Projects\440_Scripts\Pless_MON\$hostname
    foreach($file in $rep.Name)
    {
        If(test-path "\\192.168.5.230\Pless_Data\490_Tech_Projects\440_Scripts\Pless_MON\$hostname\$file")
        {}
        Else
        {
            Copy-Item -Path C:\PlessMON_Agent\Reports\$file -Destination \\192.168.5.230\Pless_Data\490_Tech_Projects\440_Scripts\Pless_MON\$hostname\$file
        }
    }
}