[CmdletBinding(DefaultParameterSetName = 'None')]
param(

    [String] [Parameter(Mandatory = $true)]
    $dacpacPattern,

    [String] [Parameter(Mandatory = $true)]
    $dacpacPath,

    [String] [Parameter(Mandatory = $true)]
    $connectionString,

    [String] [Parameter(Mandatory = $true)]
    $dbName,

    [bool] [Parameter(Mandatory = $false)]
    $blockOnPossibleDataLoss = $false,

    [bool] [Parameter(Mandatory = $false)]
    $verifyDeployment = $true,

    [bool] [Parameter(Mandatory = $false)]
    $compareUsingTargetCollation = $true,

    [bool] [Parameter(Mandatory = $false)]
    $allowIncompatiblePlatform = $true
)
if(![System.IO.Directory]::Exists($dacpacPath)){
    Write-Host "Não foi encontrado um diretorio:" $dacpacPath;
    return;
}

$fileName = $dacpacPath + "\" + $dacpacPattern 
Write-Host "Tentando encontrar o arquivo:" $fileName
try {
 
    $file = Get-ChildItem $fileName -Recurse  
    if ($file.Length = 0) {
        Write-Host "Não foi encontrado nenhum arquivo"
        return;
    }   
}
catch {
    Write-Host "Ocorreu um erro ao carregar os arquivos";
    return;
}

Write-Host "Arquivo encontrado: " $file
$dp = [Microsoft.SqlServer.Dac.DacPackage]::Load($file);
Write-Host "Conseguiu carregar o dacpac"
$dacService = new-object Microsoft.SqlServer.Dac.DacServices($connectionString);
Write-Host "Conseguiu se conectar ao servidor"
$option = new-object Microsoft.SqlServer.Dac.DacDeployOptions 
$option.BlockOnPossibleDataLoss = $blockOnPossibleDataLoss;
$option.CompareUsingTargetCollation = $compareUsingTargetCollation;
$option.AllowIncompatiblePlatform = $allowIncompatiblePlatform;
$option.VerifyDeployment = $verifyDeployment;
$dacService.Deploy($dp, $dbName, "True", $option);
Write-Host "Concluiu o deploy"
