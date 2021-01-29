$file = '' #starting location
clear
cd $file

#to do home folder
$acl = Get-ACL $file
$NewAcl = Get-Acl $file
$b = $false #boolean check for admin, since must be run as admin
Write-Host "++++----++++----++++"
Write-Host $file
Foreach($r in $acl.Access){  
    $idr = $r.IdentityReference.ToString()
    #Write-Host "$fsr $idr"
    if($idr -notlike "*Admin*"){
        $fileSystemAccessRuleArgumentList = $idr, "ReadAndExecute", "Allow" 
    }else{
        $fileSystemAccessRuleArgumentList = $idr, "FullControl", "Allow" 
        $b = $true
    }
    Write-Host $fileSystemAccessRuleArgumentList
    $fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
    $NewAcl.SetAccessRule($fileSystemAccessRule)
    Set-Acl -Path $file -AclObject $NewAcl
}
if($b -eq $false){
    Write-Host "Adding Admin"
    $fileSystemAccessRuleArgumentList = "Domain\Administrators", "FullControl", "Allow" #make sure admins have access to the folder. fill with correct admin acct
    $fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
    $NewAcl.SetAccessRule($fileSystemAccessRule)
    Set-Acl -Path $file -AclObject $NewAcl
}

#do the children
$test = Get-ChildItem -Recurse
foreach($f in $test){
    $b = $false #boolean for admin    
    Write-Host "++++----++++----++++"
    Write-Host $f.PSPath 
    $acl = Get-ACL $f.FullName
    $NewAcl = Get-Acl $f.FullName
    Foreach($r in $acl.Access){
        $idr = $r.IdentityReference.ToString()
        #Write-Host "$fsr $idr"
        if($idr -notlike "*Admin*"){
            $fileSystemAccessRuleArgumentList = $idr, "ReadAndExecute", "Allow"
        }else{
            $fileSystemAccessRuleArgumentList = $idr, "FullControl", "Allow" 
            $b = $true
        }
        Write-Host $fileSystemAccessRuleArgumentList
        $fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
        $NewAcl.SetAccessRule($fileSystemAccessRule)
        Set-Acl -Path $f.FullName -AclObject $NewAcl
    }
    if($b -eq $false){
        Write-Host "Adding Admin"
        $fileSystemAccessRuleArgumentList = "Domain\Administrators", "FullControl", "Allow" #make sure admins have access to the folder. fill with correct admin acct
        $fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
        $NewAcl.SetAccessRule($fileSystemAccessRule)
        Set-Acl -Path $f.FullName -AclObject $NewAcl
    }
}
