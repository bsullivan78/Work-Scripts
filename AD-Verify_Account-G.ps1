$search = "" 

$search = Read-Host "Account Name"
echo ""

#change the SearchBase Below to domain to properly search

$user = Get-ADUser -Filter "SamAccountName -like '*$search*'" -SearchBase <# "OU=Local,OU=new,OU=users,OU=ou,DC=new,DC=dc" #> -Properties * 

foreach($u in $user){
    if($u.DistinguishedName -like "*SyncAccounts*"){
    "    
    ******************
    Sync Account Issue
    ******************"
    }elseif(!($u.DistinguishedName -like "*Local*")){    #change "Local" to site location to properly search
    "    
    ******************
    Account not in Correct Location
    ******************"
    }
    #can add more checks here if required.
    #maybe add check for proper home directory

    $u | Select-Object -Property #wanted properties
}
