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
 
. C:\src\functions-help.ps1

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Dac")
 
Write-Host ("Find by file: $dacpacPattern")
Write-Host ("Publish on Server: $server")
Write-Host ("On databases: $dbName")
  

DeployDb($dacpacPattern, $dacpacPath, $server, $dbName, $userId, $password, $blockOnPossibleDataLoss, $verifyDeployment, $compareUsingTargetCollation , $allowIncompatiblePlatform, $commandTimeout, $createNewDatabase);


 