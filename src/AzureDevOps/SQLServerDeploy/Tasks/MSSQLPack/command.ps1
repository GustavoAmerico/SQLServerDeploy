[CmdletBinding(DefaultParameterSetName = 'None')]
param(
    [String] [Parameter(Mandatory = $True)] [string]
    $filePattern ,
    [String] [Parameter(Mandatory = $True)] [string]
    $output, 
    [String][Parameter(Mandatory = $False)] [string]
    $path = '.\'
)

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Dac");
 


function Resolve-MsBuild {
    Write-Host 'Searching by msbuild'
    $msb2017 = Resolve-Path "${env:ProgramFiles(x86)}\Microsoft Visual Studio\*\*\MSBuild\*\bin\msbuild.exe" -ErrorAction SilentlyContinue | % { $_.FullName }
    if ($msb2017) {
        Write-Host "Found MSBuild 2017 (or later)."
        Write-Host $msb2017
        return  (Get-Command $msb2017 )
    }

    $msBuild2015 = "${env:ProgramFiles(x86)}\MSBuild\14.0\bin\msbuild.exe" 

    if (-not (Test-Path $msBuild2015)) {
        throw 'Could not find MSBuild 2015 or later.'
    }

    Write-Host "Found MSBuild 2015."
    Write-Host $msBuild2015
    return (Get-Command $msBuild2015 -ErrorAction SilentlyContinue)
}

function Install-Dependency { 
    
    if (Get-Command nuget.exe -ErrorAction SilentlyContinue) {
        Write-Host 'Installing SQL Server Data Tools from nuget'
        &nuget.exe install Microsoft.Data.Tools.Msbuild -Version 10.0.61804.210 
    }
    else {     
        $sourceNugetExe = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
        Write-Host "The nuget command line not found. We will download from $sourceNugetExe"        
        $targetNugetExe = ($ENV:LOCALAPPDATA + "\nuget.exe")
        Invoke-WebRequest $sourceNugetExe -OutFile $targetNugetExe
        [System.Environment]::SetEnvironmentVariable("Path", ($env:Path + ';' + $targetNugetExe), 'User')
        Write-Host "The nuget was downloaded in $targetNugetExe"
        $nuget = (Get-Command $targetNugetExe);
        Write-Host 'Installing SQL Server Data Tools from nuget after downloading'
        &$nuget install Microsoft.Data.Tools.Msbuild -Version 10.0.61804.210
        #Write-Error 'Your need install the nuget cli and add path in Enviroment variable'
    }
}

function BuildSqlProject {
    param([String] [Parameter(Mandatory = $True)] $file, [String] [Parameter(Mandatory = $False)] $outDir)
    Write-Host 'Start BuildSqlProject';
    $nugetPath = ($env:userprofile + '\.nuget\packages\microsoft.data.tools.msbuild\10.0.61804.210\lib\net46');

    $msbuildArgs = @{ 
        performanceParameters = "/nologo", "/p:WarningLevel=4", "/clp:Summary", "/m:1"
        loggingParameters     = "/l:FileLogger,Microsoft.Build.Engine;logfile=$outDir\logdb.txt"
        packageParameters     = , "/property:outdir=$outDir", "/p:configuration=release", "/p:SQLDBExtensionsRefPath=$nugetPath", "/p:SqlServerRedistPath=$nugetPath"
        targets               = "/t:rebuild"
    }
    
    $msbuild = &Resolve-MsBuild
    Write-Host ('Build the file: ' + $file)
    Write-Host ('Found MSBUILD: ' + $msbuild )
    &$msbuild $file `
        $msbuildArgs.performanceParameters `
        $msbuildArgs.packageParameters `
        $msbuildArgs.loggingParameters `
        $msbuildArgs.targets

    Write-Host ('O Arquivo foi publicado em ' + $outDir)
}

 
try {

    $fileName = ($filePattern).Trim(); 
    if ([System.String]::IsNullOrEmpty($fileName)) {
        $fileName = '*.sqlproj';   
    }
    if ([System.String]::IsNullOrEmpty($path)) {
        $path = $(pwd);   
    }
        

    Write-Host ("Searching for: $fileName")

    $files = Get-ChildItem  -File $fileName -Recurse -Path $path
    if ($files.Length -eq 0) {
        $erro = ("No files found in " + $path );
        Throw $erro
    }
    else {
        Write-Host ("The project was found")
        Install-Dependency;

        foreach ($file in $files) {
            Write-Host "Found file: " $file;            
            $outDir = New-Item -ItemType Directory -Force -Path $output -Name $file.BaseName | % { $_.FullName };
            Write-Host ('The system will compile the file ' + $file.FullName);
            &BuildSqlProject $file.FullName $outDir;
        }
    }
}
catch {
    Write-Host "There was an error loading the file";
    Throw;
}



