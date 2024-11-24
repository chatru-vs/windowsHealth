$strComputer=$env:COMPUTERNAME
$PerfDataLog=@()
$PerfDataLog += "Performence test starts in"
$Pro_PT=Get-Counter -computername $strComputer -Counter "\processor(_total)\% processor time" | Select-Object -ExpandProperty countersamples |Select-Object -Property cookedvalue
$Pro_PrT=Get-Counter -computername $strComputer -Counter "\processor(_total)\% privileged time" | Select-Object -ExpandProperty countersamples |Select-Object -Property cookedvalue
$Mem_AM=Get-Counter -computername $strComputer -Counter "\Memory\Available MBytes" | Select-Object -ExpandProperty countersamples |Select-Object -Property cookedvalue
$Mem_CBIU=Get-Counter -computername $strComputer -Counter "\Memory\% Commited Byes in Use" | Select-Object -ExpandProperty countersamples |Select-Object -Property cookedvalue
$Mem_PS=Get-Counter -computername $strComputer -Counter "\Memory\Pages/sec" | Select-Object -ExpandProperty countersamples |Select-Object -Property cookedvalue
$Mem_PFS=Get-Counter -computername $strComputer -Counter "\Memory\Page Faults/sec" | Select-Object -ExpandProperty countersamples |Select-Object -Property cookedvalue
$NTDS_LBT = Get-Counter -computername $strComputer -Counter "\NTDS\LDAP Bind Time" | Select-Object -ExpandProperty countersamples |Select-Object -Property cookedvalue
$PD_AvgDiskSR = Get-Counter -computername $strComputer -Counter "\PhysicalDisk(_total)\Avg. Disk sec/Read" | Select-Object -ExpandProperty countersamples |Select-Object -Property cookedvalue
$PD_AvgDiskST = Get-Counter -computername $strComputer -Counter "\PhysicalDisk(_total)\Avg. Disk sec/Transfer" | Select-Object -ExpandProperty countersamples |Select-Object -Property cookedvalue
$PD_AvgDiskSW = Get-Counter -computername $strComputer -Counter "\PhysicalDisk(_total)\Avg. Disk sec/Write" | Select-Object -ExpandProperty countersamples |Select-Object -Property cookedvalue
$PD_AvgDiskQL = Get-Counter -computername $strComputer -Counter "\PhysicalDisk(_total)\Avg. Disk Queue Length" | Select-Object -ExpandProperty countersamples |Select-Object -Property cookedvalue
$PD_DT = Get-Counter -computername $strComputer -Counter "\PhysicalDisk(_total)\% Disk Time" | Select-Object -ExpandProperty countersamples |Select-Object -Property cookedvalue
$Sys_PrQL = Get-Counter -computername $strComputer -Counter "\System\Processor Queue Length" | Select-Object -ExpandProperty countersamples |Select-Object -Property cookedvalue

$PerfDataLog+="CPU | "+"\processor(_total)\% processor time = " + $Pro_PT.cookedvalue
$PerfDataLog+="CPU | "+"\processor(_total)\% privileged time = " + $Pro_PrT.cookedvalue
$PerfDataLog+="Memory | "+"\Memory\Available MBytes = " + $Mem_AM.cookedvalue
$PerfDataLog+="Memory | "+"\Memory\% Commited Byes in Use = " + $Mem_CBIU.cookedvalue
$PerfDataLog+="Memory | "+"\Memory\Pages/sec= " + $Mem_PS.cookedvalue
$PerfDataLog+="Memory | "+"\Memory\Page Faults/sec = " + $Mem_PFS.cookedvalue
$PerfDataLog+="Memory | "+"\NTDS\LDAP Bind Time = " + $NTDS_LBT.cookedvalue
$PerfDataLog+="Memory | "+"\PhysicalDisk(_total)\Avg. Disk sec/Read = " + $PD_AvgDiskSR.cookedvalue
$PerfDataLog+="Memory | "+"\PhysicalDisk(_total)\Avg. Disk sec/Transfer = " + $PD_AvgDiskST.cookedvalue
$PerfDataLog+="Memory | "+"\PhysicalDisk(_total)\Avg. Disk sec/Write " + $PD_AvgDiskSW.cookedvalue
$PerfDataLog+="Memory | "+"\PhysicalDisk(_total)\Avg. Disk Queue Length = " + $PD_AvgDiskQL.cookedvalue
$PerfDataLog+="Memory | "+"\PhysicalDisk(_total)\% Disk Time = " + $PD_DT.cookedvalue
$PerfDataLog+="Memory | "+"\System\Processor Queue Length = " + $Sys_PrQL.cookedvalue

$PerfDataLog | Out-File c:\Adperformence.csv