#*************************************************************
#  File: bak.ps1
#  Date created: 1/10/2016
#  Date edited: 1/10/2016 
#  Author: Nathan Martindale
#  Copyright © 2016 Digital Warrior Labs
#  Description: Creates backup/date-archived copy of passed file/folder
#*************************************************************

param (
	[Parameter(Position=1)]
	[string]$file = "",
	[switch]$help = $false,
	[string]$loc = "default",
	[switch]$edit = $false,
	[switch]$list = $false
)

# need to have file for default backup location (which should be the skydrive)

# check explicitly for data_dir environment variable, and if not set, then just use local folder ('.')

# then check if the default/shortcut system has been set up, and if not, set it up

$DATA_PATH = ""
$LOCS_FILE = ""

# Find all necessary files and folders
$dataDirExists = Test-Path Env:\DATA_DIR
if (!$dataDirExists) { $DATA_PATH = "." }
else { $DATA_PATH = "$DATA_DIR\utils-w" }

$DATA_PATH = "." # DEBUG ONLY

$LOCS_FILE = "$DATA_PATH\baklocs.dat"
$locsFileExists = Test-Path $LOCS_FILE
if (!$locsFileExists) 
{ 
	Write-Host "ERROR - Locations data not found" -ForegroundColor Red 
	$defaultLoc = Read-Host -prompt "Please enter default location to archive files to (no trailing '\')"
	Add-Content -path $LOCS_FILE -value "default=$defaultLoc"
}

# check if user wnats to edit
if ($edit) { notepad $LOCS_FILE; exit }

# check for if help needed 
if ($file -eq "" -or $help -and !$list)
{
	echo "Help goes here!"
	exit
}

# read in all locs
$locs = @{}
$locsFileContent = Get-Content -path $LOCS_FILE
foreach ($line in $locsFileContent)
{
	$index = $line.IndexOf("=")
	$key = $line.Substring(0,$index)
	$value = $line.Substring($index+1)

	$locs.Add($key, $value)

	if ($list) { Write-Host "`t$key = `"$value`"" }
}

if ($list) { exit }

$destination = ""

# check for existence and file type
$isFolder = Test-Path $file -PathType Container
$isFile = Test-Path $file -PathType Leaf
if (!$isFolder -and !$isFile) 
{
	Write-Host "ERROR - Passed file/folder not found" -ForegroundColor Red
	exit
}

# check for loc
if ($locs.$loc -eq $null)
{
	Write-Host "ERROR - Provided location not found!" -ForegroundColor Red
	exit
}

$destination = $locs[$loc]

$plainFileName = "$((Get-Item `'$file`').Basename)"
$extension = ""
if ($isFile) { $extension = "$((Get-Item `'$file`').Extension)" }

$date = "$(Get-Date -format M.d.yy)"

# create containing folder name
$destination += "\$plainFileName`_bak"

# check if containing folder exists
$containerExists = Test-Path "$destination"
if (!$containerExists) { md $destination }

if ($isFile)
{
	$nameResultBase = "$plainFileName $date"

	# check for suitable number (increment until that number isn't found)
	$foundSuitableNumber = $false
	$number = -1
	while (!$foundSuitableNumber)
	{
		$number++
		$exists = Test-Path "$destination\$nameResultBase`_$number$extension"
		if (!$exists) { $foundSuitableNumber = $true }
	}

	$finalResultName = "$nameResultBase`_$number$extension"

	copy $file "$destination\$fileResultName"
	echo "File archived to '$destination\$fileResultName'"
}
if ($isFolder)
{
	# check for suitable number (increment until that number isn't found)
	$foundSuitableNumber = $false
	$number = -1
	while (!$foundSuitableNumber)
	{
		$number++
		$exists = Test-Path "$destination\$date`_$number"
		if (!$exists) { $foundSuitableNumber = $true }
	}

	$finalFolderName = "$date`_$number"

	copy $file "$destination\$finalFolderName\"
	echo "Folder archived to '$destination\$finalFolderName'"
}
