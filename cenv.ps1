#*************************************************************
#  File: cenv.ps1
#  Date created: 1/12/2016
#  Date edited: 1/18/2016
#  Author: Nathan Martindale
#  Copyright � 2016 Digital Warrior Labs
#  Description: Script to quickly set up a testing environment
#*************************************************************

param (
	[Parameter(Position=1)]
	[string]$name = "",
	[string]$type = "",
	[switch]$here = $false, # doesn't create env folder in _env, just code file template
	[switch]$noextra = $false, # depending on type, either disincludes compiler/input file
	[switch]$help = $false
)

# helpful constants
$DATA_DIR = $env:DATA_DIR

# get path to _env
$ENV_PATH = ""
$ENV_PATH_FILE = "$DATA_DIR\utils-w\cenvpath.dat"
$envPathFileExists = Test-Path $ENV_PATH_FILE 

# create path file if it doesn't exist
if (!$envPathFileExists -and !$here)
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
	echo "`nQuickly creates either a full testing environment, or sets up a template code file with an optional compiler."
	echo "`nUsage: `n`tcenv -type [TYPE] [NAME] = creates a new folder NAME in the set _env folder path, and adds code file templates for the given TYPE`n`tcenv -type [TYPE] [NAME] -here = inserts code file templates for given TYPE in the current folder`n`tcenv -type [TYPE] [NAME] [-here] -noextra = does NOT include compiler/data file`n`tcenv -help = shows this help. duh."
	echo "`nAvailable types: cpp, ps1, java`n"
	exit
}

# create the project directory (if applicable)
if (!$here)
{
	echo "Creating directory '$ENV_PATH\$name'..."
	md "$ENV_PATH\$name" | Out-Null
	cd "$ENV_PATH\$name" | Out-Null
}

# current date
$currentDate = Get-Date -format %M/%d/yyyy

if ($type -eq "cpp")
{
	echo "Setting up c++ files..."

	# get library path
	$LIB_DIR = $env:LIB_DIR

	# create default files
	$buildContent = "@echo off`ncall cl *.cpp /I $LIB_DIR /EHsc /Fe$name /w`necho -------------------- PROGRAM RUN --------------------`n$name.exe" 
	
	if (!$noextra) { $buildContent | Out-File -encoding ASCII -FilePath "build.bat" } # done using encoding due to >> operators not using the right encoding 

	$cppContent = @"
//*************************************************************
//  File: $name.cpp
//  Date created: $currentDate
//  Date edited: $currentDate
//  Author: Nathan Martindale
//  Copyright � 2016 Digital Warrior Labs
//  Description: 
//*************************************************************

#include <iostream>

using namespace std;

int main(int argc, char* argv[])
{
	cout << "Hello world!" << endl;
	return 0;
}
"@
	echo $cppContent > "$name.cpp"
	gvim "$name.cpp"
}

if ($type -eq "libcpp")
{
	echo "Setting up c++ files..."

	# get library path
	$LIB_DIR = $env:LIB_DIR

	# create directory structure
	md src,env,bin

	# create default files
	$buildContent = "@echo off`npushd `"..\bin`"`ncall cl `"..\src\*.cpp`" `"..\env\*.cpp`" /I $LIB_DIR /EHsc /FeTesting /w`ncopy `".\Testing.exe`" `"..\env\Testing.exe`"`npopd`necho -------------------- PROGRAM RUN --------------------`nTesting.exe" 
	
	if (!$noextra) { $buildContent | Out-File -encoding ASCII -FilePath "env\build.bat" } # done using encoding due to >> operators not using the right encoding 

	$hContent = @"
//*************************************************************
//  File: $name.h
//  Date created: $currentDate
//  Date edited: $currentDate
//  Author: Nathan Martindale
//  Copyright � 2016 Digital Warrior Labs
//  Description: 
//*************************************************************

#include <iostream>

using namespace std;

class $name
{
	private:

	public:
		void test();
};
"@

	$cppContent = @"
//*************************************************************
//  File: $name.cpp
//  Date created: $currentDate
//  Date edited: $currentDate
//  Author: Nathan Martindale
//  Copyright � 2016 Digital Warrior Labs
//  Description: 
//*************************************************************

#include "$name.h"

using namespace std;

void $name::test()
{
	cout << "Hello world!" << endl;
}
"@

	$testContent = @"
//*************************************************************
//  File: Testing.cpp
//  Date created: $currentDate
//  Date edited: $currentDate
//  Author: Nathan Martindale
//  Copyright � 2016 Digital Warrior Labs
//  Description: 
//*************************************************************

#include <iostream>
#include "../src/$name.h"

using namespace std;

int main(int argc, char* argv[])
{
	$name* obj = new $name();
	obj->test();
	
	return 0;
}
"@

	echo $cppContent > "src\$name.cpp"
	echo $hContent > "src\$name.h"
	echo $testContent > "env\Testing.cpp"
	gvim "src/*.cpp" "src/*.h" "env/*.cpp"
}

if ($type -eq "ps1")
{
	echo "Setting up ps1 files..."

	$dataContent = "Hello world!`nFrom data file!"
	if (!$noextra) { echo $dataContent > input.dat }

	$scriptContent = @"
#*************************************************************
#  File: $name.ps1
#  Date created: $currentDate
#  Date edited: $currentDate
#  Author: Nathan Martindale
#  Copyright � 2016 Digital Warrior Labs
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

	$editString = "$name.ps1"
	if (!$noextra) { $editString += " input.dat" }
	gvim "$editString"
}

# TODO: Anything need to be done with library/jar folders?
if ($type -eq "java")
{
	echo "Setting up java files..."
	
	$compilerContent = @"
@echo off
javac *.java
java $name
"@

	if (!$noextra) { $compilerContent | Out-File -encoding ASCII -FilePath "build.bat" }

	$javaContent = @"
//*************************************************************
//  File: $name.java
//  Date created: $currentDate
//  Date edited: $currentDate
//  Author: Nathan Martindale
//  Copyright � 2016 Digital Warrior Labs
//  Description: 
//*************************************************************

import java.io.*;
import java.util.*;

public class $name
{
	public static void main(String[] args)
	{
		BufferedReader in = new BufferedReader(new InputStreamReader(System.in));

		System.out.println("Enter name:");
		String name = "";
		try { name = in.readLine(); } catch (IOException e) { }
		System.out.println("Hello " + name + "!");
	}
}
"@
	$javaContent | Out-File -encoding ASCII -FilePath "$name.java"

	gvim "$name.java"
}

echo "Environment successfully created!"
