#
# CyberArk Replication Status reporter (public version)
# This quick and dirty script can be run on your CyberARK DR vault to check the logs for failures.
#

$RunTime = Get-Date
$PADRLogString = ""
$PADRLogEvents = Get-Content -Tail 25 -Path "E:\Program Files (x86)\PrivateArk\PADR\Logs\padr.log"
$EmailFromAddress = ""
$EmailToAddress = ""
$EmailCCAddress = ""
$EmailBCCAddress = ""
$SMTPServer = ""

#
# This for loop converts the log events in array format to a continuous string so that they can be added to the body of the notification emails...
#
foreach ($line in $PADRLogEvents) {
   $PADRLogString = $PADRLogString + "`n" + $line
}

foreach ($event in $PADRLogEvents) {
  if (($event.Contains("PADR0013E")) -Or (($event.Contains("PADR0022I")))){ 
    $ReplicationSuccessful = "FALSE"
    #echo "CyberArk Replication has failed`n`n====  Failure Event ====`n$event`n`nSee remediation procedure at: http://xyleminc.atlassian.com/wiki/spaces/MSO/pages/5507942273/CyberArk+Replication+Verification+Procedure"
    Send-MailMessage -From $EmailFromAddress -To $EmailToAddress -Cc $EmailCCAddress -Bcc $EmailBCCAddress -Subject "Cyber-Ark Replication Failed"  -Priority High -Body "CyberArk Replication has failed`n`n====  Failure Event ====`n$event`n`n==== Replication Log ====$PADRLogString" -SmtpServer $SMTPServer -Port 25
    break
  }
  #
  # Elseif required because supposedly you can't chain 'or' statements
  #
  elseif (($event.Contains("PADR0011E"))){ 
    $ReplicationSuccessful = "FALSE"
    #echo "CyberArk Replication has failed`n`n====  Failure Event ====`n$event`n`nSee remediation procedure at: http://xyleminc.atlassian.com/wiki/spaces/MSO/pages/5507942273/CyberArk+Replication+Verification+Procedure"
    Send-MailMessage -From $EmailFromAddress -To $EmailToAddress -Cc $EmailCCAddress -Bcc $EmailBCCAddress -Subject "SaaS Cyber-Ark Replication Failed"  -Priority High -Body "CyberArk Replication has failed`n`n====  Failure Event ====`n$event`n`n==== Replication Log ====$PADRLogString" -SmtpServer $SMTPServer -Port 25
    break
  }

  else
    { $ReplicationSuccessful = "TRUE" }
}

if ($ReplicationSuccessful -eq "TRUE") { 
  #echo "`nCyberArk Replication successful at last check, $RunTime " 
   Send-MailMessage -From $EmailFromAddress -To $EmailToAddress -Subject "Cyber-Ark Replication Status"  -Priority High -Body "CyberArk Replication successful at last check, $RunTime`n`n==== Replication Log ====$PADRLogString" -SmtpServer $SMTPServer -Port 25
}

