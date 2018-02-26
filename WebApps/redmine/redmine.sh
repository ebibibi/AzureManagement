az group create --name redmine --location "Japan West"

az mysql server create --name ebimysql --resource-group redmine --location "Japan West" --admin-user adminuser --admin-password P@ssw0rd
az mysql server firewall-rule create --name allIPs --server ebimysql --resource-group redmine --start-ip-address 0.0.0.0 --end-ip-address 255.255.255.255
az mysql server update --resource-group redmine --name ebimysql --ssl-enforcement Disabled


mysql -u adminuser@ebimysql -h ebimysql.mysql.database.azure.com -P 3306 -p
CREATE DATABASE redmine CHARACTER SET utf8;
CREATE USER 'redmineuser' IDENTIFIED BY 'P@ssw0rd'; 
GRANT ALL PRIVILEGES ON redmine.* TO 'redmineuser';
FLUSH PRIVILEGES;
quit


az webapp deployment user set --user-name ebibibi --password P@ssw0rd
az appservice plan create --name myAppServicePlane --resource-group redmine --sku S1 --is-linux
az webapp create --resource-group redmine --plan myAppServicePlane --name ebiredmine --deployment-container-image-name redmine

az webapp config appsettings set --name ebiredmine --resource-group redmine --settings REDMINE_DB_MYSQL="ebimysql.mysql.database.azure.com" REDMINE_DB_USERNAME="redmineuser@ebimysql" REDMINE_DB_PASSWORD="P@ssw0rd"

