[EN-US](readme.md)

# **O que é?**

O SQLServer deploy  é um conjunto de scripts capazes de executar a publicação da estrutura do seu banco de dados (MS SQL Server) com base no .dacpac selecionado.

# **Como funciona?**

O script executado pesquisa por um arquivo que corresponde ao pattern digitado, connecta ao banco de dados utilizando a connection string, instancia uma classe, do pacote SDDT, configura a execução da publicação e executa o deploy.


![alt text](images/screenshot_1.png "Scheenshot")


## **Requisitos:**
Para essa tarefa funcionar o servidor de execução "Agent" deve ter instalado o SQL Server Data Tools no diretorio C:\Program Files (x86)\Microsoft SQL Server\120\DAC\bin\Microsoft.SqlServer.Dac.dll

[Link para download](https://docs.microsoft.com/pt-br/sql/ssdt/download-sql-server-data-tools-ssdt)

## **Como colaborar?**
  
[![logo](https://ms-vsts.gallerycdn.vsassets.io/extensions/ms-vsts/services-github/1.0.5/1479220457210/Microsoft.VisualStudio.Services.Icons.Branding)](https://github.com/GustavoAmerico/SQLServerDeploy)

