clear
$pcs = @(Get-Content ./APC.txt)
$log = ".\log.txt"

#starts log
if($true){
    $date = Get-Date -Format "MM/dd_HH:mm" 
    $title = "---"
    $title += $date
    $title += "---"
    Write-Output $title  >> $log 
}

function createSchedule{
    try{
    Unregister-ScheduledTask -TaskName "Toast" -Confirm
    }
    catch{}
    $A = New-ScheduledTaskAction -Execute "C:\temp\Toast\batch.bat"
    $T = New-ScheduledTaskTrigger -At 9:00 -Weekly -WeeksInterval 2 -DaysOfWeek Wednesday,Thursday,Friday  #starting on run week
    $P = New-ScheduledTaskPrincipal  -GroupID "<users group SID>"
    $S = New-ScheduledTaskSettingsSet
    $D = New-ScheduledTask -Action $A -Settings $S -Description "Toast"  -Trigger $T -Principal $P
    Register-ScheduledTask -TaskName "Toast" -InputObject $D 

}

foreach($cn in $pcs){
    $i++
    $a = $i/$pcs.Count
    [int]$b = $a * 100
    $str = "$b%"
    Write-Host "--- $str ---"

    if(Test-Connection -ComputerName $cn -Quiet -Count 2){
        try{
        New-Item -Type Directory "\\$cn\C$\Temp\T"
        }catch{}
        if(Test-Path "\\$cn\C$\Temp\T"){
            robocopy '\\<local pc>\c$\Users\<username>\Documents\T' "\\$cn\C$\Temp\T" /V /TEE /R:0 /S
            if(Test-Path "\\$cn\C$\Temp\Toast\"){
                Invoke-command -computername "${cn}" -ScriptBlock ${Function:createSchedule} 
            }else{
                $s = "File: " 
                $s += $cn
                Write-Output $s >> $log
            }
        }
    }else{
        $s = "Ping: " 
        $s += $cn
        Write-Output $s >> $log
    }
}