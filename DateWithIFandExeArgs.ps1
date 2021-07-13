$DayNbr = Get-Date -UFormat "%d"
Write-Output $DayNbr

$HrNbr = Get-Date -UFormat "%H"
Write-Output $HrNbr

if($DayNbr -eq "03") {
    Start-Process -FilePath "D:\SomePath\Automated.exe" -ArgumentList "0"
}
ElseIf ($DayNbr -eq "04" -And $HrNbr -eq "07" )  {
    Start-Process -FilePath "D:\SomePath\Automated.exe" -ArgumentList "1"
}  
ElseIf ($Data  -eq "04" -And $HrNbr -eq "13" )  {
    Start-Process -FilePath "D:\SomePath\Automated.exe" -ArgumentList "2"
}
