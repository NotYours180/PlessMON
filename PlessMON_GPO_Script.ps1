$FOL_share = read-host -Prompt "what is the path to the folder? ie: \\192.168.1.1\share\folder"
import-module $FOL_share\PlessMON-Agent.psm1
Get-Reports_PMA
$hostname = hostname
$rep = Get-childitem -path "C:\PlessMON_Agent\Reports"
$FOL_share = read-host -Prompt "what is the path to the folder? ie: \\192.168.1.1\share\folder"
If(test-path $FOL_share\$hostname)
{
    foreach($file in $rep.Name)
        {
            If(test-path $FOL_share\$hostname\$file)
            {}
            Else
            {
                Copy-Item -Path C:\PlessMON_Agent\Reports\$file -Destination $FOL_share\$hostname\$file
            }
        }
}
Else
{
    New-Item -ItemType Directory $FOL_share\$hostname
    foreach($file in $rep.Name)
    {
        If(test-path $FOL_share\$hostname\$file)
        {}
        Else
        {
            Copy-Item -Path C:\PlessMON_Agent\Reports\$file -Destination $FOL_share\$hostname\$file
        }
    }
}