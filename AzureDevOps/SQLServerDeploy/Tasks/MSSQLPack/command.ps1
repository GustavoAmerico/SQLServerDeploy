[CmdletBinding(DefaultParameterSetName = 'None')]
param(
     [String] [Parameter(Mandatory = $True)] [string]
    $filePattern ,
    [String] [Parameter(Mandatory = $True)] [string]
    $output 
)
 
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

function Install-Dependency { 
     Write-Host 'Installing SQL Server Data Tools from nuget'
     nuget.exe install Microsoft.Data.Tools.Msbuild -Version 10.0.61804.210
}

function BuildSqlProject {
param([String] [Parameter(Mandatory = $True)] $file)
    $nugetPath = ($env:userprofile + '\.nuget\packages\microsoft.data.tools.msbuild\10.0.61804.210\lib\net46');

    $msbuild = Resolve-MsBuild
    $msbuildArgs = @{ 
        performanceParameters = "/nologo", "/p:WarningLevel=4", "/clp:Summary", "/m:1"
        loggingParameters     = "/l:FileLogger,Microsoft.Build.Engine;logfile=$output\logdb.txt"
        packageParameters     = , "/property:outdir=$output", "/p:configuration=release","/p:SQLDBExtensionsRefPath=$nugetPath","/p:SqlServerRedistPath=$nugetPath"
        targets               = "/t:rebuild"
    }
    
    & $msbuild  $file `
        $msbuildArgs.performanceParameters `
        $msbuildArgs.packageParameters `
        $msbuildArgs.loggingParameters `
        $msbuildArgs.targets

}

New-Item -ItemType Directory -Force -Path $output

try {

    $fileName = ($filePattern).Trim(); 
    Write-Host "Searching for:" $fileName

    $files = Get-ChildItem $fileName -Recurse  
    if ($files.Length -eq 0) {
        Throw "No files found"
    }
    else {
        foreach ($file in $files){

        Write-Host "Found file: " $file
        Install-Dependency;
        BuildSqlProject $file;
    }
}
}
catch {
    Write-Host "There was an error loading the file";
    Throw;
}



