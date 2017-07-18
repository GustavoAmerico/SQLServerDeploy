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
    $commandTimeout = 7200
)
 add-type -path "C:\Program Files (x86)\Microsoft SQL Server\110\DAC\bin\Microsoft.SqlServer.Dac.dll"
if (![System.IO.Directory]::Exists($dacpacPath)) {
    Write-Host "Não foi encontrado um diretorio:" $dacpacPath;
    return;
}

$fileName = ($dacpacPath + "\" + $dacpacPattern).Trim(); 
Write-Host "Tentando encontrar o arquivo:" $fileName
try {
 
    $file = Get-ChildItem $fileName -Recurse  
    if ($file.Length -eq 0) {
        Throw "Não foi encontrado nenhum arquivo"
    }
    else {
        Write-Host "Arquivo encontrado: " $file
    }
}
catch {
    Write-Host "Ocorreu um erro ao carregar os arquivos";
    Throw;
}
 
  
#Load Microsoft.SqlServer.Dac assembly
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Dac")

Write-Host "Iniciando o deploy"
$dp = [Microsoft.SqlServer.Dac.DacPackage]::Load($file);
Write-Host "Conseguiu carregar o dacpac"
$dacService = new-object Microsoft.SqlServer.Dac.DacServices($connectionString);
Write-Host "Conseguiu se conectar ao servidor" 

Write-Host "Preparando as variaveis de publicação"
Write-Host "BlockOnPossibleDataLoss: " $blockOnPossibleDataLoss
Write-Host "CompareUsingTargetCollation: " $compareUsingTargetCollation
Write-Host "AllowIncompatiblePlatform: " $allowIncompatiblePlatform
Write-Host "VerifyDeployment: " $verifyDeployment

$option = new-object Microsoft.SqlServer.Dac.DacDeployOptions 

$option.BlockOnPossibleDataLoss = [System.Convert]::ToBoolean($blockOnPossibleDataLoss.Trim());
$option.CompareUsingTargetCollation = [System.Convert]::ToBoolean( $compareUsingTargetCollation.Trim());
$option.AllowIncompatiblePlatform = [System.Convert]::ToBoolean( $allowIncompatiblePlatform.Trim());
$option.VerifyDeployment = [System.Convert]::ToBoolean($verifyDeployment.Trim());
$option.CommandTimeout = [System.Convert]::ToInt32($commandTimeout);

$dacService.Deploy($dp, $dbName, "True", $option)
Write-Host "Concluiu o deploy"

Write-Host "Terminando a execução"


