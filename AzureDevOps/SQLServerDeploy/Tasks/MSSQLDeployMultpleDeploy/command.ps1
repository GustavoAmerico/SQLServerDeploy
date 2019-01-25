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


. C:\src\functions-help.ps1  


DeployDb($dacpacPattern, $dacpacPath, $server, $dbName, $userId, $password, $blockOnPossibleDataLoss, $verifyDeployment, $compareUsingTargetCollation , $allowIncompatiblePlatform, $commandTimeout, $createNewDatabase)