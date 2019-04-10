###########################################################################
# INSTALL .NET CORE CLI
###########################################################################
 
function global:InstallDotNetCore { 
    param(
        # Version
        [Parameter(Mandatory = $False)]
        [System.String]
        $DotNetVersion = "2.2.100"
    ) 

    Function Remove-PathVariable([string]$VariableToRemove) {
        $path = [Environment]::GetEnvironmentVariable("PATH", "User")
        if ($path -ne $null) {
            $newItems = $path.Split(';', [StringSplitOptions]::RemoveEmptyEntries) | Where-Object { "$($_)" -inotlike $VariableToRemove }
            [Environment]::SetEnvironmentVariable("PATH", [System.String]::Join(';', $newItems), "User")
        }
    
        $path = [Environment]::GetEnvironmentVariable("PATH", "Process")
        if ($path -ne $null) {
            $newItems = $path.Split(';', [StringSplitOptions]::RemoveEmptyEntries) | Where-Object { "$($_)" -inotlike $VariableToRemove }
            [Environment]::SetEnvironmentVariable("PATH", [System.String]::Join(';', $newItems), "Process")
        }
    }
     
    $DotNetInstallerUri = "https://dot.net/v1/dotnet-install.ps1";
 
    # Get .NET Core CLI path if installed.
    $FoundDotNetCliVersion = 0;
    if (Get-Command dotnet -ErrorAction SilentlyContinue) {
        $FoundDotNetCliVersion = (dotnet --version).Substring(0, 7);
        Write-Host "Found version: $FoundDotNetCliVersion"
    } 
    if ($FoundDotNetCliVersion -lt $DotNetVersion) {
        $InstallPath = $ENV:TEMP = Join-Path $PSScriptRoot ".dotnet"
        if (!(Test-Path $InstallPath)) {
            mkdir -Force $InstallPath | Out-Null;
        }        
        Write-Host 'Install the dotnet core 2.1 for use dotnet tool feature';
        $installerScript = "$InstallPath\dotnet-install.ps1";
        Write-Host "Start Download from dotnet cli from $DotNetInstallerUri in $installerScript";        
        (New-Object System.Net.WebClient).DownloadFile($DotNetInstallerUri, $installerScript);
        & $InstallPath\dotnet-install.ps1 -Channel $DotNetChannel -Version $DotNetVersion -InstallDir $InstallPath;
 

        Remove-PathVariable "$InstallPath"
        $env:PATH = "$InstallPath;$env:PATH"
    }
    $env:DOTNET_SKIP_FIRST_TIME_EXPERIENCE = 1
    $env:DOTNET_CLI_TELEMETRY_OPTOUT = 1
 
    return Get-Command  dotnet.exe;
}

function Install-DotNet-Dacpac {
    $dotnet= global:InstallDotNetCore
     if (Get-Command dotnet-dacpac.exe -ErrorAction SilentlyContinue) {
         Write-Host 'Found dotnet-dacpac.exe'
     }
     else {
         
         Write-Host 'Installing the dotnet tool feature for deploy .dacpac';
        &$dotnet tool install --global Dacpac.Tool 
     }
     return Get-Command dotnet-dacpac.exe;
 }


[CmdletBinding(DefaultParameterSetName = 'None')]
param(

    [String] [Parameter(Mandatory = $True)]
    $dacpacPattern,

    [String] [Parameter(Mandatory = $True)]
    $dacpacPath,
    [String] [Parameter(Mandatory = $True)]
    $server,
 
    [String] [Parameter(Mandatory = $True)]
    $userId,

    [SecureString] [Parameter(Mandatory = $True)]
    $password,

    [String] [Parameter(Mandatory = $True)]
    $dbName,

    [String] [Parameter(Mandatory = $False)]
    $blockOnPossibleDataLoss = "false",

    [String] [Parameter(Mandatory = $False)]
    $verifyDeployment = "true",

    [String] [Parameter(Mandatory = $False)]
    $compareUsingTargetCollation = "true",

    [String] [Parameter(Mandatory = $False)]
    $allowIncompatiblePlatform = "true",

    [Int32][Parameter(Mandatory = $true)]
    $commandTimeout = 7200,

    [String] [Parameter(Mandatory = $False)]
    $createNewDatabase = "false",

    [String] [Parameter(Mandatory = $False)]
    $sqlVersion = "120",

    [String] [Parameter(Mandatory = $False)]
    $variablesInput = ""
)

Write-Host "Preparing Publishing Variables"
$Variables = ConvertFrom-StringData -StringData $variablesInput
foreach ($VariableKey in $Variables.Keys) {
    [Environment]::SetEnvironmentVariable($VariableKey, $Variables[$VariableKey], "User");
    Write-Host $Variables[$VariableKey];
}
  
 
$dacpac = Install-Dotnet-Dacpac

if (!(Test-Path $dacpacPath)) {
    Write-Error "The path $dacpacPath not exists"
    return;
}  

$currentPath = Get-Location
Set-Location $dacpacPath

Write-Host 'Start publish database'

&$dacpac publish --DacPath=$dacpacPath --server=$server --namePattern=$dacpacPattern  --databaseNames=$dbName --blockOnPossibleDataLoss=$blockOnPossibleDataLoss --verifyDeployment=$verifyDeployment --compareUsingTargetCollation=$compareUsingTargetCollation --allowIncompatiblePlatform=$allowIncompatiblePlatform --commandTimeout=$commandTimeout --createNewDatabase=$createNewDatabase

Set-Location $currentPath  
