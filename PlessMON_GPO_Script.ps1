import-module \\192.168.5.230\Pless_Data\490_Tech_Projects\440_Scripts\Pless_MON\PlessMON-Agent.psm1
Get-Reports_PMA
$hostname = hostname
New-Item -ItemType Directory \\192.168.5.230\Pless_Data\490_Tech_Projects\440_Scripts\Pless_MON\$hostname
Move-Item -Path C:\PlessMON_Agent\Reports\*.html -Destination \\192.168.5.230\Pless_Data\490_Tech_Projects\440_Scripts\Pless_MON\$hostname\