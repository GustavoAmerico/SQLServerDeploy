

###########################################################################
# INSTALL .NET CORE CLI
###########################################################################

function Install-DotNet-Dacpac {
   $dotnet= global:InstallDotNetCore
    if (Get-Command dotnet-dacpac.exe -ErrorAction SilentlyContinue) {
        Write-Host 'Found dotnet-dacpac.exe'
    }
    else {
        
        Write-Host 'Install the dotnet tool feature for deploy .dacpac';
     start   $dotnet tool install --global Dacpac.Tool 
    }
    return Get-Command dotnet-dacpac.exe;
}


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


 