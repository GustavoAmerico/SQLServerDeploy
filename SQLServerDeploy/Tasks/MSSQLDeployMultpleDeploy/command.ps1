[CmdletBinding(DefaultParameterSetName = 'None')]
param(

    [String] [Parameter(Mandatory = $True)]
    $dacpacPattern,

    [String] [Parameter(Mandatory = $True)]
    $dacpacPath,

    [String] [Parameter(Mandatory = $True)]
    $server,

    [String] [Parameter(Mandatory = $True)]
    $dbName,
    
    [String] [Parameter(Mandatory = $True)]
    $userId,

    [SecureString] [Parameter(Mandatory = $True)]
    $password,

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
# add-type -path "C:\Program Files (x86)\Microsoft SQL Server\120\DAC\bin\Microsoft.SqlServer.Dac.dll"
  
#Load Microsoft.SqlServer.Dac assembly
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Dac")

$allDatabases = GetDatabaseList;
$dacPack = GetDacPackage;
$option = CreateDacDeployOptions;


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

function GetDatabaseList() {

    $allDatabases = $dbName.Split(';');
    if ($allDatabases.Length -eq 0) {
        Throw "Without database selected";
    }
    else {Write-Host "Total database:  " + $allDatabases.Length; }
    return $allDatabases;
}

function GetDacPackage() {

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
            Write-Host "Found file: " $file
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