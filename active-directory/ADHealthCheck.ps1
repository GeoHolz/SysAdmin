<#PSScriptInfo

.VERSION 1.0

#>

<# 

.DESCRIPTION 
    AD Health Status


#> 
<#################################################################################################################################################################
																Variables
#################################################################################################################################################################>
$timeout = "60"
#Start-Transcript -OutputDirectory "D:\DSI\Script\"
$tmp_date=(Get-Date).ToString("dd-MM-yyyy")
$getForest = [system.directoryservices.activedirectory.Forest]::GetCurrentForest()
$DCServers = $getForest.domains | ForEach-Object {$_.DomainControllers} | ForEach-Object {$_.Name}

if((test-path $report) -like $false)
{
	new-item $report -type file
}

switch ($getForest)
{
    "LOCAL.DOMAIN.1" { $site="LD1" 
    $report = "D:\DSI\Script\$getForest-ADReport.htm" }
    "LOCAL.DOMAIN.2" { $site="LD2" 
    $report = "D:\DSI\Script\$getForest-ADReport.htm" }
}

<#################################################################################################################################################################
																HTML Report Content
#################################################################################################################################################################>
Clear-Content $report 
Add-Content $report "<html>" 
Add-Content $report "<head>" 
Add-Content $report "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>" 
Add-Content $report '<title>AD Status Report</title>' 
add-content $report '<style>
td 
{
	font-family: Tahoma;
	font-size: 11px;
	border-top: 1px solid #999999;
	border-right: 1px solid #999999;
	border-bottom: 1px solid #999999;
	border-left: 1px solid #999999;
	padding-top: 0px;
	padding-right: 0px;
	padding-bottom: 0px;
	padding-left: 0px;
}
body 
{
	margin-left: 5px;
	margin-top: 5px;
	margin-right: 0px;
	margin-bottom: 10px;
}
table 
{
	border: thin solid #000000;
}
.button 
{
		border: none;
		text-align: center;
		text-decortation: none;
		display: inline-block;
		font-size: 12px;
		margin: 4px 2px;
		cursor: pointer;
		background-color: #e7e7e7; 
		color: black;
}

.incorrect-date 
{
        color: red;
}
</style>'
Add-Content $report "</head>" 
Add-Content $report "<body>" 
<#################################################################################################################################################################
																HTML Report Menu
#################################################################################################################################################################>
add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='#A2D2DF'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='tahoma' color='#003399' size='5'><strong>Active Directory Report</strong></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 
add-content $report  "<table width='100%'>" 
add-content $report  "<tr>" 
Add-Content $report  "<tr bgcolor='#A2D2DF'>" 
Add-Content $report  "<td width='10%' align='center'><B><a href='http://X.X.X.X/ad-report/LD1-ADReport.htm'>Local Domain 1</a></B></td>" 
Add-Content $report  "<td width='10%' align='center'><B><a href='http://X.X.X.X/ad-report/LD2-ADReport.htm'>Local Domain 2</a></B></td>" 
Add-Content $report "</tr>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 

<#################################################################################################################################################################
																HTML Report Title
#################################################################################################################################################################>
add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='#A2D2DF'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='tahoma' color='#003399' size='4'><strong>&#128048 $getForest -  <span id='date'>$tmp_date</span> &#128048 </strong></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>"
add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='#DAEAF1'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='tahoma' color='#003399' size='4'><strong>Active Directory DCDiag</strong></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 
<#################################################################################################################################################################
																DC DIAG
#################################################################################################################################################################>
add-content $report  "<table width='100%'>" 
Add-Content $report  "<tr bgcolor='#DCD6F7'>" 
Add-Content $report  "<td width='5%' align='center'><B>Identity</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>PingStatus</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>NetlogonsTest</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>ReplicationTest</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>ServicesTest</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>AdvertisingTest</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>FSMOCheckTest</B></td>"
Add-Content $report "</tr>" 


foreach ($DC in $DCServers)
{	
	### Ping Test
	$Identity = $DC
	Add-Content $report "<tr>"
	if ( Test-Connection -ComputerName $DC -Count 1 -ErrorAction SilentlyContinue ) 
	{
		Write-Host $DC `t $DC `t Ping Success -ForegroundColor Green
		Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $Identity</B></td>" 
		Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B>PingsPassed</B></td>" 
	   ### ### Netlogons status
	   add-type -AssemblyName microsoft.visualbasic 
	   $cmp = "microsoft.visualbasic.strings" -as [type]
	   $sysvol = start-job -scriptblock {dcdiag /test:netlogons /s:$($args[0])} -ArgumentList $DC
	   wait-job $sysvol -timeout $timeout
	   if($sysvol.state -like "Running")
	   {
	   Write-Host $DC `t Netlogons Test TimeOut -ForegroundColor Yellow
	   Add-Content $report "<td bgcolor= '#F6FDC3' align=center><B>NetlogonsTimeout</B></td>"
	   stop-job $sysvol
	   }
	   else
	   {
	   $sysvol1 = Receive-job $sysvol
	   if($cmp::instr($sysvol1, "réussi"))
		  {
		  Write-Host $DC `t Netlogons Test passed -ForegroundColor Green
		  Add-Content $report "<td bgcolor= '#F5F5F5' align=center><B>NetlogonsPassed</B></td>"
		  }
	   else
		  {
		  Write-Host $DC `t Netlogons Test Failed -ForegroundColor Red
		  Add-Content $report "<td bgcolor= '#FF8080' align=center><B>NetlogonsFail</B></td>"
		  }
		}

	   ### ### Replications status
	   add-type -AssemblyName microsoft.visualbasic 
	   $cmp = "microsoft.visualbasic.strings" -as [type]
	   $sysvol = start-job -scriptblock {dcdiag /test:Replications /s:$($args[0])} -ArgumentList $DC
	   wait-job $sysvol -timeout $timeout
	   if($sysvol.state -like "Running")
	   {
	   Write-Host $DC `t Replications Test TimeOut -ForegroundColor Yellow
	   Add-Content $report "<td bgcolor= '#F6FDC3' align=center><B>ReplicationsTimeout</B></td>"
	   stop-job $sysvol
	   }
	   else
	   {
	   $sysvol1 = Receive-job $sysvol
	   if($cmp::instr($sysvol1, "réussi"))
		  {
		  Write-Host $DC `t Replications Test passed -ForegroundColor Green
		  Add-Content $report "<td bgcolor= '#F5F5F5' align=center><B>ReplicationsPassed</B></td>"
		  }
	   else
		  {
		  Write-Host $DC `t Replications Test Failed -ForegroundColor Red
		  Add-Content $report "<td bgcolor= '#FF8080' align=center><B>ReplicationsFail</B></td>"
		  }
		}
	   ########################################################
		 ####################Services status##################
	   add-type -AssemblyName microsoft.visualbasic 
	   $cmp = "microsoft.visualbasic.strings" -as [type]
	   $sysvol = start-job -scriptblock {dcdiag /test:Services /s:$($args[0])} -ArgumentList $DC
	   wait-job $sysvol -timeout $timeout
	   if($sysvol.state -like "Running")
	   {
	   Write-Host $DC `t Services Test TimeOut -ForegroundColor Yellow
	   Add-Content $report "<td bgcolor= '#F6FDC3' align=center><B>ServicesTimeout</B></td>"
	   stop-job $sysvol
	   }
	   else
	   {
	   $sysvol1 = Receive-job $sysvol
	   if($cmp::instr($sysvol1, "réussi"))
		  {
		  Write-Host $DC `t Services Test passed -ForegroundColor Green
		  Add-Content $report "<td bgcolor= '#F5F5F5' align=center><B>ServicesPassed</B></td>"
		  }
	   else
		  {
		  Write-Host $DC `t Services Test Failed -ForegroundColor Red
		  Add-Content $report "<td bgcolor= '#FF8080' align=center><B>ServicesFail</B></td>"
		  }
		}
	   ########################################################
		 ####################Advertising status##################
	   add-type -AssemblyName microsoft.visualbasic 
	   $cmp = "microsoft.visualbasic.strings" -as [type]
	   $sysvol = start-job -scriptblock {dcdiag /test:Advertising /s:$($args[0])} -ArgumentList $DC
	   wait-job $sysvol -timeout $timeout
	   if($sysvol.state -like "Running")
	   {
	   Write-Host $DC `t Advertising Test TimeOut -ForegroundColor Yellow
	   Add-Content $report "<td bgcolor= '#F6FDC3' align=center><B>AdvertisingTimeout</B></td>"
	   stop-job $sysvol
	   }
	   else
	   {
	   $sysvol1 = Receive-job $sysvol
	   if($cmp::instr($sysvol1, "réussi"))
		  {
		  Write-Host $DC `t Advertising Test passed -ForegroundColor Green
		  Add-Content $report "<td bgcolor= '#F5F5F5' align=center><B>AdvertisingPassed</B></td>"
		  }
	   else
		  {
		  Write-Host $DC `t Advertising Test Failed -ForegroundColor Red
		  Add-Content $report "<td bgcolor= '#FF8080' align=center><B>AdvertisingFail</B></td>"
		  }
		}
	   ########################################################
		 ####################FSMOCheck status##################
	   add-type -AssemblyName microsoft.visualbasic 
	   $cmp = "microsoft.visualbasic.strings" -as [type]
	   $sysvol = start-job -scriptblock {dcdiag /test:FSMOCheck /s:$($args[0])} -ArgumentList $DC
	   wait-job $sysvol -timeout $timeout
	   if($sysvol.state -like "Running")
	   {
	   Write-Host $DC `t FSMOCheck Test TimeOut -ForegroundColor Yellow
	   Add-Content $report "<td bgcolor= '#F6FDC3' align=center><B>FSMOCheckTimeout</B></td>"
	   stop-job $sysvol
	   }
	   else
	   {
	   $sysvol1 = Receive-job $sysvol
	   if($cmp::instr($sysvol1, "réussi"))
		  {
		  Write-Host $DC `t FSMOCheck Test passed -ForegroundColor Green
		  Add-Content $report "<td bgcolor= '#F5F5F5' align=center><B>FSMOCheckPassed</B></td>"
		  }
	   else
		  {
		  Write-Host $DC `t FSMOCheck Test Failed -ForegroundColor Red
		  Add-Content $report "<td bgcolor= '#FF8080' align=center><B>FSMOCheckFail</B></td>"
		  }
		}				
	} 
	else
	{
		Write-Host $DC `t $DC `t Ping Fail -ForegroundColor Red
		Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $Identity</B></td>" 
		Add-Content $report "<td bgcolor= '#FF8080' align=center>  <B>Ping Fail</B></td>" 
		Add-Content $report "<td bgcolor= '#FF8080' align=center>  <B>Ping Fail</B></td>" 
		Add-Content $report "<td bgcolor= '#FF8080' align=center>  <B>Ping Fail</B></td>" 
		Add-Content $report "<td bgcolor= '#FF8080' align=center>  <B>Ping Fail</B></td>" 
		Add-Content $report "<td bgcolor= '#FF8080' align=center>  <B>Ping Fail</B></td>"
		Add-Content $report "<td bgcolor= '#FF8080' align=center>  <B>Ping Fail</B></td>"
		Add-Content $report "<td bgcolor= '#FF8080' align=center>  <B>Ping Fail</B></td>"
		Add-Content $report "<td bgcolor= '#FF8080' align=center>  <B>Ping Fail</B></td>"
		Add-Content $report "<td bgcolor= '#FF8080' align=center>  <B>Ping Fail</B></td>"
	}         
		   
} 

Add-Content $report "</tr>"
Add-content $report  "</table>" 

<#################################################################################################################################################################
																Active Directory Users
#################################################################################################################################################################>
add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='#DAEAF1'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='tahoma' color='#003399' size='4'><strong>Active Directory Users</strong><button class='button' onclick=`"toggleTable('table1')`">Afficher/Masquer</button></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 
add-content $report  "<table id='table1'width='100%'>" 
Add-Content $report  "<tr bgcolor='#DCD6F7'>" 
Add-Content $report  "<td width='5%' align='center'><B>samaccountname</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>PasswordLastSet</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>DaysUntilExpired</B></td>" 
Add-Content $report "</tr>" 


$MaxPwdAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge.Days
$expiredDate = (Get-Date).addDays(-$MaxPwdAge)
#Set the number of days until you would like to begin notifing the users. -- Do Not Modify --
#Filters for all users who's password is within $date of expiration.
$ExpiredUsers = Get-ADUser -Filter {(PasswordLastSet -gt $expiredDate) -and (PasswordNeverExpires -eq $false) -and (Enabled -eq $true)} -Properties PasswordNeverExpires, PasswordLastSet, Mail | select samaccountname, PasswordLastSet, @{name = "DaysUntilExpired"; Expression = {$_.PasswordLastSet - $ExpiredDate | select -ExpandProperty Days}} | Sort-Object PasswordLastSet

foreach ($ExpiredUser in $ExpiredUsers)
{ 
	$tmp_samaccountname=$ExpiredUser.samaccountname
	$tmp_PasswordLastSet=$ExpiredUser.PasswordLastSet
	$tmp_DaysUntilExpired=$ExpiredUser.DaysUntilExpired
	Add-Content $report "<tr>"
	Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $tmp_samaccountname</B></td>" 
	Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $tmp_PasswordLastSet</B></td>" 
	if($tmp_DaysUntilExpired -ge 31)
	{
		Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $tmp_DaysUntilExpired</B></td>" 
	}
	if($tmp_DaysUntilExpired -gt 7 -and $tmp_DaysUntilExpired -lt 31)
	{
		Add-Content $report "<td bgcolor= '#F6FDC3' align=center>  <B> $tmp_DaysUntilExpired</B></td>" 
	}
	if($tmp_DaysUntilExpired -le 7)
	{
		Add-Content $report "<td bgcolor= '#FF8080' align=center>  <B> $tmp_DaysUntilExpired</B></td>" 
	}

	Add-Content $report "</tr>"
}

$ExpiredUsers = Get-ADUser -filter * -properties * | Where-Object {$_.Enabled -eq $true} | where-object {$_.PasswordExpired -eq $true} | select samaccountname,passwordexpired,passwordlastset
foreach ($ExpiredUser in $ExpiredUsers)
{ 
	$tmp_samaccountname=$ExpiredUser.samaccountname
	$tmp_PasswordLastSet=$ExpiredUser.PasswordLastSet

	Add-Content $report "<tr>"
	Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $tmp_samaccountname</B></td>" 
	Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $tmp_PasswordLastSet</B></td>" 
	Add-Content $report "<td bgcolor= '#FF8080' align=center>  <B> 0</B></td>" 


	Add-Content $report "</tr>"
}
Add-content $report  "</table>" 
<#################################################################################################################################################################
																Active Directory Service Account Managed
#################################################################################################################################################################>
add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='#DAEAF1'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='tahoma' color='#003399' size='4'><strong>Active Directory Managed Service Account and other</strong><button class='button' onclick=`"toggleTable('table2')`">Afficher/Masquer</button></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 
add-content $report  "<table id='table2' width='100%'>" 
Add-Content $report  "<tr bgcolor='#DCD6F7'>" 
Add-Content $report  "<td width='5%' align='center'><B>samaccountname</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>PasswordLastSet</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>DaysUntilExpired</B></td>" 
Add-Content $report "</tr>" 
$MaxPwdAge = 31
$expiredDate = (Get-Date).addDays(-$MaxPwdAge)
$ExpiredUsers=Get-ADServiceAccount -Filter {(Enabled -eq $true)} -Properties PasswordLastSet,SamAccountName | select samaccountname, PasswordLastSet, @{name = "DaysUntilExpired"; Expression = {$_.PasswordLastSet - $ExpiredDate | select -ExpandProperty Days}} | Sort-Object PasswordLastSet
foreach ($ExpiredUser in $ExpiredUsers)
{ 
	$tmp_samaccountname=$ExpiredUser.samaccountname
	$tmp_PasswordLastSet=$ExpiredUser.PasswordLastSet
	$tmp_DaysUntilExpired=$ExpiredUser.DaysUntilExpired
	Add-Content $report "<tr>"
	Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $tmp_samaccountname</B></td>" 
	Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $tmp_PasswordLastSet</B></td>" 
	if($tmp_DaysUntilExpired -ge 31)
	{
		Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $tmp_DaysUntilExpired</B></td>" 
	}
	if($tmp_DaysUntilExpired -gt 7 -and $tmp_DaysUntilExpired -lt 31)
	{
		Add-Content $report "<td bgcolor= '#F6FDC3' align=center>  <B> $tmp_DaysUntilExpired</B></td>" 
	}
	if($tmp_DaysUntilExpired -le 7)
	{
		Add-Content $report "<td bgcolor= '#FF8080' align=center>  <B> $tmp_DaysUntilExpired</B></td>" 
	}

	Add-Content $report "</tr>"
}
## krgbt
$MaxPwdAge = 360
$expiredDate = (Get-Date).addDays(-$MaxPwdAge)
$ExpiredUsers=Get-ADUser -Identity krbtgt  -Properties PasswordNeverExpires, PasswordLastSet, Mail | select samaccountname, PasswordLastSet, @{name = "DaysUntilExpired"; Expression = {$_.PasswordLastSet - $ExpiredDate | select -ExpandProperty Days}} | Sort-Object PasswordLastSet
foreach ($ExpiredUser in $ExpiredUsers)
{ 
	$tmp_samaccountname=$ExpiredUser.samaccountname
	$tmp_PasswordLastSet=$ExpiredUser.PasswordLastSet
	$tmp_DaysUntilExpired=$ExpiredUser.DaysUntilExpired
	Add-Content $report "<tr>"
	Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $tmp_samaccountname</B></td>" 
	Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $tmp_PasswordLastSet</B></td>" 
	if($tmp_DaysUntilExpired -ge 31)
	{
		Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $tmp_DaysUntilExpired</B></td>" 
	}
	if($tmp_DaysUntilExpired -gt 7 -and $tmp_DaysUntilExpired -lt 31)
	{
		Add-Content $report "<td bgcolor= '#F6FDC3' align=center>  <B> $tmp_DaysUntilExpired</B></td>" 
	}
	if($tmp_DaysUntilExpired -le 7)
	{
		Add-Content $report "<td bgcolor= '#FF8080' align=center>  <B> $tmp_DaysUntilExpired</B></td>" 
	}

	Add-Content $report "</tr>"
}

Add-content $report  "</table>" 




<#################################################################################################################################################################
																Account Never Expire
#################################################################################################################################################################>
Add-content $report  "</table>" 

add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='#DAEAF1'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='tahoma' color='#003399' size='4'><strong>Active Directory Password Never Expires</strong><button class='button' onclick=`"toggleTable('table3')`">Afficher/Masquer</button></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 
add-content $report  "<table id='table3' width='100%'>" 
Add-Content $report  "<tr bgcolor='#DCD6F7'>" 
Add-Content $report  "<td width='5%' align='center'><B>samaccountname</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>DistinguisedName</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>Enabled</B></td>" 
Add-Content $report "</tr>" 


$tmp_userneverexpire=get-aduser -filter * -properties Name,PasswordNeverExpires |  where {($_.passwordneverexpires -eq "true") -and ($_.enabled -eq "true")  } | select samaccountname,distinguishedname,enabled
foreach ($tmp_user in $tmp_userneverexpire)
{ 
	$tmp_samaccountname=$tmp_user.samaccountname
	$tmp_distinguishedname=$tmp_user.distinguishedname
	$tmp_enabled=$tmp_user.enabled
	Add-Content $report "<tr>"
	Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $tmp_samaccountname</B></td>" 
	Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $tmp_distinguishedname</B></td>" 
	Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $tmp_enabled</B></td>" 
	Add-Content $report "</tr>"
}
<#################################################################################################################################################################
																Protected Users
#################################################################################################################################################################>
Add-content $report  "</table>" 
add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='#DAEAF1'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='tahoma' color='#003399' size='4'><strong>Compte avec privileges non membre du groupe Protected User</strong><button class='button' onclick=`"toggleTable('table4')`">Afficher/Masquer</button></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 
add-content $report  "<table id='table4' width='100%'>" 
Add-Content $report  "<tr bgcolor='#DCD6F7'>" 
Add-Content $report  "<td width='5%' align='center'><B>samaccountname</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>Groupe</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>CN</B></td>" 
Add-Content $report "</tr>" 


# Get the 'Protected Users' group
$protectedUsersGroup = Get-ADGroup -Filter { Name -eq 'Protected Users' }

# Get privileged group names
$privilegedGroupNames = @(
    'Admins du domaine',
    'Administrateurs du schema',
    "Administrateurs de l’entreprise",
    "Administrateurs clés Enterprise",
    "Opérateurs de compte",
    "Opérateurs de serveur",
    "Opérateurs de sauvegarde",
    "Opérateurs d’impression",
    'Administrateurs'
)

# Initialize array for accounts not in 'Protected Users'
$accountsNotProtected = @()

# Get admin/privileged accounts and check if they are members of 'Protected Users'
foreach ($privilegedGroupName in $privilegedGroupNames) 
{
    $groupMembers = Get-ADGroupMember -Identity $privilegedGroupName -Recursive | Get-ADUser -Properties MemberOf | Select-Object -Unique

    foreach ($account in $groupMembers) 
    {
        if ($account.MemberOf -notcontains $protectedUsersGroup.DistinguishedName) 
        {
            if ($accountsnotprotected -ne $null)
            {
            $index_of_array = [array]::indexof($accountsnotprotected.username,$account.Name)
			}

            if($index_of_array -ge 0)
			{
				$accountsNotProtected[$index_of_array].GroupName += '<br/>'
				$accountsNotProtected[$index_of_array].GroupName += $privilegedGroupName
				
			}
			else
			{	
                $accountsNotProtected += [pscustomobject]@{
                    UserName = $account.Name
                    GroupName = $privilegedGroupName
                    DistinguishedName = $account.DistinguishedName				
				}
            }
			
		}
	}
}
foreach ($tmp_user in $accountsNotProtected)
{ 
	$tmp_samaccountname=$tmp_user.username
	$tmp_distinguishedname=$tmp_user.groupname
	$tmp_cn=$tmp_user.distinguishedname
	Add-Content $report "<tr>"
	Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $tmp_samaccountname</B></td>" 
	Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $tmp_distinguishedname</B></td>" 
	Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $tmp_cn</B></td>" 
	Add-Content $report "</tr>"
}
# Output the result
if ($accountsNotProtected.Count -eq 0) {
    Write-Output "All privileged accounts are members of the 'Protected Users' group."
} else {
    Write-Warning "The following privileged accounts are NOT members of the 'Protected Users' group:"
    $accountsNotProtected | Format-Table UserName, GroupName, DistinguishedName
}

<#################################################################################################################################################################
																AD Broken Owner
#################################################################################################################################################################>
Add-content $report  "</table>" 
add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='#DAEAF1'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='tahoma' color='#003399' size='4'><strong>Active Directory Broken Owner</strong><button class='button' onclick=`"toggleTable('table5')`">Afficher/Masquer</button></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 
add-content $report  "<table id='table5' width='100%'>" 
Add-Content $report  "<tr bgcolor='#DCD6F7'>" 
Add-Content $report  "<td width='5%' align='center'><B>Type</B></td>" 
Add-Content $report  "<td width='5%' align='center'><B>Name</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>DistinguisedName</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>operatingsystem</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>Owner</B></td>" 
Add-Content $report "</tr>" 

$skipdefaultgroups = $null
$skipdefaultgroups = @()	
$skipdefaultgroups += ([adsisearcher]"(&(groupType:1.2.840.113556.1.4.803:=1)(!(objectSID=S-1-5-32-546))(!(objectSID=S-1-5-32-545)))").findall().Properties.name
$skipdefaultgroups += ([adsisearcher] "(&(objectCategory=group)(admincount=1)(iscriticalsystemobject=*))").FindAll().Properties.name
$varoptionalgroup = [ADSI]("LDAP://" + (([ADSI]"LDAP://RootDSE").schemaNamingContext))
$varoptionalgroup.PsBase.ObjectSecurity.Access.identityreference.value | select -Unique | ForEach-Object {

$skipdefaultgroups += $_.Split("\")[1]
}

$conditions = ([adsisearcher]"(|(&(objectCategory=computer)(!(userAccountControl:1.2.840.113556.1.4.803:=8192)))(objectCategory=User)(groupType:1.2.840.113556.1.4.803:=2)(objectCategory=organizationalUnit))").findall().properties
$conditions | ForEach-Object {
    

    $name = $_.samaccountname

    if (!$name) { $name = $_.name }

    #Write-Host "We scanne $name" -ForegroundColor Yellow 

    $getowner = [ADSI]("LDAP://" + $_.distinguishedname)

    #check if owner is different from the array
    if ($skipdefaultgroups -notcontains $getowner.PsBase.ObjectSecurity.Owner.Split("\")[1]) { 
            Add-Content $report "<tr>"
        
          #Convert Binary SID     
          $sid = $_["objectsid"][0] 
          if ($sid) { $sidstring = (New-Object System.Security.Principal.SecurityIdentifier($sid, 0)).Value }
          $adbrokenowner_name=$_["name"][0]
          $adbrokenowner_dsn=$_["distinguishedname"][0]
          $adbrokenowner_os=$_["operatingsystem"][0]
          $adbrokenowner_owner=$getowner.PsBase.ObjectSecurity.Owner.Split("\")[1]
                   
           if ($_["objectcategory"][0] -match "Computer") { 
           Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> Computer</B></td>" 
           Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $adbrokenowner_name</B></td>" 
           Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $adbrokenowner_dsn</B></td>" 
           Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B>  $adbrokenowner_os</B></td>" 
           Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $adbrokenowner_owner</B></td>"                                                                         
       
           } elseif ($_["objectcategory"][0] -match "Person") {
           Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> Computer</B></td>" 
           Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $adbrokenowner_name</B></td>" 
           Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $adbrokenowner_dsn</B></td>" 
           Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B>  $adbrokenowner_os</B></td>" 
           Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $adbrokenowner_owner</B></td>"  
           } elseif ($_["objectcategory"][0] -match "group") {
           Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> Computer</B></td>" 
           Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $adbrokenowner_name</B></td>" 
           Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $adbrokenowner_dsn</B></td>" 
           Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B>  $adbrokenowner_os</B></td>" 
           Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $adbrokenowner_owner</B></td>"  
           } else {

           Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> Object</B></td>" 
           Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $adbrokenowner_name</B></td>" 
           Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $adbrokenowner_dsn</B></td>" 
           Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B>  $adbrokenowner_os</B></td>" 
           Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $adbrokenowner_owner</B></td>"  }
   
        $name = $getowner = $null 
            Add-Content $report "</tr>"
    }
  


}


<#################################################################################################################################################################
																AD OLD COMPUTER
#################################################################################################################################################################>
Add-content $report  "</table>" 
$dayss=45
$today=Get-Date
$timecomputer=(Get-Date).Adddays(-($dayss))
$oldcomputers=Get-ADComputer -Filter {LastLogontimestamp -lt $timecomputer} -Properties Name,distinguishedname,lastlogontimestamp | select Name,distinguishedname,lastlogontimestamp | sort lastlogontimestamp
$tmpoldcomputerstotal= $oldcomputers | measure
$oldcomputerstotal=$tmpoldcomputerstotal.count
add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='#DAEAF1'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='tahoma' color='#003399' size='4'><strong>Ordinateur non vue dans le domaine depuis 45 jours. Total : $oldcomputerstotal</strong><button class='button' onclick=`"toggleTable('table6')`">Afficher/Masquer</button></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 
add-content $report  "<table id='table6' width='100%'>" 
Add-Content $report  "<tr bgcolor='#DCD6F7'>" 
Add-Content $report  "<td width='5%' align='center'><B>Computer</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>DistinguisedName</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>NbJours</B></td>" 
Add-Content $report "</tr>" 

foreach ($oldcomputer in $oldcomputers) {
    $oldcomputername=$oldcomputer.name
    $oldcomputercn=$oldcomputer.distinguishedname
    $oldcomputertimestamp=[datetime]::FromFileTime($oldcomputer.lastlogontimestamp)
    $daysDiff = ($today - $oldcomputertimestamp).Days
    Add-Content $report "<tr>"
    Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $oldcomputername</B></td>" 
    Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $oldcomputercn</B></td>" 
    Add-Content $report "<td bgcolor= '#F5F5F5' align=center>  <B> $daysDiff</B></td>"
    Add-Content $report "</tr>"
}




Add-content $report  "</table>" 
Add-content $report  "    <script>
        // Récupérer la date affichée dans le tableau
        const dateElement = document.getElementById('date');
        const pageDate = dateElement.textContent.trim();

        // Obtenir la date d'aujourd'hui au format DD-MM-YYYY
        const today = new Date();
        const day = String(today.getDate()).padStart(2, '0');
        const month = String(today.getMonth() + 1).padStart(2, '0'); // Les mois commencent à 0
        const year = today.getFullYear();
        const todayDate = day+'-'+month+'-'+year;

        // Comparer les dates et changer la couleur si elles ne correspondent pas
        if (pageDate !== todayDate) {
            dateElement.classList.add('incorrect-date');
        }
    </script>"
Add-content $report  "    	<script>
	function toggleTable(tableId)
	{
		var table = document.getElementById(tableId);
		if (table.style.display == 'none')
		{
			table.style.display = 'table';
		}
		else
		{
			table.style.display ='none';
		}
	}
	</script>"
Add-Content $report "</body>" 
Add-Content $report "</html>" 
<#################################################################################################################################################################
																SEND REPORT
#################################################################################################################################################################>
#Stop-Transcript
$tmp_filename="$getForest-ADReport.htm"	
$client = New-Object System.Net.WebClient
$client.Credentials = New-Object System.Net.NetworkCredential("adreport","pass")
$client.UploadFile("ftp://X.X.X.X/adreport/"+$tmp_filename,$report)	