<#
Created by CTR BRANDON SULLIVAN
#>

cd '' <#File location needed to be cleaned#>            #set location
                                                        #set global variables
$tmp = 'C:\Temp' #change to where you want the log file to go
$trash = 'T:\Trash' #where to put any old files
if(!(Test-Path $tmp)){
    mkdir $tmp
}
if(!(Test-Path $trash)){
    mkdir $trash
}
$logfile = "$tmp\removed.log"
                                                        #move anything older than a month
$month = (Get-Date).AddMonths(-1)                       #get date a month ago
$files = Get-ChildItem                                  #get contents
"==============$month==mv=========" >> $logfile         #write date of things being moved
foreach($f in $files){
    if(!($f.LastWriteTime -lt $month)){
        $f.PSPath >> $logfile                           #if older than a month move to a temp trash folder and tell log what moved
        Move-Item -Path $f -Destination $trash
    }
}
                                                        #remove anything older than 2 months
$month = (Get-Date).AddMonths(-2)                       #get date 2 months ago
cd $trash                                               #move to trash folder
$files = Get-ChildItem                                  #get contents of trash folder 
"==============$month==rm========" >> $logfile          #log date of what is being removed
foreach($f in $files){
    if(!($f.LastWriteTime -lt $month)){
        $f.PSPath >> $logfile                           #log what was deleted
        rm $f
    }
}
