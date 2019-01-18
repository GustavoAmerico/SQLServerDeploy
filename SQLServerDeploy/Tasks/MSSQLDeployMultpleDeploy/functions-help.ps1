function TryResgisterSqlServerDac()
{
  
    [System.Reflection.Assembly]::Load("System.EnterpriseServices, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a");
    $publish = New-Object System.EnterpriseServices.Internal.Publish ;
    $files =Get-ChildItem @('C:\Program Files (x86)\Microsoft SQL Server\**\Microsoft.SqlServer.Dac.dll', 'C:\Program Files (x86)\Microsoft Visual Studio\**\Microsoft.SqlServer.Dac.dll','C:\Microsoft.Data.Tools.Msbuild**\lib\**\Microsoft.SqlServer.Dac.dll', '**\.nuget\packages\microsoft.data.tools.msbuild\*\lib\**\Microsoft.SqlServer.Dac.dll' ) -Recurse -ErrorAction SilentlyContinue ;
    $dllIsRegister = $False;
    ForEach ($file in  $files){ 
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

    if ([string]::IsNullOrEmpty($dbName))
{
    Write-Error "The database name not can be null";
    return null;
}

    $allDatabases = $dbName.Split(';');
    if ($allDatabases.Length -eq 0) {
        Throw "Without database selected";
    }
    else {Write-Host "Total database:  " + $allDatabases.Length; }
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
    
    $dp = [Microsoft.SqlServer.Dac.DacPackage]::Load($file);
    return $dp;
}
 
function  CreateDacDeployOptions() {
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
    Write-Host [System.String]::Format("CreateNewDatabase:{0}", $option.CreateNewDatabase) -NoNewline;
    Write-Host [System.String]::Format("CommandTimeout: {0}", $option.CommandTimeout) -NoNewline;
    Write-Host [System.String]::Format("BlockOnPossibleDataLoss:{0}", $option.BlockOnPossibleDataLoss) -NoNewline;
    Write-Host [System.String]::Format("AllowIncompatiblePlatform:{0}", $option.AllowIncompatiblePlatform) -NoNewline;
    Write-Host [System.String]::Format("CompareUsingTargetCollation:{0}", $option.CompareUsingTargetCollation) -NoNewline;
    Write-Host [System.String]::Format("VerifyDeployment:{0}", $option.VerifyDeployment) -NoNewline;
    
    return $option;    

}


function DeployDb() {
    param(       
         [Parameter(Mandatory = $False)]
        $dacpacPattern = "**\*.dacpac",

        [Parameter(Mandatory = $True)]
        $dacpacPath,

        [String] [Parameter(Mandatory = $True)]
        $server,

        [String] [Parameter(Mandatory = $True)]
        $dbName,
    
        [String] [Parameter(Mandatory = $True)]
        $userId,

        [String] [Parameter(Mandatory = $True)]
        $password,

        [String] [Parameter(Mandatory = $False)]
        $blockOnPossibleDataLoss = "false",

        [String] [Parameter(Mandatory = $False)]
        $verifyDeployment = "true",

        [String] [Parameter(Mandatory = $False)]
        $compareUsingTargetCollation = "true",

        [String] [Parameter(Mandatory = $False)]
        $allowIncompatiblePlatform = "true",

        [String][Parameter(Mandatory = $True)]
        $commandTimeout = "7200",

        [String] [Parameter(Mandatory = $False)]
        $createNewDatabase = "false"
    )

    #$server, $userId, $password,
    $allDatabases = GetDatabaseList( $dbName);
    $dacPack = GetDacPackage( $dacpacPattern, $dacpacPath);
    $option = CreateDacDeployOptions($blockOnPossibleDataLoss, $verifyDeployment, $compareUsingTargetCollation , $allowIncompatiblePlatform, $commandTimeout, $createNewDatabase) ;
    Write-Host "Start deploy file"

    foreach ($database in $allDatabases) {
        try {
            $connectionString = [System.Linq.Enumerable]::Select($allDatabases, ($database = > [System.String]::Format("Server=tcp:{0};Initial Catalog={3};Persist Security Info=False;User ID={1};Password={2};MultipleActiveResultSets=True;Encrypt=True;", $server.Trim(), $userId, $password, $database.Trim())));
            Write-Host "Try deploy in $database"
    
            $dacService = new-object Microsoft.SqlServer.Dac.DacServices($connectionString);
            $dacService.Deploy($dacPack, $database, "True", $option)
            Write-Host "Finish Deploy to $database";
        }
        catch {
            Write-Host "Error Deploy to $database"
        }
    }

    Write-Host "Finish deploy for all database"
}

