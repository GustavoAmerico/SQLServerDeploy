[CmdletBinding(DefaultParameterSetName = 'None')]
param(
    [String] [Parameter(Mandatory = $True)] [string]
    $filePattern ,
    [String] [Parameter(Mandatory = $True)] [string]
    $output, 
    [String][Parameter(Mandatory = $False)] [string]
    $path = '.\'
)
 
function Resolve-MsBuild {
    $msb2017 = Resolve-Path "${env:ProgramFiles(x86)}\Microsoft Visual Studio\*\*\MSBuild\*\bin\msbuild.exe" -ErrorAction SilentlyContinue
    if ($msb2017) {
        Write-Information "Found MSBuild 2017 (or later)."
        Write-Host $msb2017
        return $msb2017
    }

    $msBuild2015 = "${env:ProgramFiles(x86)}\MSBuild\14.0\bin\msbuild.exe"

    if (-not (Test-Path $msBuild2015)) {
        throw 'Could not find MSBuild 2015 or later.'
    }

    Write-Information "Found MSBuild 2015."
    Write-Host $msBuild2015

    return $msBuild2015
}

function Install-Dependency { 
    Write-Information 'Installing SQL Server Data Tools from nuget'
    nuget.exe install Microsoft.Data.Tools.Msbuild -Version 10.0.61804.210
}

function BuildSqlProject {
    param([String] [Parameter(Mandatory = $True)] $file, [String] [Parameter(Mandatory = $False)] $outDir)
    $nugetPath = ($env:userprofile + '\.nuget\packages\microsoft.data.tools.msbuild\10.0.61804.210\lib\net46');

    $msbuild = Resolve-MsBuild


    $msbuildArgs = @{ 
        performanceParameters = "/nologo", "/p:WarningLevel=4", "/clp:Summary", "/m:1"
        loggingParameters     = "/l:FileLogger,Microsoft.Build.Engine;logfile=$outDir\logdb.txt"
        packageParameters     = , "/property:outdir=$outDir", "/p:configuration=release", "/p:SQLDBExtensionsRefPath=$nugetPath", "/p:SqlServerRedistPath=$nugetPath"
        targets               = "/t:rebuild"
    }
    
    & $msbuild  $file `
        $msbuildArgs.performanceParameters `
        $msbuildArgs.packageParameters `
        $msbuildArgs.loggingParameters `
        $msbuildArgs.targets

    Write-Information ('O Arquivo foi publicado em ' + $outDir)
}

 
try {

    $fileName = ($filePattern).Trim(); 
    Write-Information "Searching for:" $fileName

    $files = Get-ChildItem $fileName -Recurse -File -Path $path | % {$_}
    if ($files.Length -eq 0) {
        Throw "No files found"
    }
    else {
        Install-Dependency;

        foreach ($file in $files) {
            Write-Information "Found file: " $file
            $outDir = New-Item -ItemType Directory -Force -Path $output -Name $file.BaseName | % {$_.FullName}
            BuildSqlProject $file.FullName $outDir;
        }
    }
}
catch {
    Write-Information "There was an error loading the file";
    Throw;
}



