

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
    $FoundDotNetCliVersion = $null;
    if (Get-Command dotnet -ErrorAction SilentlyContinue) {
        $FoundDotNetCliVersion = dotnet --version;
    }
 
    if ($FoundDotNetCliVersion -ne $DotNetVersion) {
        $InstallPath = Join-Path $PSScriptRoot ".dotnet"
        if (!(Test-Path $InstallPath)) {
            mkdir -Force $InstallPath | Out-Null;
        }
        (New-Object System.Net.WebClient).DownloadFile($DotNetInstallerUri, "$InstallPath\dotnet-install.ps1");
        & $InstallPath\dotnet-install.ps1 -Channel $DotNetChannel -Version $DotNetVersion -InstallDir $InstallPath;
 

        Remove-PathVariable "$InstallPath"
        $env:PATH = "$InstallPath;$env:PATH"
    }
    $env:DOTNET_SKIP_FIRST_TIME_EXPERIENCE = 1
    $env:DOTNET_CLI_TELEMETRY_OPTOUT = 1
 
    
}