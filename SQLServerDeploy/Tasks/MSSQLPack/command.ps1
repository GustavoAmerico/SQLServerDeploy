[CmdletBinding(DefaultParameterSetName = 'None')]
param(
    [String] [Parameter(Mandatory = $False)] [string]
    $output = ""
)
New-Item -ItemType Directory -Force -Path $output
$msbuild = @{ 
    performanceParameters = "/nologo", "/noconsolelogger", "/p:WarningLevel=0", "/clp:ErrorsOnly", "/m:1"
    loggingParameters     = "/l:FileLogger,Microsoft.Build.Engine;logfile=$output\log.txt"
    packageParameters     = , "/property:outdir=$output", "/p:configuration=release"
    targets               = "/t:rebuild"
}
MSBuild  `
    $msbuild.performanceParameters `
    $msbuild.packageParameters `
    $msbuild.loggingParameters `
    $msbuild.targets