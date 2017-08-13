[CmdletBinding(DefaultParameterSetName = 'None')]
param(
    [String] [Parameter(Mandatory = $False)] [string]
    $output = ""
)
New-Item -ItemType Directory -Force -Path $output
$msbuild = @{ 
    performanceParameters = "/nologo", "/p:WarningLevel=4", "/clp:Summary", "/m:1"
    loggingParameters     = "/l:FileLogger,Microsoft.Build.Engine;logfile=$output\logdb.txt"
    packageParameters     = , "/property:outdir=$output", "/p:configuration=release"
    targets               = "/t:rebuild"
}
MSBuild  `
    $msbuild.performanceParameters `
    $msbuild.packageParameters `
    $msbuild.loggingParameters `
    $msbuild.targets