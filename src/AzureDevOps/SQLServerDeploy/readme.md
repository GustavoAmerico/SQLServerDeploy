![Badge](https://opensource-gag.vsrm.visualstudio.com/_apis/public/Release/badge/d3f0baad-0ba9-4d85-8676-a331fd4094cb/2/2)

[![Build Status](https://opensource-gag.visualstudio.com/Visual%20Studio%20Marketplace/_apis/build/status/SQL%20Server%20Dacpac%20Tool%20-%20Continuous%20Delivery?branchName=master)](https://opensource-gag.visualstudio.com/Visual%20Studio%20Marketplace/_build/latest?definitionId=6&branchName=master)

[PT-BR](./src/AzureDevOps/SQLServerDeploy/readme-pt-br.md)
# **What is?**

The Dacpac Tool is a set of scripts that are able to perform the publication of the structure of your database (MS SQL Server) based on the selected .dacpac file.

# **How it works?**

The executed script searches for a file that matches the pattern entered, connects to the database using the connection string, instantiates a class, from the SDDT package, configures the execution of the publication, and executes deploy.

## Deploy  database on same server
![alt text](https://raw.githubusercontent.com/GustavoAmerico/SQLServerDeploy/master/AzureDevOps/SQLServerDeploy/images/screenshot_2.png "Scheenshot")


# **Requirements:**

## publish a dacpac on database
This task will install all requirements automatically

1. .Net Core 2.100+
2. .[Net Core Tool](./docs/How-use.md) - [Dacpac.Tool](https://www.nuget.org/packages/Dacpac.Tool/)

## Generate .dacpac from .sqlproj
For this task to run the "Agent" running server must have installed SQL Server Data Tools in the directory C:\Program Files (x86)\Microsoft SQL Server\120\DAC\bin\Microsoft.SqlServer.Dac.dll

[Link para download](https://docs.microsoft.com/pt-br/sql/ssdt/download-sql-server-data-tools-ssdt)
 

## **To collaborate:**
  
[![logo](https://ms-vsts.gallerycdn.vsassets.io/extensions/ms-vsts/services-github/1.0.5/1479220457210/Microsoft.VisualStudio.Services.Icons.Branding)](https://github.com/GustavoAmerico/SQLServerDeploy)

 
[Help me continue with coding](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=GAAV5TY5P8AJL&source=url)