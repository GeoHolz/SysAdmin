$From = "XXX@XXX.com"
$To = "XXX@XXX.fr"




$aPrinterList = @()
$dateActuel= Get-Date -Format "dd/MM/yyyy"
$Subject = $dateActuel+ " : Impression sur SRVFLIP4"
$StartTime = $dateActuel+" 03:00:00"
$EndTime = $dateActuel+" 23:00:00"
$Results = Get-WinEvent -FilterHashTable @{LogName="Microsoft-Windows-PrintService/Operational"; ID=307; StartTime=$StartTime; EndTime=$EndTime;} -ComputerName XXX


ForEach($Result in $Results){
  $ProperyData = [xml]$Result.ToXml()
  $PrinterName = $ProperyData.Event.UserData.DocumentPrinted.Param5
    

    $hItemDetails = New-Object -TypeName psobject -Property @{
      DocName = $ProperyData.Event.UserData.DocumentPrinted.Param2
      UserName = $ProperyData.Event.UserData.DocumentPrinted.Param3
      MachineName = $ProperyData.Event.UserData.DocumentPrinted.Param4
      PrinterName = $PrinterName
      PageCount = $ProperyData.Event.UserData.DocumentPrinted.Param8
      TimeCreated = $Result.TimeCreated
    }

    $aPrinterList += $hItemDetails
  
}

$DataTable = New-Object System.Data.DataTable "DataTable"
$col1 = New-Object system.Data.DataColumn PageCount,([string])
$col2 = New-Object system.Data.DataColumn MachineName,([string])
$col3 = New-Object system.Data.DataColumn DocName,([string])
$col4 = New-Object system.Data.DataColumn TimeCreated,([string])
$col5 = New-Object system.Data.DataColumn UserName,([string])
$col6 = New-Object system.Data.DataColumn PrinterName,([string])
$DataTable.Columns.Add($col1)
$DataTable.Columns.Add($col2)
$DataTable.Columns.Add($col3)
$DataTable.Columns.Add($col4)
$DataTable.Columns.Add($col5)
$DataTable.Columns.Add($col6)

foreach ($entry in $aPrinterList){
    $row = $DataTable.NewRow()
    $row.PageCount = $entry.PageCount
    $row.MachineName = $entry.MachineName
    $row.DocName = $entry.DocName
    $row.TimeCreated = $entry.TimeCreated
    $row.UserName = $entry.UserName
    $row.PrinterName = $entry.PrinterName
    $DataTable.Rows.Add($row)
}

$HtmlTable = "<table border='1' align='Left' cellpadding='2' cellspacing='0' style='color:black;font-family:arial,helvetica,sans-serif;text-align:left;'>
<tr style ='font-size:12px;font-weight: normal;background: #FFFFFF'>
<th align=left><b>PageCount</b></th>
<th align=left><b>MachineName</b></th>
<th align=left><b>DocName</b></th>
<th align=left><b>TimeCreated</b></th>
<th align=left><b>UserName</b></th>
<th align=left><b>PrinterName</b></th>
</tr>"

foreach ($row in $DataTable)
{
    $HtmlTable += "<tr style='font-size:12px;background-color:#FFFFFF'>
    <td>" + $row.PageCount + "</td>
    <td>" + $row.MachineName + "</td>
    <td>" + $row.DocName + "</td>
    <td>" + $row.TimeCreated + "</td>
    <td>" + $row.UserName + "</td>
    <td>" + $row.PrinterName + "</td>
    </tr>"

}

$HtmlTable += "</table>"

# The password is an app-specific password if you have 2-factor-auth enabled
$Password = "XXXX" | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $From, $Password
Send-MailMessage -From $From -To $To -Subject $Subject -Body $HtmlTable -BodyAsHtml -SmtpServer "smtp.gmail.com" -port 587 -UseSsl -Credential $Credential
