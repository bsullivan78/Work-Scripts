clear
$end = Get-Date -format "MM/dd/yyyy"
$end += " 00:00" #time here
while($true){
    clear
    $start = Get-Date
    $r = New-TimeSpan -Start $start -End $end | select TotalSeconds
    $s = $r.TotalSeconds
    $ss,$t = $s -split "\."
    echo "shutdown /r /f /t $ss"
    Set-Clipboard -Value "shutdown /r /f /t $ss"
}
