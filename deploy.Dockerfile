FROM microsoft/dotnet:2.2-sdk
VOLUME [ "/dacpacfiles" ]
WORKDIR /dacpacfiles
 
#ENV DOTNET_CLI_HOME=/var/cache

#RUN Intall-Package sql2017-dacframework
ENV dacpacPattern="*.dacpac" 

#The server domain name or IP and port ([database_domain_name or IP],[port])# <192.168.0.3,1433>
ENV server=localhost 

#The sql server user with grant access for create/alter schema
ENV userId=sa 
#SQL User Password
ENV password=123 

#The database name for publish package. multiple databases have separated #by (;)
ENV databases=newdb           

#specifies whether the plan verification phase is executed or not.
ENV verifyDeployment=true 

#specifies whether the source collation will be used for identifier #comparison.
ENV compareUsingTargetCollation=true 

#specifies whether deployment will block due to platform compatibility.
ENV allowIncompatiblePlatform=true 

#Specifies whether the existing database will be dropped and a new database created before proceeding with the actual deployment actions. Acquires single-user mode before dropping the existing database.(Not Recomend for production)
ENV createNewDatabase=false

#Time for connection wait publish
ENV commandTimeout=17200
#"specifies whether deployment should stop if the operation could cause #data loss."
ENV blockOnPossibleDataLoss=true
ENV dacpacpath=/dacpacfiles 
ENV UseWindowsAuthentication=false

RUN dotnet tool install --global Dacpac.Tool
ENV PATH="${PATH}:/root/.dotnet/tools"

ENTRYPOINT dotnet dacpac publish --path=$dacpacPath --namePattern=$dacpacPattern --server=$server --databaseNames=$dbName --userId=$userId --password=$password --blockOnPossibleDataLoss=$blockOnPossibleDataLoss --verifyDeployment=$verifyDeployment --compareUsingTargetCollation=$compareUsingTargetCollation --allowIncompatiblePlatform=$allowIncompatiblePlatform --commandTimeout=$commandTimeout --createNewDatabase=$createNewDatabase

#    -server=$ENV:server -dbName=$ENV:databases -userId=$ENV:userId -password=$ENV:password -blockOnPossibleDataLoss=$ENV:blockOnPossibleDataLoss -verifyDeployment=$ENV:verifyDeployment -compareUsingTargetCollation=$ENV:compareUsingTargetCollation -allowIncompatiblePlatform=$ENV:allowIncompatiblePlatform -commandTimeout=$ENV:commandTimeout -createNewDatabase=$ENV:createNewDatabase  

#A connection string gerada vai ter o formato:
#Server=tcp:{0};Initial Catalog={3};Persist Security Info=False;User ID={1};Password={2};MultipleActiveResultSets=True;Encrypt=True; 

# Server=tcp:localhost;Initial Catalog=teste;Persist Security Info=False;User ID={1};Password={2};MultipleActiveResultSets=True;Encrypt=True; 
#docker run -v 'D:\Gustavo\SourceCode\Intcom\BlueOpexDatabase\src\:C:\ProjectPath' -v 'C:\temp\:C:\output'   sqlservertool:4.7.2

# docker build -f .\Dockerfile -t sqlservertool:4.7.2 .



#docker build --rm -f ..\..\..\Dockerfile --target deploy -t sqlserver-deploy ..\..\..\; 
#docker run -e 'password="123456667"'`  --rm  -v 'C:\temp:C:\dacpacfiles' sqlserver-deploy:latest