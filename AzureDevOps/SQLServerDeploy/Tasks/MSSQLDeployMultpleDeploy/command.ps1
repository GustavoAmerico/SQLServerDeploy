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
 

. .\functions-help.ps1
InstallDotNetCore
dotnet tool install --global Dacpac.Tool

dotnet dacpac publish --path=$dacpacPath --namePattern=$dacpacPattern --server=$server --databaseNames=$dbName --userId=$userId --password=$password --blockOnPossibleDataLoss=$blockOnPossibleDataLoss --verifyDeployment=$verifyDeployment --compareUsingTargetCollation=$compareUsingTargetCollation --allowIncompatiblePlatform=$allowIncompatiblePlatform --commandTimeout=$commandTimeout --createNewDatabase=$createNewDatabase