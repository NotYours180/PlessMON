#---------------------------------------------------------------------------------------------------------------------------------------------
#/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#//////////////////////////////////////////Functionality Section//////////////////////////////////////////////////////////////////////////////
#/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#---------------------------------------------------------------------------------------------------------------------------------------------
#Description: Install directories and build files to make PlessMON work
#Version: 1; 8APR18
#Permissions:
function Install-PlessMON_PM
{
    #Build "c:\PlessMON"
    If(test-path "c:\PlessMON"){}
    Else{new-item -ItemType directory -Path c:\PlessMON}

    #Build "c:\PlessMON\Scripts"
    If(test-path "c:\PlessMON\Scripts"){}
    Else{new-item -ItemType directory -Path c:\PlessMON\Scripts}

    #Build "c:\PlessMON\Reports"
    If(test-path "c:\PlessMON\Reports"){}
    Else{new-item -ItemType directory -Path c:\PlessMON\Reports}

    #Build c:\PlessMON\Reports\Installed.txt
    If(test-path "c:\PlessMON\Reports\Installed.txt"){}
    Else{new-item -ItemType file -Path c:\PlessMON\Reports\Installed.txt;$date = get-date; echo "PlessMON was installed on $date." >> "C:\PlessMON\Reports\Installed.txt" }

    #Build "c:\PlessMON\Reports\RM102-04-SysInfo-Template.csv"
    Add-Content -Path C:\PlessMON\Reports\SysInfo-Template.csv  -Value '"Null"'
    $sysinfo_csv = @(
      '"Null"' )
    $sysinfo_csv | foreach { Add-Content -Path  C:\PlessMON\Reports\SysInfo-Template.csv -Value $_ }
    #Build "c:\PlessMON\Temp"
    If(test-path "c:\PlessMON\Temp"){}
    Else{new-item -ItemType directory -Path c:\PlessMON\Temp}
    #Build "c:\PlessMON\Log"
    If(test-path "c:\PlessMON\Log"){}
    Else{new-item -ItemType directory -Path c:\PlessMON\Log}
}
#---------------------------------------------------------------------------------------------------------------------------------------------
#Description: Setup Variables for PlessMON Module and functions
#Version: 4; 8APR18
#Permissions:User
function Initialize-PlessMON_PM
{
    $install_test = test-path c:\PlessMON\Reports\installed.txt
    If($install_test -eq $false){install-PlessMON_PM}
    $Global:Hostname = hostname
    $Global:Date = get-date -format hhmm-ddMMMyy
    $Global:Today = get-date -format d
    $Global:Date2 = get-date -format ddMMMyy
    $Global:Titles = @($subject.PSObject.Properties.Name)
    $Global:DIR_Root = "C:\PlessMON"
    $Global:DIR_Scripts = "$DIR_Root\Scripts"
    $Global:DIR_Reports = "$DIR_Root\Reports"
    $Global:DIR_Temp = "$DIR_Root\Temp"
    $Global:DIR_Log = "$DIR_Root\Log"
    $Global:FIL_SysInfo_Template = "$Dir_Reports\SysInfo-Template.csv"
    $Global:FIL_SysInfo_Baseline = "$Dir_Reports\$Hostname-SysInfo-Baseline.csv"
    $Global:FIL_SysInfo_New = "$Dir_Reports\$Hostname-SysInfo-$Date2.csv"
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
#Permissions: 
function Push-CSV_PM
{
Initialize-PlessMON_PM
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
#Description: Get System information
#Version: 4; 8APR18
#Permissions: 
function Get-SystemInfo_PM
{
    Initialize-PlessMON_PM
    If (Test-Path $FIL_SysInfo_New)
    {
        $Global:arr = Import-CSV $FIL_SysInfo_New; $Global:FIL_SysInfo = $FIL_SysInfo_New
    }
Else
    {
        If(test-path $FIL_SysInfo_Baseline)
        {
            $Global:arr = Import-CSV $FIL_SysInfo_Template; $Global:FIL_SysInfo = $FIL_SysInfo_New
        }
        Else
        {
            $Global:arr = Import-CSV $FIL_SysInfo_Template; $Global:FIL_SysInfo = $FIL_SysInfo_Baseline
        }
    }
    Initialize-PlessMON_PM
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

    $PhysicalDrive = wmic diskdrive get interfacetype,mediatype,model
    $subject = $PhysicalDrive
    $title = "Disk"
    Push-CSV_PM
    write-host "$title information has been added to $FIL_SysInfo"

    $PhysicalDriveSN = get-wmiobject win32_physicalmedia | select serialnumber
    $subject = $PhysicalDriveSN
    $title = "Disk-SN"
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
#Permissions: 
function Get-SystemReport_PM
{
    Initialize-PlessMON_PM   
    #$filename = "$Date-$Hostname.html"
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
    $PhysicalDrive = wmic diskdrive get interfacetype,mediatype,model | convertto-html -Body "<h2>Physical Drive Info</h2>"
    $PhysicalDriveSN = get-wmiobject win32_physicalmedia | select serialnumber | convertto-html -Body "<h2>Physical Drive Serial Number</h2>"
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