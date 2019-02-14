
docker build --rm -f .\Dockerfile --target deploy -t sqlserver-deploy .; 
#docker run --rm  -e 'UseWindowsAuthentication="$False"' -e 'password="NJI90okm!"'  -v 'C:\temp:C:\dacpacfiles' sqlserver-deploy:latest
docker run -e 'password="1234567890"' -e 'server="GAMERICO\SQLEXPRESS"' -e 'UseWindowsAuthentication="$True"'  --rm  -v 'C:\temp:C:\dacpacfiles' sqlserver-deploy:latest