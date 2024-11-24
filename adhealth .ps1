$startTime = $(get-date)
$srtComputer=$env:COMPUTERNAME
$DSRMPath = C:\dsrm.log
$healthcheck = "\\" + "$srtComputer" + "\ADhealthcheck"
if(!(Test-path $healthcheck) -or !(Test-path "$dir\ADHealthCheck\log")){
    New-Item "$dir\ADhealthCheck" -type "directory" -ErrorAction SilentlyContinue
    New-SMBShare -Name "ADHealthCheck" -Path "$dir\ADHealthCheck" -FullAccess "RISE\domain admins" -ReadAccess "authenticated users" -ErrorAction SilentlyContinue
    New-Item "$dir\ADHealthCheck\log" -type "directory" -ErrorAction SilentlyContinue
}
Get-ChildItem "$dir\ADHealthCheck\log" | Remome-Item
#####Running DCdiag################
$DCDIAGDATALOG=@()
$dcdiag=@()
$i = 0
$DCDIAGDATALOG += "'nDCDIAG Starts' n"
$dcdiag = (Dcdiag.exe /v /s:$srtComputer)
if((dcdiag -eq $null) -or ($dcdiag | Select-String -pattern "Ldap search capability attribute search failed on server")){
    $DCDIAGDATALOG+="could not run the dcdiag"
}
else{
    $FailedTestList = @($dcdiag | Select-String -Pattern "failed test")
    $allfailedtests = @()
    {
        if($FailedTestList)
        {
            foreach($test in $FailedTestList){
                $obj =($test -split "test")[1].Trim()
                $allfailedtests+=$obj
            }
            foreach($test in $allfailedtests){
                $test=$test.Trim()
                $FailedRecords = @()
                $dcdiagdata = @()
                $datalog = @()
                $warnings = @()
                $from = 0
                $to = 0
                $FromLine = ""
                $ToLine = ""
                $TestName1 = ""
                $FromLine = "Starting test: $Test"
                $ToLine = "failed test $Test"
                [int]$from = (($Dcdiag | Select-String -pattern $FromLine | Select-Object LineNumber).LineNumber)-1
                [int]$to = ($Dcdiag | Select-String -Pattern $ToLine | Select-Object LineNumber).LineNumber
                $dcdiagdata += $Dcdiag | Select-Object -Index ("$from".."$to")
                $numbers = (($dcdiagdata | Select-String -Pattern "A warning","EventID: 0x00002720","EventID: 0x000016AD","EventID: 0x0000165B","EventID: 0xC0000419","EventID: 0xC000051F","EventID: 0xC0000168E","EventID: 0xC0001B61", "EventID: 0xC0001B59","EventID: 0x0000900A","EventID: 0xC0000B50","EventID: 0xC0000B9E","EventID: 0x0000448",'EventID: 0xC00001B63',"EventID: 0x80000017","EventID: 0x0000168E","EventID: 0x80000013","EventID: 0xC0001B58","EventID: 0xC0001B58","EventID: 0x00009012","EventID: 0xC00009007","EventID: 0xC0001390","EventID: 0xC000138A" | Select-Object LineNumber).LineNumber)
                $numbers = (($dcdiagdata | Select-String -Pattern "A warning","EventID: 0x00002720","EventID: 0x000016AD","EventID: 0x0000165B","EventID: 0xC0000419","EventID: 0xC000051F","EventID: 0x0000168E","EventID: 0xC00001B61","EventID: 0xC0001B59","EventID: 0x0000900A","EventID: 0xC0000B50" | Select-Object LineNumber).LineNumber)

                $events = (($dcdiagdata | Select-String -Pattern "event occurred","failed test" | Select-Object LineNumber).LineNumber)
                foreach($number in $numbers){
                    if($events -contains $number){
                        [int]$num = ((events | Select-String -Pattern "^number$" | Select-Object LineNumber).LineNumber)
                        [int]$endnum = $events[$num]-2
                        [int]$startnum = $number-1
                    }
                }
                foreach($warning in $warnings){
                    $dcdiagdata = $dcdiagdata | ?($_ -ne $warning)
                }
                if($dcdiagdata -match "event occurred"){
                    $i++
                    foreach($item in $dcdiagdata){
                        $dcdiagdata += $item
                        $dcdiagdata += " "
                    }
                }
            }
            if($i -eq 0){
                $DCDIAGDATALOG += "All tests are passed"
            }
        }
        else{
            $DCDIAGDATALOG += "All tests are passed"
        }
    }
    $DCDIAGDATALOG += "DCDIAG Ends 'n"


    #########Running DNSDIAG##########
    DddiagDNS = @()
    $DNSDIAGDATALOG =@()
    $DNSDIAGDATALOG += "'nDNSDIAG Starts'n"
    $DCdiagDNS = (Dcdiag.exe /test:dns /v /s:$srtComputer)
    if(($dcdiagdns -eq $nul ) -or ($DCdiagDNS | Select-String -Pattern "LDap search capabality attribute search failed on server")){
        $DNSDIAGDATALOG+="could not run DNS diagnosis'n"
    }
    else{
        $TestLine = (($DCdiagDNS | Select-String -Pattern "summary of dns test results:" | Select-Object LineNumber).LineNumber) + 6
        $DcdiagDNSText = @($DcdiagDNS)
        $TestStatusLine =$($DcdiagDNSText[$TestLine])
        $Auth = ($TestStatusLine.-split()|where {$_})[1]
        $Basc = ($TestStatusLine.-split()|where {$_})[2]
        $Forw  = ($TestStatusLine.-split()|where {$_})[3]
        $Del = ($TestStatusLine.-split()|where {$_})[4]
        $Dyn = ($TestStatusLine.-split()|where {$_})[5]
        $RReg =  ($TestStatusLine.-split()|where {$_})[6]
        $Ext =  ($TestStatusLine.-split()|where {$_})[7]
        $FailedDCDNSTest = @()
        if($auth -eq "PASS" -or $Auth -eq "n/a"){}Else{$FailedDCDNSTest+= "Test: Authentication; Test:Basic; Summary of DNS tet results:"}
        if($Basc -eq "PASS" -or $Basc -eq "n/a"){}Else{$FailedDCDNSTest+= "Test: Basic; Test:Forwrders/Root hints; Summary of DNS test results:"}
        if($Forw -eq "PASS" -or $Forw -eq "n/a"){}Else{$FailedDCDNSTest+= "Test: Forwarders/Root hints; Test: Delegations; Summary of DNS Test Result:"}
        if($Del -eq "PASS" -or $Del -eq "n/a"){}Else{$FailedDCDNSTest+= "Test: Delgation; Test:Dynamic update; Summary of Dns Test Result"}
        if($Dyn -eq "PASS" -or $Dyn -eq "n/a"){}Else{$FailedDCDNSTest+= "Test: Dynamic update; Test Records registration; Summary of DNS test results:"}
        if($RReg -eq "PASS" -or $RReg -eq "n/a"){}Else{$FailedDCDNSTest+= "Test: Records, registration; Summary of test results; summary of DNS test results:"}
        #FailedDCNDNSTest

        $DcdiagDNSCount = 0
        $DcdiagDNSCount = $FailedDCDNSTest.count 
        if($DcdiagDNSCount -gt 0){
            foreach($lines in $Fail){
                $FailRows = @();
                $FromLine = ""
                $ToLine = ""
                $From =0
                $to = 0
                $FromLine = ($Lines.split(";")[0])
                $ToLine = ($Lines.split(";")[1])
                $ToLine1 = ($Lines.split(";")[2])
                [int]$from = ($DCdiagDNS | Select-String -Pattern $FromLine | Select-Object LineNumber).LineNumber
                [int]$to = ($DCdiagDNS | Select-String -Pattern $FromLine | Select-Object LineNumber).LineNumber
                if($to -le 0){
                    [int]$to = ($DCdiagDNS | Select-String -Pattern $FromLine | Select-Object LineNumber).LineNumber
                }
                if($from -ge '1'){$from =$from -1}
                if($to -ge '2'){}
                $DNSDIAGDATALOG+=$DCdiagDNS | Select-Object -Index("$from".."$to")
            }s
        }
        else{
            $DCDIAGDATALOG+= "All tests are passed"
        }
        $DNSDIAGDATALOG+="DNSDIAG Ends"


    }

}