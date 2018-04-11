#---------------------------------------------------------------------------------------------------------------------------------------------
#/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#//////////////////////////////////////////Functionality Section//////////////////////////////////////////////////////////////////////////////
#/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#---------------------------------------------------------------------------------------------------------------------------------------------
#Description: Install directories and build files to make PlessMON work
#Version: 1; 8APR18
#Permissions: User
function Install-PlessMON_PMA
{
    #Build "c:\PlessMON_Agent"
    If(test-path "c:\PlessMON_Agent"){}
    Else{new-item -ItemType directory -Path c:\PlessMON_Agent}

    #Build "c:\PlessMON_Agent\Reports"
    If(test-path "c:\PlessMON_Agent\Reports"){}
    Else{new-item -ItemType directory -Path c:\PlessMON_Agent\Reports}

    #Build c:\PlessMON_Agent\Reports\Installed.txt
    If(test-path "c:\PlessMON_Agent\Reports\Installed.txt"){}
    Else{new-item -ItemType file -Path c:\PlessMON_Agent\Reports\Installed.txt;$date = get-date; echo "PlessMON was installed on $date." >> "c:\PlessMON_Agent\Reports\Installed.txt" }

    #Build "c:\PlessMON_Agent\Reports\RM102-04-SysInfo-Template.csv"
    Add-Content -Path "c:\PlessMON_Agent\Reports\SysInfo-Template.csv"  -Value '"Null"'
    $sysinfo_csv = @(
      '"Null"' )
    $sysinfo_csv | foreach { Add-Content -Path  "c:\PlessMON_Agent\Reports\SysInfo-Template.csv" -Value $_ }
    #Build "c:\PlessMON_Agent\Temp"
    If(test-path "c:\PlessMON_Agent\Temp"){}
    Else{new-item -ItemType directory -Path "c:\PlessMON_Agent\Temp"}
    #Build "c:\PlessMON_Agent\Log"
    If(test-path "c:\PlessMON_Agent\Log"){}
    Else{new-item -ItemType directory -Path "c:\PlessMON_Agent\Log"}
}
#---------------------------------------------------------------------------------------------------------------------------------------------
#Description: Setup Variables for PlessMON Module and functions
#Version: 4; 8APR18
#Permissions: User
function Initialize-PlessMON_PMA
{
    $install_test = test-path c:\PlessMON_Agent\Reports\installed.txt
    If($install_test -eq $false){Install-PlessMON_PMA}
    $Global:Hostname = hostname
    $Global:Date = get-date -format hhmm-ddMMMyy
    $Global:Today = get-date -format d
    $Global:Date2 = get-date -format ddMMMyy
    $Global:Titles = @($subject.PSObject.Properties.Name)
    $Global:DIR_Root = "c:\PlessMON_Agent"
    $Global:DIR_Scripts = "$DIR_Root\Scripts"
    $Global:DIR_Reports = "$DIR_Root\Reports"
    $Global:DIR_Temp = "$DIR_Root\Temp"
    $Global:DIR_Log = "$DIR_Root\Log"
    $Global:FIL_SysInfo_Template = "$Dir_Reports\SysInfo-Template.csv"
    $Global:FIL_Hardware_Baseline = "$Dir_Reports\$Hostname-Hardware-Baseline.csv"
    $Global:FIL_Hardware_New = "$Dir_Reports\$Hostname-Hardware-$Date2.csv"
    $Global:FIL_Software_Baseline = "$Dir_Reports\$Hostname-Software-Baseline.csv"
    $Global:FIL_Software_New = "$Dir_Reports\$Hostname-Software-$Date2.csv"
    If(test-path "$Dir_Log\WIN_Security_Log_PM.txt")
    {} 
    Else 
    {
        New-Item -ItemType file -Path "$Dir_Log\WIN_Security_Log_PM.txt"
    }
    $Global:Fil_WIN_SEC_Log_PM = "$Dir_Log\WIN_Security_Log_PM.txt"
}
#---------------------------------------------------------------------------------------------------------------------------------------------
#Description: Push the information from the sysinfo function into a csv to be read and compared later
#Version: 2; 8APR18
#Permissions: Administrator
function Push-CSV_PM
{
Initialize-PlessMON_PMA
foreach ($key in $Titles) 
    { 
        $arr | Add-Member -MemberType NoteProperty -Name "$key-$title" -value $subject.$key -ErrorAction SilentlyContinue
    }
$arr | Export-Csv $FIL_SysInfo -NoTypeInformation
}
#---------------------------------------------------------------------------------------------------------------------------------------------
#/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#//////////////////////////////////////////Baseline Creation Section//////////////////////////////////////////////////////////////////////////
#/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#----------------------------------------------------------------------------------------------------------------------------------------------
#Description: Get Hardware information
#Version: 4; 8APR18
#Permissions: Administrator
function Get-HardwareInfo_PMA
{
    Initialize-PlessMON_PMA
    If (Test-Path $FIL_Hardware_New)
    {
        $Global:arr = Import-CSV $FIL_Hardware_New; $Global:FIL_SysInfo = $FIL_Hardware_New
    }
    Else
    {
        If(test-path $FIL_Hardware_Baseline)
        {
            $Global:arr = Import-CSV $FIL_SysInfo_Template; $Global:FIL_SysInfo = $FIL_Hardware_New
        }
        Else
        {
            $Global:arr = Import-CSV $FIL_SysInfo_Template; $Global:FIL_SysInfo = $FIL_Hardware_Baseline
        }
    }
    $Processor = get-wmiobject win32_Processor | select Name,Caption,DeviceID,NumberOfCores,NumberOfEnabledCore,NumberOfLogicalProcessors,ThreadCount,L2CacheSize,L3CacheSize,ProcessorId,VirtualizationFirmwareEnabled,SocketDesignation,Revision,Manufacturer
    $subject = $Processor
    $title = "CPU"
    Push-CSV_PM
    write-host "$title information has been added to $FIL_SysInfo"

    $Memory = get-wmiobject win32_physicalmemory | select PSComputerName,BankLabel,Capacity,Caption,ConfiguredClockSpeed,DeviceLocator,FormFactor
    $subject = $Memory
    $title = "Mem"
    Push-CSV_PM
    write-host "$title information has been added to $FIL_SysInfo"

    $Memory_SN = get-wmiobject -class win32_physicalmemory | select manufacturer,serialnumber
    $subject = $Memory_SN
    $title = "Mem-SN"
    Push-CSV_PM
    write-host "$title information has been added to $FIL_SysInfo"

    $PhysicalDrive = get-physicaldisk | select FriendlyName,SerialNumber,MediaType,Size
    $subject = $PhysicalDrive
    $title = "Disk"
    Push-CSV_PM
    write-host "$title information has been added to $FIL_SysInfo"

    $Users = get-ciminstance win32_useraccount | sort status | format-table -property name,description,disabled,accounttype,pscomputername
    $subject = $Users
    $title = "User"
    Push-CSV_PM
    write-host "$title information has been added to $FIL_SysInfo"
} 
#----------------------------------------------------------------------------------------------------------------------------------------------
#Description: Get Hardware information
#Version: 4; 8APR18
#Permissions: Administrator
function Get-SoftwareInfo_PMA
{
    Initialize-PlessMON_PMA
    If (Test-Path $FIL_Software_New)
    {
        $Global:arr = Import-CSV $FIL_Software_New; $Global:FIL_SysInfo = $FIL_Software_New
    }
Else
    {
        If(test-path $FIL_Software_Baseline)
        {
            $Global:arr = Import-CSV $FIL_SysInfo_Template; $Global:FIL_SysInfo = $FIL_Software_New
        }
        Else
        {
            $Global:arr = Import-CSV $FIL_SysInfo_Template; $Global:FIL_SysInfo = $FIL_Software_Baseline
        }
    }
    Initialize-PlessMON_PMA
    $Global:OperatingSystem = get-wmiobject win32_OperatingSystem | select Caption,OSArchitecture,BuildNumber,Codeset,ServicePackMajorVersion,ServicePackMinorVersion,OSLanguage,OSType,InstallDate,CountryCode,EncryptionLevel,RegisteredUser,SerialNumber
    $Global:subject = $OperatingSystem
    $title = "OS"
    Push-CSV_PM
    write-host "$title information has been added to $FIL_SysInfo"

    $BIOS = get-wmiobject win32_bios | select Version,SMBIOSBIOSVersion,SMBIOSMajorVersion,SMBIOSMinorVersion,SerialNumber,Name,ReleaseDate,CurrentLanguage
    $subject = $BIOS
    $title = "BIOS"
    Push-CSV_PM
    write-host "$title information has been added to $FIL_SysInfo"

    $PowershellVersion_3 = $PSVersionTable.PSVersion
    $subject = $PowershellVersion_3
    $title = "PS-Ver3"
    Push-CSV_PM
    write-host "$title information has been added to $FIL_SysInfo"

    $Applications = wmic product get name,version
    $subject = $Applications
    $title = "Applications"
    Push-CSV_PM
    write-host "$title information has been added to $FIL_SysInfo"

    $Users = get-ciminstance win32_useraccount | sort status | format-table -property name,description,disabled,accounttype,pscomputername
    $subject = $Users
    $title = "User"
    Push-CSV_PM
    write-host "$title information has been added to $FIL_SysInfo"
} 
#---------------------------------------------------------------------------------------------------------------------------------------------
#Description: Get System information and build report
#Version: 4; Added 8APR18
#Permissions: User
function Get-SystemReport_PMA
{
    Initialize-PlessMON_PMA   
    $Fil_SysInfoReportHTML = "$Global:Dir_Reports\Baseline_@$Hostname#$Date.html"
    $filename_xml = "$Global:Dir_Reports\Baseline_@$Hostname#$Date.xml"
    $HTMLBaseline = "$Fil_SysInfoReportHTML"
    $XMLBaseline = "$filename_xml"
    $ReportTitle = "$Hostname System-Information"
    $CSSlink = "$Global:Dir_Reports\table.css"
    $Global:OperatingSystem = get-wmiobject win32_OperatingSystem | select Caption,OSArchitecture,BuildNumber,Codeset,ServicePackMajorVersion,ServicePackMinorVersion,OSLanguage,OSType,InstallDate,CountryCode,EncryptionLevel,RegisteredUser,SerialNumber
    $Global:OperatingSystem2 = $Global:OperatingSystem | convertto-html -CssUri $CSSlink -Title $ReportTitle  -Body "<h1>$ReportTitle</h1>`n<h5>Updated: on $(Date)</h5>`n<h2>Operating System</h2>"
    $BIOS = get-wmiobject win32_bios | select Version,SMBIOSBIOSVersion,SMBIOSMajorVersion,SMBIOSMinorVersion,SerialNumber,Name,ReleaseDate,CurrentLanguage | convertto-html -Body "<h2>BIOS</h2>"
    $PowershellVersion_3 = $PSVersionTable.PSVersion | convertto-html -Body "<h2>Powershell_v3</h2>"
    $Processor = get-wmiobject win32_Processor | select Name,Caption,DeviceID,NumberOfCores,NumberOfEnabledCore,NumberOfLogicalProcessors,ThreadCount,L2CacheSize,L3CacheSize,ProcessorId,VirtualizationFirmwareEnabled,SocketDesignation,Revision,Manufacturer | convertto-html -Body "<h2>Processor</h2>"
    $Memory = get-wmiobject win32_physicalmemory | select PSComputerName,BankLabel,Capacity,Caption,ConfiguredClockSpeed,DeviceLocator,FormFactor | convertto-html -Body "<h2>Memory</h2>"
    $Memory_SN = get-wmiobject -class win32_physicalmemory | select manufacturer,serialnumber | convertto-html -Body "<h2>RAM Chip Serial Numbers</h2>"
    $PhysicalDrive = get-physicaldisk | select FriendlyName,SerialNumber,MediaType,Size | convertto-html -Body "<h2>Physical Drive Info</h2>"
    $Users = get-ciminstance win32_useraccount | sort status | format-table -property name,description,disabled,accounttype,pscomputername
    Add-Content $HTMLBaseline $OperatingSystem2
    Add-Content $HTMLBaseline $BIOS
    Add-Content $HTMLBaseline $Processor
    Add-Content $HTMLBaseline $Memory_SN
    Add-Content $HTMLBaseline $Memory
    add-Content $HTMLBaseline $PhysicalDrive
    Add-Content $HTMLBaseline $PhysicalDriveSN
    Add-Content $HTMLBaseline $PowershellVersion_3
    write-host "Your System-info report has been built and is located at $Fil_SysInfoReportHTML"
}
#---------------------------------------------------------------------------------------------------------------------------------------------
#Description: Get Logons (win event 4624 starting at 0001 this morning)
#Version: 1
#Permissions: Administrator
function Get-Logon_PMA
{
    Initialize-PlessMON_PMA
    $lst_log_index = get-content -path "$Fil_WIN_SEC_Log_PM"
    $event = Get-Eventlog -LogName Security -InstanceId 4624 -After $Today
    foreach($e in $event)
        {if ( $lst_log_index -contains $e.index){} else{$e | Format-Table -wrap >> $Fil_WIN_SEC_Log_PM}}
    Write-host "All win event logs '4624' starting from 0001 this morning have been written to '$Fil_WIN_SEC_Log_PM'"
}
#---------------------------------------------------------------------------------------------------------------------------------------------
