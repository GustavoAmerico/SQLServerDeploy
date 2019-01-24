. C:\src\functions-help.ps1

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Dac");
  
#'/dacpacfiles' %server% %databases% %userId% $ENV:server $ENV:databases $ENV:userId $ENV:password $ENV:blockOnPossibleDataLoss $ENV:verifyDeployment $ENV:compareUsingTargetCollation $ENV:allowIncompatiblePlatform $ENV:commandTimeout $ENV:createNewDatabase 
#Write-Host $ENV:dacpacPattern, $ENV:dacpacPath, $ENV:server, $ENV:dbName, $ENV:userId, $ENV:password, $ENV:blockOnPossibleDataLoss, $ENV:verifyDeployment, $ENV:compareUsingTargetCollation, $ENV:allowIncompatiblePlatform, $ENV:commandTimeout, $ENV:createNewDatabase

function GetConnectString(){
    param([System.String]$database)
    $server = $env:server.Trim();
    
            #$connectionString = [System.String]::Format("Server={0};Initial Catalog={3};Persist Security Info=False;User ID={1};Password={2};MultipleActiveResultSets=True;", $server.Trim(), $ENV:userId, $ENV:password, $database.Trim());

     Write-Host ("Start process file on $database");

     if (-not $env:UseWindowsAuthentication) {
        $connectionString ="Data Source=$server;User Id=$ENV:userId;Password=$ENV:password;Integrated Security=False;Provider=SQLOLEDB.1;Application Name=SqlPackageUpdate";
        # 
        #$authentication = "SQL ($ENV:userId)"
    }
    else {
        $connectionString = "Integrated Security=SSPI;Persist Security Info=False;Data Source=$server;Application Name=SqlPackageUpdate" ;
        # "Data Source=$server;Integrated Security=True;";
        #$authentication = "Windows ($env:USERNAME)"
    }
    return $connectionString;
    #' C:\Arquivos de Programas (x86)\Microsoft SQL Server\'
}

if ([string]::IsNullOrEmpty($ENV:databases)) {
    Write-Error "Not found database name in Environment";
    return;
}

Write-Host ('Find by  files: ' + $ENV:dacpacPattern + ' in path ' + $env:dacpacpath);
$dacPack = GetDacPackage  $ENV:dacpacPattern  $env:dacpacpath  ;

if (-not $dacPack) {
    Write-Error 'Not found the file dacpac for publish database schema';
    return;
}
else {

    $option = CreateDacDeployOptions $env:blockOnPossibleDataLoss $env:verifyDeployment $env:compareUsingTargetCollation $env:allowIncompatiblePlatform $env:commandTimeout $env:createNewDatabase ;
    Write-Host ('View all database name: ' + $ENV:databases);
    $allDatabases = GetDatabaseList $env:databases ;

    foreach ($database in $allDatabases) {
        
        try {        
            $connectionString = GetConnectString $database;
            Write-Host "Try deploy in $database";
            Write-Host $connectionString;      
            $dacService = new-object Microsoft.SqlServer.Dac.DacServices $connectionString;
            if (-not $dacService ) {
                Write-Error 'Microsoft.SqlServer.Dac.DacServices cannot be loaded';
            }
            else {                 
                $dacService.Deploy($dacPack[1], $database.Trim(), $True, $option[1]);    
            }        
            Write-Host "Finish Deploy to $database";
        } 
        # catch [Microsoft.Data.Tools.Schema.Sql.Deployment.DeploymentFailedException]{
        #     Write-Error $_.Exception;  
          
        #     break;
        # }
        catch {
         
            Write-Error $_.Exception;  
            Write-Host "Error Deploy to $database"
        }
    }
}
Write-Host "Finish deploy for all database"

#DeployDb($ENV:dacpacPattern, '/dacpacfiles', $ENV:server, $ENV:dbName, $ENV:userId, $ENV:password, $ENV:blockOnPossibleDataLoss, $ENV:verifyDeployment, $ENV:compareUsingTargetCollation , $ENV:allowIncompatiblePlatform, $ENV:commandTimeout, $ENV:createNewDatabase);


 