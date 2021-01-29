param(
    [string]$if = "", [string]$v = "", [int]$c = 0, [switch]$h
    )
#above incl the switches to input information easier into the script

<#

Created by CTR BRANDON SULLIVAN
Update v3

Does:
    o(3n) for verbose output 
Goal:
    redo verbose output
Want: 
    v3 -> optimize verbose output to still include order that pinged but in separate lists
       |->take list count offline vs online, then create 1 array of custom object @([str] true/fasls/line , [str] IP/hostname)
Bugs:

#>

if($h){
"
v2.7
Given a file input script will ping a list of devices and output a file that will contain the results. Can ping
host names, but if it doesnt reply, will consider it a `"word line`"

Switches:
-if <>     input file
-v <>      verbosity switch
-c <>      how many pings to attempt
-h         this help file

Verbosity options:
d          default output lists all IPs in order and says online or offline/error, can also use blank/ no flag
v          Verbose output lists all ips grouped by online vs offline/error vs `"lines`"
q          quiet output lists only ips that are offline/errors

script produced by CTR Brandon Sullivan
"
exit
}

$Array = New-Object System.Collections.ArrayList

function FillArray{
    #fills array with alive/dead/lines
    Write-Host "Checked:"
    ForEach($line in $arrS){
        $obj = [PSCustomObject]@{
            'Line'= $line
            'Result' = $false
        }
        echo $line
        if(!($line -eq "")){
            if($line -like "*.*.*.*"){
                if(Test-Connection -ComputerName $line -BufferSize 1 -Count $c -Quiet){
                    $obj.Result = $true
                }else{
                    $obj.Result = $false
                }
            }else{
                if(Test-Connection -ComputerName $line -BufferSize 1 -Count $c -Quiet){
                    $obj.Result = $true
                }else{
                    $obj.Result = 'Line'
                }
            }
        }else{
            $obj.Result = 'Line'
        }
        Write-Output "$obj" >> $tmpfile
        $Array.Add($obj)
    }
}

Function Defaultoutput{
    #Output each item in the order it came in
    "Default output " + $c + " Pings" >> $file
    foreach($line in $Array){
        $l = $line.Line
        $s = $line.Result
        if($s -like "Line"){$s = ""}
        Write-Output "$l`t$s" >> $file
    }
}

Function Voutput{
    #output each line in context of online/offline/lines
    if($v -eq 'V'){
        "Verbose output " + $c + " Pings" >> $file
        echo "Online:" >> $file
        foreach($line in $Array){
            $l = $line.Line
            $s = $line.Result
            if($s -eq $true){
                Write-Output "$l" >> $file
            }
        }
    }
    echo "`nOffline:" >> $file
    foreach($line in $Array){
        $l = $line.Line
        $s = $line.Result
        if($s -eq $false){
            Write-Output "$l" >> $file
        }
    }
    echo "`nLines:" >> $file
    foreach($line in $Array){
        $l = $line.Line
        $s = $line.Result
        if($s -like 'Line'){
            Write-Output "$l" >> $file
        }
    }
}

function Checkout{
    #what output to output
    $v.ToUpper()

    echo "Results for:" > $file
    Get-Date >> $file
    echo "File Created at $file"

    if (($v[0] -like "D") -or ($v[0] -like "")){
        Defaultoutput
    }elseif($v[0] -like "V"){
        Voutput
    }elseif($v[0] -like "Q"){
        "Quiet output " + $c + " Pings" >> $file
        Voutput
    }else{
        Throw "V requires a proper input"}
}

#######   Main Thread

$tmpfile = ".\ping"
$tmpfile += Get-Date -Format "MMdd_HHmm"
$tmpfile += "tmp.txt"

try{
    Test-Path -Path $if
    $of = $if
}catch{
    echo "Using Default File..."
    $of = ".\IP.txt"
    if(Test-Path -Path $of){}else{
        echo "Please fill the provided file then try again"
        echo "Please fill and try again" > IP.txt
        Notepad .\IP.txt
        break
    }
}

$arrS = @(Get-Content $of)        #Array of File

if($c -eq 0){  ##amount of default pings##
    $c = 4
}

FillArray      ##Actually does the pings

##creates a file to input all of the data
$file = ".\"
$file += Get-Date -Format "yyyyMMdd_HHmm"
$file += "Ping.txt"

Checkout ##fills file

Notepad.exe $file

rm $tmpfile