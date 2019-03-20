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
 
. ..\Install-Dotnet-Core.ps1
 
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
