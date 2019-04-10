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

function TryResgisterSqlServerDac() {
    [OutputType([bool])]
    #[System.Reflection.Assembly]::Load("System.EnterpriseServices, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a");
    #$publish = New-Object System.EnterpriseServices.Internal.Publish ;
    $files = Get-ChildItem @('C:\Program Files (x86)\Microsoft SQL Server\**\Microsoft.SqlServer.Dac.dll', 'C:\Program Files (x86)\Microsoft Visual Studio\**\Microsoft.SqlServer.Dac.dll', 'C:\Microsoft.Data.Tools.Msbuild**\lib\**\Microsoft.SqlServer.Dac.dll', '**\.nuget\packages\microsoft.data.tools.msbuild\*\lib\**\Microsoft.SqlServer.Dac.dll' ) -Recurse -ErrorAction SilentlyContinue ;
    $dllIsRegister = $False;
    ForEach ($file in  $files) { 
        Write-Host ('Try register dll ' + $file.FullName);
        #$publish.GacInstall($file.FullName);
        # [System.Reflection.Assembly]::LoadFile($file.FullName)
        add-type -path $file.FullName
        $dllIsRegister = $True;
    } 
     
    return $dllIsRegister;
}   

function GetDatabaseList() {
    param(   
        [String] [Parameter(Mandatory = $True )]
        $dbName     
    )

    if ([string]::IsNullOrEmpty($dbName)) {
        Write-Error "The database name not can be null";
        return null;
    }

    $allDatabases = $dbName.Split(';');
    if ($allDatabases.Length -eq 0) {
        Throw "Without database selected";
    }
    else {
        Write-Host "Total database:  " $allDatabases.Length; 
        
    }
    return $allDatabases;
}

function GetDacPackage() {
    param(    
        [String] [Parameter(Mandatory = $True)]
        $dacpacPattern,

        [String] [Parameter(Mandatory = $True)]
        $dacpacPath  
    )
    if (![System.IO.Directory]::Exists($dacpacPath)) {
        Write-Host "No directory found:" $dacpacPath;
        return;
    }
    
    $fileName = ($dacpacPath + "\" + $dacpacPattern).Trim(); 
    Write-Host "Searching for:" $fileName
    try {
     
        $file = Get-ChildItem $fileName -Recurse  
        if ($file.Length -eq 0) {
            Throw "No files found"
        }
        else {
            Write-Host "Found file: " $file;
            TryResgisterSqlServerDac

        }
    }
    catch {
        Write-Host "There was an error loading the file";
        Throw;
    }    
    #Essa virgula serve para o powershell não retorna um array de objeto 
    return [Microsoft.SqlServer.Dac.DacPackage]::Load($file);
     
}
 
function  CreateDacDeployOptions() {
    [OutputType([Microsoft.SqlServer.Dac.DacDeployOptions])]
    param(    
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
        $createNewDatabase = "false"
    )
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Dac")
    Write-Host "Preparing Publishing Variables"
    $option = new-object Microsoft.SqlServer.Dac.DacDeployOptions 
    $option.CommandTimeout = 7200; 
    $option.BlockOnPossibleDataLoss = [System.Convert]::ToBoolean($blockOnPossibleDataLoss.Trim());
    $option.CompareUsingTargetCollation = [System.Convert]::ToBoolean( $compareUsingTargetCollation.Trim());
    
    $option.AllowIncompatiblePlatform = [System.Convert]::ToBoolean( $allowIncompatiblePlatform.Trim());
    $option.VerifyDeployment = [System.Convert]::ToBoolean($verifyDeployment.Trim());
    $option.CreateNewDatabase = [System.Convert]::ToBoolean($createNewDatabase.Trim());
    $option.CommandTimeout = [System.Convert]::ToInt32($commandTimeout);
    Write-Host ([System.String]::Format("CreateNewDatabase:{0}", $option.CreateNewDatabase)) -NoNewline;
    Write-Host ([System.String]::Format("CommandTimeout: {0}", $option.CommandTimeout)) -NoNewline;
    Write-Host ([System.String]::Format("BlockOnPossibleDataLoss:{0}", $option.BlockOnPossibleDataLoss)) -NoNewline;
    Write-Host ([System.String]::Format("AllowIncompatiblePlatform:{0}", $option.AllowIncompatiblePlatform)) -NoNewline;
    Write-Host ([System.String]::Format("CompareUsingTargetCollation:{0}", $option.CompareUsingTargetCollation)) -NoNewline;
    Write-Host ([System.String]::Format("VerifyDeployment:{0}", $option.VerifyDeployment)) -NoNewline;
    #Essa virgula serve para o powershell não retorna um array de objeto 
    return $option;    

}

 

function Test-SQLConnection {    
    [OutputType([bool])]
    Param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        $ConnectionString
    )
    try {
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString;
        $sqlConnection.Open();
        $sqlConnection.Close();

        return $true;
    }
    catch {
        return $false;
    }
}




function Resolve-MsBuild {
    $msb2017 = Resolve-Path "${env:ProgramFiles(x86)}\Microsoft Visual Studio\*\*\MSBuild\*\bin\msbuild.exe" -ErrorAction SilentlyContinue
    if ($msb2017) {
        Write-Host "Found MSBuild 2017 (or later)."
        Write-Host $msb2017
        return $msb2017
    }

    $msBuild2015 = "${env:ProgramFiles(x86)}\MSBuild\14.0\bin\msbuild.exe"

    if (-not (Test-Path $msBuild2015)) {
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

    Write-Host ('O Arquivo foi publicado em ' + $outDir)
}

 
try {

    $fileName = ($filePattern).Trim(); 
    Write-Host "Searching for:" $fileName

    $files = Get-ChildItem $fileName -Recurse -File -Path $path | % {$_}
    if ($files.Length -eq 0) {
        Throw "No files found"
    }
    else {
        Install-Dependency;

        foreach ($file in $files) {
            Write-Host "Found file: " $file
            $outDir = New-Item -ItemType Directory -Force -Path $output -Name $file.BaseName | % {$_.FullName}
            BuildSqlProject $file.FullName $outDir;
        }
    }
}
catch {
    Write-Host "There was an error loading the file";
    Throw;
}



