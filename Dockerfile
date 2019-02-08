#It’s based from Microsoft’s Windows Server Core image, and the Dockerfile uses a SHELL instruction to switch to PowerShell in the RUN instructions:
#Autor: Gustavo Américo Gonçalves
#Email: contato@gustavoamerico.net

FROM microsoft/dotnet-framework:4.7.2-sdk-windowsservercore-1803  
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

WORKDIR /src
COPY 'AzureDevOps\\SQLServerDeploy\\Tasks\\MSSQLPack' '.'
WORKDIR /ProjectPath/
ENTRYPOINT [ "powershell" ,  "/src/command.ps1",  "*.sqlproj",  "'/output'" ]
