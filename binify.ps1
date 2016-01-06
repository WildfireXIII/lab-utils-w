#*************************************************************
#  File: binify.ps1
#  Date created: 1/6/2016
#  Date edited: 1/6/2016
#  Author: Nathan Martindale
#  Copyright � 2016 Digital Warrior Labs
#  Description: Script that takes passed file and puts it into the temporary bin
#*************************************************************

param (
	[Parameter(Position=1)]
	[string]$fileToBin = "",
	
	[switch]$list = $false,
	[switch]$clear = $false
)

if ($fileToBin -ne "") { Copy-Item $fileToBin "/dwl/tmp/bin/" }
if ($list) { Get-ChildItem "/dwl/tmp/bin/" }
if ($clear) { Remove-Item "/dwl/tmp/bin/*" }

if ($fileToBin -eq "" -and !$list -and !$clear)
{
	echo "`nSends specified file to the temporary bin folder for quick testing/usage elsewhere, without having to go through the package system."
	echo "`n`nUsage: `n`tbinify [path/name of script/runnable]`n`tbinify -list `t= displays all current contents of temporary bin`n`tbinify -clear `t= deletes all contents of temporary bin`n"
}
