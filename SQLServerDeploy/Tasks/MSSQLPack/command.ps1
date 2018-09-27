[CmdletBinding(DefaultParameterSetName = 'None')]
param(
     [String] [Parameter(Mandatory = $True)] [string]
    $filePattern ,
    [String] [Parameter(Mandatory = $True)] [string]
    $output 
)


 
New-Item -ItemType Directory -Force -Path $output

$fileName = ($filePattern).Trim(); 
Write-Host "Searching for:" $fileName
try {
 
    $file = Get-ChildItem $fileName -Recurse  
    if ($file.Length -eq 0) {
        Throw "No files found"
    }
    else {
        Write-Host "Found file: " $file
    }
}
catch {
    Write-Host "There was an error loading the file";
    Throw;
}


function Resolve-MsBuild {
	$msb2017 = Resolve-Path "${env:ProgramFiles(x86)}\Microsoft Visual Studio\*\*\MSBuild\*\bin\msbuild.exe" -ErrorAction SilentlyContinue
	if($msb2017) {
		Write-Host "Found MSBuild 2017 (or later)."
		Write-Host $msb2017
		return $msb2017
	}

	$msBuild2015 = "${env:ProgramFiles(x86)}\MSBuild\14.0\bin\msbuild.exe"

	if(-not (Test-Path $msBuild2015)) {
		throw 'Could not find MSBuild 2015 or later.'
	}

	Write-Host "Found MSBuild 2015."
	Write-Host $msBuild2015

	return $msBuild2015
}


$msbuild = Resolve-MsBuild
 
$msbuildArgs = @{ 
    performanceParameters = "/nologo", "/p:WarningLevel=4", "/clp:Summary", "/m:1"
    loggingParameters     = "/l:FileLogger,Microsoft.Build.Engine;logfile=$output\logdb.txt"
    packageParameters     = , "/property:outdir=$output", "/p:configuration=release"
    targets               = "/t:rebuild"
}

& $msbuild $fileName `
    $msbuildArgs.performanceParameters `
    $msbuildArgs.packageParameters `
    $msbuildArgs.loggingParameters `
    $msbuildArgs.targets
