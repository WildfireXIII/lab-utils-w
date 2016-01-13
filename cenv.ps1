#*************************************************************
#  File: cenv.ps1
#  Date created: 1/12/2016
#  Date edited: 1/12/2016
#  Author: Nathan Martindale
#  Copyright © 2016 Digital Warrior Labs
#  Description: Script to quickly set up a testing environment
#*************************************************************

param (
	[Parameter(Position=1)]
	[string]$name = "",
	[string]$type = "",
	[switch]$help = $false
)

# helpful constants
$DATA_DIR = $env:DATA_DIR

$DATA_DIR = "./env" # DEBUG ONLY

# get path to _env
$ENV_PATH = ""
$ENV_PATH_FILE = "$DATA_DIR\utils-w\cenvpath.dat"
$envPathFileExists = Test-Path $ENV_PATH_FILE 

# create path file if it doesn't exist
if (!$envPathFileExists)
{
	Write-Host "ERROR: _env folder path not found" -ForegroundColor Red
	$envPath = Read-Host -prompt "Please enter path to _env folder"
	Add-Content -path $ENV_PATH_FILE -value "$envPath"
}

$envPathFileContent = Get-Content -path $ENV_PATH_FILE
$ENV_PATH = $envPathFileContent

# check for nothing passed or help
if ($name -eq "" -or $help)
{
	echo "Help goes here!"
	exit
}

# create the project directory
echo "Creating directory '$ENV_PATH\$name'..."
md "$ENV_PATH\$name" | Out-Null
cd "$ENV_PATH\$name" | Out-Null

# current date
$currentDate = Get-Date -format %M/%d/yyyy

if ($type -eq "cpp")
{
	echo "Setting up folder as c++ project..."

	# get library path
	$LIB_DIR = $env:LIB_DIR

	# create default files
	$buildContent = "@echo off`ncall cl $name.cpp /I $LIB_DIR /EHsc /Fe$name /w`necho -------------------- PROGRAM RUN --------------------`n$name.exe" 
	
	$buildContent | Out-File -encoding ASCII -FilePath "build.bat" # done using encoding due to >> operators not using the right encoding

	$cppContent = @"
//*************************************************************
//  File: $name.cpp
//  Date created: $currentDate
//  Date edited: $currentDate
//  Author: Nathan Martindale
//  Copyright © 2016 Digital Warrior Labs
//  Description: 
//*************************************************************

#include <iostream>

using namespace std;

int main()
{
	cout << "Hello world!" << endl;
	return 0;
}
"@
	echo $cppContent > "$name.cpp"
	gvim "$name.cpp"
}

if ($type -eq "ps1")
{
	echo "Setting up folder as ps1 project..."

	$dataContent = "Hello world!`nFrom data file!"
	echo $dataContent > input.dat

	$scriptContent = @"
#*************************************************************
#  File: $name.ps1
#  Date created: $currentDate
#  Date edited: $currentDate
#  Author: Nathan Martindale
#  Copyright © 2016 Digital Warrior Labs
#  Description: 
#*************************************************************

param (
	[Parameter(Position=1)]
	[string]`$inputThing = ""
)

`$lines = Get-Content input.dat

foreach (`$line in `$lines)
{
	Write-Host `$line
}
"@
	echo $scriptContent > "$name.ps1"
	gvim "$name.ps1" "input.dat"
}




echo "Project successfully set up!"
