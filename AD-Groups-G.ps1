#reset the info
$search = "" 

$search = Read-Host "Account Name"
echo ""

$users = Get-ADUser -Filter "SamAccountName -like '*$search*'" -SearchBase <# "OU=Local,OU=new,OU=users,OU=ou,DC=new,DC=dc" #> -Properties * | Select-Object -Property SamAccountName
$groupNew = Get-ADPrincipalGroupMembership $users.SamAccountName | select name

try{
    $memof = Get-ADUser -Filter "SamAccountName -like '*$search*'" -SearchBase <# "OU=Local,OU=old,OU=users,OU=ou,DC=old,DC=dc" #> -Properties * -Server <#old server#> 
}catch{
    Write-Host "User Does Not Exist Within Old Domain"
}
$OLDgroups = @("") * $memof.MemberOf.Count

for($i =0;$i -lt $OLDgroups.Count; $i++){
    $OLDgroups[$i] = $memof.MemberOf[$i].Split(",")[0].Split("=")[1]
}

$MLen = $groupM.Length
$ALen = $OLDgroups.Length

$mc = 0 
$ac = 0

$obj = @()

while($true){
    #both ok
    if(($mc -lt $MLen) -and ($ac -lt $ALen)){
        $obj += New-Object psobject -Property @{Old=$OLDgroups[$ac];New=$groupNew[$mc].name}
    }#ac ok
    elseif(($ac -lt $ALen) -and (-not($mc -lt $MLen))){
        $obj += New-Object psobject -Property @{Old=$OLDgroups[$ac];New=""}
    }#mc ok
    elseif(($mc -lt $MLen) -and (-not($ac -lt $ALen))){
        $obj += New-Object psobject -Property @{Old="";New=$groupNew[$mc].name}
    }#else
    else{
        break
    }
    $mc++
    $ac++
}

$ans = Read-Host "View users Old Groups Only (Y/N)?"

if($ans -like "Y"){
    $obj.Old
}else{
    $obj
}
