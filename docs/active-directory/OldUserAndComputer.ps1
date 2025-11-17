<# 
.Synopsis 
   This script allows you to have the list of users with their expired passwords and computers that have not contacted the domain for X days
.CREDITS  
   Geo Holz https://blog.jolos.fr
.EXAMPLE 
  PasswordChangeNotification.ps1 -smtpServer mail.domain.com -expireInDays 21 -from "IT Support <support@domain.com>" -Logging -LogPath "c:\logFiles" -testing -testRecipient support@domain.com 
.EXAMPLE 
  PasswordChangeNotification.ps1 -smtpServer mail.domain.com -expireInDays 21 -from "IT Support <support@domain.com>"  
#> 
param( 
    # $smtpServer Enter Your SMTP Server Hostname or IP Address 
    [Parameter(Mandatory=$True,Position=0)] 
    [ValidateNotNull()] 
    [string]$smtpServer, 
    # Notify Computer if Expiry Less than X Days 
    [Parameter(Mandatory=$True,Position=1)] 
    [ValidateNotNull()] 
    [int]$Days, 
    # From Address, eg "IT Support <support@domain.com>" 
    [Parameter(Mandatory=$True,Position=2)] 
    [ValidateNotNull()] 
    [string]$smtpfrom, 
    # To Address, eg "IT Support <support@domain.com>" 
    [Parameter(Mandatory=$True,Position=2)] 
    [ValidateNotNull()] 
    [string]$smtpto, 
    [switch]$Console, 
    # Testing Enabled 
    [switch]$Email
) 
$time = (Get-Date).Adddays(-($Days)) 
$messageSubjectSysadmin = "AD Health : Old Computer and Account expired"



if($Console)
{
Write-Host "Users whose password has expired :"
get-aduser -filter {(Enabled -eq $true) -and (PasswordNeverExpires -eq $false)} -properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress | where { $_.passwordexpired -eq $true } | FT Name,DistinguishedName
Write-Host "Computer that has not logged on to the domain for $Days days :"
Get-ADComputer -Property Name,LastLogonTimeStamp,DistinguishedName,lastLogonDate -Filter {LastLogonTimeStamp -lt $time} | sort LastLogonTimeStamp | FT Name,lastLogonDate,DistinguishedName
}


if($Email){
$messageSysAdmin = New-Object System.Net.Mail.MailMessage $smtpfrom, $smtpto
$messageSysAdmin.Subject = $messageSubjectSysadmin
$messageSysAdmin.IsBodyHTML = $true


$style = "<style>BODY{font-family: Arial; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>" 

$tmpComputer=Get-ADComputer -Property Name,LastLogonTimeStamp,DistinguishedName,lastLogonDate -Filter {LastLogonTimeStamp -lt $time} | sort LastLogonTimeStamp | ConvertTo-Html -Head $style -Property Name,DistinguishedName,lastLogonDate
$tmpUser=get-aduser -filter {(Enabled -eq $true) -and (PasswordNeverExpires -eq $false)} -properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress | where { $_.passwordexpired -eq $true } | sort LastLogonTimeStamp | ConvertTo-Html -Head $style -Property Name,DistinguishedName
$messageSysAdmin.Body ="Users whose password has expired :<br/>"+$tmpUser+"Computer that has not logged on to the domain for "+$Days+" days :<br/>"+$tmpComputer
$mailSysadmin = New-Object Net.Mail.SmtpClient($smtpServer)
$mailSysadmin.Send($messageSysAdmin)}
