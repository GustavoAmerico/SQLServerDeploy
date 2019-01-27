# How use

## Use .NetCore tool for publish .dacpac file

### What's .dacpac
A data-tier application (DAC) is a logical database management entity that defines all SQL Server objects - such as tables, views, and instance objects - associated with a user's database. It is a self-contained unit of SQL Server database deployment that enables data-tier developers and DBAs to package SQL Server objects into a portable artifact called a DAC package, or .dacpac file. <sup>[See more](https://docs.microsoft.com/en-us/sql/relational-databases/data-tier-applications/data-tier-applications?view=sql-server-2017)</sup>

### Requirements

1. .NET Core 2.1+ runtime installed

### Publish .dacpac with .Net tool

####  Install the Dacpac.Tool package 

```powershell
 dotnet tool install --global Dacpac.Tool
```

#### Run tool only with the required parameters

 1. Use case   
 Multi tenant database, your have same schema for multiple client on database server

* Windows autentication (SSPI)
```powershell

dotnet dacpac publish --dacpath=C:\artifact\db\ --server=mydatabase.server.contoso.com --databasenames='client1;client2;client3;client4'
```
* Specific User authentication 

```powershell
dotnet dacpac publish --dacpath=C:\artifact\db\ --server=mydatabase.server.contoso.com --databasenames='client1;client2;client3;client4' --userId=useWithPersmissionForUpdate --password=123455

```

* Parameters    

|Name|Description|Default|
|-------|-------|-----|
|dacpath| Directory where the dacpac file is stored| Directory that the tool is running|
|databasenames | The names of databases that need to be updated|It's requerid not have default|
|namenattern|Pattern for search file|*.dacpac|
|UseSspi|Indicates that the windows user should be used|true
|userId|Database user <sub>Need permissions for schema change</sub>|carioca|
|password| The password from 'userid' | IFromBrazilian|

[See all parameters](https://docs.microsoft.com/en-us/dotnet/api/microsoft.sqlserver.dac.dacdeployoptions?redirectedfrom=MSDN&view=sql-dacfx-140.3881.1)





