#It’s based from Microsoft’s Windows Server Core image, and the Dockerfile uses a SHELL instruction to switch to PowerShell in the RUN instructions:
#Autor: Gustavo Américo Gonçalves
#Email: contato@gustavoamerico.net

FROM microsoft/dotnet-framework:4.7.2-sdk as base
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]


#The Dockerfile goes on to install all the tools needed to build SSDT projects. The majority of the tools are available as Chocolatey packages, so in the Dockerfile the RUN instruction installs Chocolatey, the MSBuild tools, and the .NET 4.7.2 target package
RUN Write-Host 'Installing chocolatey package management';
RUN Install-PackageProvider -Name chocolatey -RequiredVersion 2.8.5.130 -Force; 

RUN Write-Host 'Installing SQL Server Data Tools';
RUN Install-Package -Name microsoft-build-tools -RequiredVersion 15.0.26320.2 -Force; 

RUN Write-Host 'Installing Nuget CLI';
RUN Install-Package nuget.commandline -RequiredVersion 4.9.2 -Force;

#At this point the Docker image will have all the tools to build basic .NET projects, but for SSDT you also need to install Microsoft.Data.Tools.Msbuild, which comes as a NuGet package:
RUN Write-Host 'Installing SQL Server Data Tools from nuget'
RUN C:\Chocolatey\bin\nuget install Microsoft.Data.Tools.Msbuild -Version 10.0.61804.210

#Finally the Dockerfile adds the build tools to the path, so users of the image can run msbuild without specifying a full path:
ENV MSBUILD_PATH="C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\BuildTools\\MSBuild\\15.0\\Bin"
RUN $env:PATH = $env:MSBUILD_PATH + ';' + $env:PATH; 
RUN [Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine);
COPY 'AzureDevOps\\SQLServerDeploy\\Tasks\\MSSQLDeployMultpleDeploy' '/help'

#RUN   . /help/functions-help.ps1; TryResgisterSqlServerDac

FROM base as package
WORKDIR /src
COPY 'AzureDevOps\\SQLServerDeploy\\Tasks\\MSSQLPack' '.'
WORKDIR /ProjectPath/
ENTRYPOINT [ "powershell" ,  "/src/command.ps1",  "*.sqlproj",  "'/output'" ]


FROM base as deploy
RUN mkdir '/dacpacfiles'
WORKDIR /src
COPY 'AzureDevOps\\SQLServerDeploy\\Tasks\\MSSQLDeployMultpleDeploy' '.'
#RUN Intall-Package sql2017-dacframework
RUN [System.Environment]::SetEnvironmentVariable('dacpacPattern','**/*.dacpac',  [System.EnvironmentVariableTarget]::Machine),\

#The server domain name or IP and port ([database_domain_name or IP],[port])# <192.168.0.3,1433>
[System.Environment]::SetEnvironmentVariable('server', 'localhost',  [System.EnvironmentVariableTarget]::Machine), \

#The sql server user with grant access for create/alter schema
[System.Environment]::SetEnvironmentVariable('userId','sa', [System.EnvironmentVariableTarget]::Machine), \
#SQL User Password
[System.Environment]::SetEnvironmentVariable('password','123', [System.EnvironmentVariableTarget]::Machine), \

#The database name for publish package. multiple databases have separated #by (;)
[System.Environment]::SetEnvironmentVariable('databases','newdb', [System.EnvironmentVariableTarget]::Machine), \

#specifies whether the plan verification phase is executed or not.
[System.Environment]::SetEnvironmentVariable('verifyDeployment','true' ,[System.EnvironmentVariableTarget]::Machine), \

#specifies whether the source collation will be used for identifier #comparison.
[System.Environment]::SetEnvironmentVariable('compareUsingTargetCollation','true',[System.EnvironmentVariableTarget]::Machine) , \ 

#specifies whether deployment will block due to platform compatibility.
[System.Environment]::SetEnvironmentVariable('allowIncompatiblePlatform','true',[System.EnvironmentVariableTarget]::Machine), \

#Specifies whether the existing database will be dropped and a new database created before proceeding with the actual deployment actions. Acquires single-user mode before dropping the existing database.(Not Recomend for production)
[System.Environment]::SetEnvironmentVariable('createNewDatabase','false', [System.EnvironmentVariableTarget]::Machine),\

#Time for connection wait publish
[System.Environment]::SetEnvironmentVariable('commandTimeout',17200,[System.EnvironmentVariableTarget]::Machine), \ 
#"specifies whether deployment should stop if the operation could cause #data loss."
[System.Environment]::SetEnvironmentVariable('blockOnPossibleDataLoss','true', [System.EnvironmentVariableTarget]::Machine), \
[System.Environment]::SetEnvironmentVariable('dacpacpath','C:\\dacpacfiles', [System.EnvironmentVariableTarget]::Machine), \
[System.Environment]::SetEnvironmentVariable('UseWindowsAuthentication', 'false', [System.EnvironmentVariableTarget]::Machine) ;

ENTRYPOINT powershell C:\src\command-docker.ps1

#    -server=$ENV:server -dbName=$ENV:databases -userId=$ENV:userId -password=$ENV:password -blockOnPossibleDataLoss=$ENV:blockOnPossibleDataLoss -verifyDeployment=$ENV:verifyDeployment -compareUsingTargetCollation=$ENV:compareUsingTargetCollation -allowIncompatiblePlatform=$ENV:allowIncompatiblePlatform -commandTimeout=$ENV:commandTimeout -createNewDatabase=$ENV:createNewDatabase  

#A connection string gerada vai ter o formato:
#Server=tcp:{0};Initial Catalog={3};Persist Security Info=False;User ID={1};Password={2};MultipleActiveResultSets=True;Encrypt=True; 

# Server=tcp:localhost;Initial Catalog=teste;Persist Security Info=False;User ID={1};Password={2};MultipleActiveResultSets=True;Encrypt=True; 
#docker run -v 'D:\Gustavo\SourceCode\Intcom\BlueOpexDatabase\src\:C:\ProjectPath' -v 'C:\temp\:C:\output'   sqlservertool:4.7.2

# docker build -f .\Dockerfile -t sqlservertool:4.7.2 .



#docker build --rm -f ..\..\..\Dockerfile --target deploy -t sqlserver-deploy ..\..\..\; 
#docker run -e 'password="123456667"'`  --rm  -v 'C:\temp:C:\dacpacfiles' sqlserver-deploy:latest