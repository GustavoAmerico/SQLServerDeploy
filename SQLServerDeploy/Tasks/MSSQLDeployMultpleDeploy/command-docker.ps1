# [CmdletBinding(DefaultParameterSetName = 'None')]
# param(

#     [String] [Parameter(Mandatory = $True)]
#     $dacpacPattern,

#     [String] [Parameter(Mandatory = $True)]
#     $dacpacPath,

#     [String] [Parameter(Mandatory = $True)]
#     $server,

#     [String] [Parameter(Mandatory = $True)]
#     $dbName,
    
#     [String] [Parameter(Mandatory = $True)]
#     $userId,

#     [String] [Parameter(Mandatory = $True)]
#     $password,

#     [String] [Parameter(Mandatory = $False)]
#     $blockOnPossibleDataLoss = "false",

#     [String] [Parameter(Mandatory = $False)]
#     $verifyDeployment = "true",

#     [String] [Parameter(Mandatory = $False)]
#     $compareUsingTargetCollation = "true",

#     [String] [Parameter(Mandatory = $False)]
#     $allowIncompatiblePlatform = "true",

#     [String][Parameter(Mandatory = $True)]
#     $commandTimeout = "7200",

#     [String] [Parameter(Mandatory = $False)]
#     $createNewDatabase = "false"
# )
 
. C:\src\functions-help.ps1

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Dac")
  
#'/dacpacfiles' %server% %databases% %userId% $ENV:server $ENV:databases $ENV:userId $ENV:password $ENV:blockOnPossibleDataLoss $ENV:verifyDeployment $ENV:compareUsingTargetCollation $ENV:allowIncompatiblePlatform $ENV:commandTimeout $ENV:createNewDatabase 
#Write-Host $ENV:dacpacPattern, $ENV:dacpacPath, $ENV:server, $ENV:dbName, $ENV:userId, $ENV:password, $ENV:blockOnPossibleDataLoss, $ENV:verifyDeployment, $ENV:compareUsingTargetCollation, $ENV:allowIncompatiblePlatform, $ENV:commandTimeout, $ENV:createNewDatabase

if ([string]::IsNullOrEmpty($ENV:databases))
{
    Write-Error "Not found database name in Environment";
    return;
}

Write-Host ('View all database name: ' + $ENV:databases);
$allDatabases = GetDatabaseList ('"'+ $env:databases +'"') ;

Write-Host ('Find by  files: ' + $ENV:dacpacPattern + ' in path ' + $env:dacpacpath);
$dacPack = GetDacPackage ('"'+$ENV:dacpacPattern +'"')  ('"'+$env:dacpacpath +'"')  ;


$option = CreateDacDeployOptions($env:blockOnPossibleDataLoss, $env:verifyDeployment, $env:compareUsingTargetCollation , $env:allowIncompatiblePlatform, $env:commandTimeout, $env:createNewDatabase) ;
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

#DeployDb($ENV:dacpacPattern, '/dacpacfiles', $ENV:server, $ENV:dbName, $ENV:userId, $ENV:password, $ENV:blockOnPossibleDataLoss, $ENV:verifyDeployment, $ENV:compareUsingTargetCollation , $ENV:allowIncompatiblePlatform, $ENV:commandTimeout, $ENV:createNewDatabase);


 