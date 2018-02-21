az webapp deployment user set --user-name ebibibi --password P@ssw0rd
az group create --name deletableRedmineTest --location "Japan East"
az appservice plan create --name myAppServicePlane --resource-group deletableRedmineTest --sku S1 --is-linux
az webapp create --resource-group deletableRedmineTest --plan myAppServicePlane --name redminetest --deployment-container-image-name redmine
