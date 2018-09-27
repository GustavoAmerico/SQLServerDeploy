[CmdletBinding(DefaultParameterSetName = 'None')]
param(

    [String] [Parameter(Mandatory = $True)]
    $dacpacPattern,

    [String] [Parameter(Mandatory = $True)]
    $dacpacPath,

    [String] [Parameter(Mandatory = $True)]
    $connectionString,

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
    $createNewDatabase ="false"
)
 add-type -path "C:\Program Files (x86)\Microsoft SQL Server\120\DAC\bin\Microsoft.SqlServer.Dac.dll"

 
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
 
  
#Load Microsoft.SqlServer.Dac assembly
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Dac")

Write-Host "Start deploy"
$dp = [Microsoft.SqlServer.Dac.DacPackage]::Load($file);
Write-Host "Uploaded file"
$dacService = new-object Microsoft.SqlServer.Dac.DacServices($connectionString);
Write-Host "Connected to server" 

Write-Host "Preparing Publishing Variables"
$option = new-object Microsoft.SqlServer.Dac.DacDeployOptions 
$option.CommandTimeout = 7200; 
$option.BlockOnPossibleDataLoss = [System.Convert]::ToBoolean($blockOnPossibleDataLoss.Trim());
$option.CompareUsingTargetCollation = [System.Convert]::ToBoolean( $compareUsingTargetCollation.Trim());
$option.AllowIncompatiblePlatform = [System.Convert]::ToBoolean( $allowIncompatiblePlatform.Trim());
$option.VerifyDeployment = [System.Convert]::ToBoolean($verifyDeployment.Trim());
$option.CreateNewDatabase =  [System.Convert]::ToBoolean($createNewDatabase.Trim());
$option.CommandTimeout = [System.Convert]::ToInt32($commandTimeout);

Write-Host [System.String]::Format("CreateNewDatabase:{0}",$option.CreateNewDatabase);
Write-Host [System.String]::Format("CommandTimeout: {0}",$option.CommandTimeout);
Write-Host [System.String]::Format("BlockOnPossibleDataLoss:{0}",$option.BlockOnPossibleDataLoss);
Write-Host [System.String]::Format("AllowIncompatiblePlatform:{0}",$option.AllowIncompatiblePlatform);
Write-Host [System.String]::Format("CompareUsingTargetCollation:{0}",$option.CompareUsingTargetCollation);
Write-Host [System.String]::Format("VerifyDeployment:{0}",$option.VerifyDeployment);

 
$dacService.Deploy($dp, $dbName, "True", $option)
Write-Host "Finish Deploy"


