[CmdletBinding(DefaultParameterSetName = 'None')]
param(
     [String] [Parameter(Mandatory = $True)] [string]
    $filePattern ,
    [String] [Parameter(Mandatory = $True)] [string]
    $output 
)

$path = [environment]::GetEnvironmentVariable("windir","Process")+"\Microsoft.NET\Framework64\v4.0.30319";
add-type -path $path
 
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


add-type -path "%windir%\Microsoft.NET\Framework64\v4.0.30319"
$msbuild = @{ 
    performanceParameters = "/nologo", "/p:WarningLevel=4", "/clp:Summary", "/m:1"
    loggingParameters     = "/l:FileLogger,Microsoft.Build.Engine;logfile=$output\logdb.txt"
    packageParameters     = , "/property:outdir=$output", "/p:configuration=release"
    targets               = "/t:rebuild"
}
MSBuild $fileName `
    $msbuild.performanceParameters `
    $msbuild.packageParameters `
    $msbuild.loggingParameters `
    $msbuild.targets
