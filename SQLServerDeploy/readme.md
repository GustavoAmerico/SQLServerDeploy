<!-- [PT-BR](readme.md) -->
# **What is?**

The SQLServer Deploy is a set of scripts that are able to perform the publication of the structure of your database (MS SQL Server) based on the selected .dacpac file.

# **How it works?**

The executed script searches for a file that matches the pattern entered, connects to the database using the connection string, instantiates a class, from the SDDT package, configures the execution of the publication, and executes deploy.

You need change the file name pattern for select one unique file, case your path has multiple.

## Deploy one database by task
![alt text](./images/screenshot_1.png "Scheenshot")

## Deploy multiple database by task on same server
![alt text](https://raw.githubusercontent.com/GustavoAmerico/SQLServerDeploy/master/SQLServerDeploy/images/screenshot_2.png "Scheenshot")




# **Requirements:**
For this task to run the "Agent" running server must have installed SQL Server Data Tools in the directory C:\Program Files (x86)\Microsoft SQL Server\120+\DAC\bin\Microsoft.SqlServer.Dac.dll

[Link para download](https://docs.microsoft.com/pt-br/sql/ssdt/download-sql-server-data-tools-ssdt)


## **To collaborate:**
  
[![logo](https://ms-vsts.gallerycdn.vsassets.io/extensions/ms-vsts/services-github/1.0.5/1479220457210/Microsoft.VisualStudio.Services.Icons.Branding)](https://github.com/GustavoAmerico/SQLServerDeploy)