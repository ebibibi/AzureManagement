resource "azurerm_resource_group" "GitLabCE" {
  name     = "GitLabCE"
  location = "Japan East"
}

resource "azurerm_app_service_plan" "AppservicePlan" {
  name                = "appserviceplan"
  location            = "${azurerm_resource_group.GitLabCE.location}"
  resource_group_name = "${azurerm_resource_group.GitLabCE.name}"
  kind                = "Linux"

  sku {
    tier = "Standard"
    size = "S1"
  }

  properties {
    reserved = true
  }
}

resource "azurerm_postgresql_server" "postgresql" {
  name                = "postgresqlforgitlab"
  location            = "${azurerm_resource_group.GitLabCE.location}"
  resource_group_name = "${azurerm_resource_group.GitLabCE.name}"

  sku {
    name     = "B_Gen5_1"
    capacity = 1
    tier     = "Basic"
    family   = "Gen5"
  }

  storage_profile {
    storage_mb            = 5120
    backup_retention_days = 7
    geo_redundant_backup  = "Disabled"
  }

  administrator_login          = "psqladmin"
  administrator_login_password = "${var.password}"
  version                      = "9.5"
  ssl_enforcement              = "Enabled"
}

resource "azurerm_template_deployment" "appservice" {
  name                = "appservice"
  resource_group_name = "${azurerm_resource_group.GitLabCE.name}"

  template_body = <<DEPLOY
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "app_service_plan_id": {
      "type": "string",
      "metadata": {
        "description": "App Service Plan ID"
      }
    },
    "name": {
      "type": "string",
      "metadata": {
        "description": "App Name"
      }
    },
    "image": {
      "type": "string",
      "metadata": {
        "description": "Docker image"
      }
    },
    "gitlab_database_host": {
      "type": "string",
      "metadata": {
        "description": "gitlab_database_host"
      }
    },
    "gitlab_database_username": {
      "type": "string",
      "metadata": {
        "description": "gitlab_database_username"
      }
    },
    "gitlab_database_password": {
      "type": "string",
      "metadata": {
        "description": "gitlab_database_password"
      }
    },
    "gitlab_host": {
      "type": "string",
      "metadata": {
        "description": "gitlab_host"
      }
    },
    "gitlab_database_adapter": {
      "type": "string",
      "metadata": {
        "description": "gitlab_database_adapter"
      }
    },
    "gitlab_database_port": {
      "type": "string",
      "metadata": {
        "description": "gitlab_database_port"
      }
    },
    "gitlab_database_database": {
      "type": "string",
      "metadata": {
        "description": "gitlab_database_database"
      }
    },

    "gitlab_database_encoding": {
      "type": "string",
      "metadata": {
        "description": "gitlab_database_encoding"
      }
    }
  },
  "resources": [
    {
      "apiVersion": "2016-08-01",
      "kind": "app,linux,container",
      "name": "[parameters('name')]",
      "type": "Microsoft.Web/sites",
      "properties": {
        "name": "[parameters('name')]",
        "siteConfig": {
          "alwaysOn": true,
          "appSettings": [
            {
              "name": "WEBSITES_ENABLE_APP_SERVICE_STORAGE",
              "value": "true"
            },
            {
              "name": "GITLAB_HOST",
              "value": "[parameters('gitlab_host')]"
            },
            {
              "name": "GITLAB_DATABASE_ADAPTER",
              "value": "[parameters('gitlab_database_adapter')]"
            },
            {
              "name": "GITLAB_DATABASE_HOST",
              "value": "[parameters('gitlab_database_host')]"
            },
            {
              "name": "GITLAB_DATABASE_DATABASE",
              "value": "[parameters('gitlab_database_database')]"
            },
            {
              "name": "GITLAB_DATABASE_USERNAME",
              "value": "[parameters('gitlab_database_username')]"
            },
            {
              "name": "GITLAB_DATABASE_PASSWORD",
              "value": "[parameters('gitlab_database_password')]"
            },
            {
              "name": "GITLAB_DATABASE_PORT",
              "value": "[parameters('gitlab_database_port')]"
            },
            {
              "name": "GITLAB_DATABASE_ENCODING",
              "value": "[parameters('gitlab_database_encoding')]"
            }
          ],
          "linuxFxVersion": "[concat('DOCKER|', parameters('image'))]"
        },
        "serverFarmId": "[parameters('app_service_plan_id')]"
      },
      "location": "[resourceGroup().location]"
    }
  ]
}
DEPLOY

  parameters {
    name                     = "jbsgitlabce"
    image                    = "ebibibi/appservice-gitlab-ce"
    app_service_plan_id      = "${azurerm_app_service_plan.AppservicePlan.id}"
    gitlab_host              = "http://jbsgitlabce.azurewebsites.net"
    gitlab_database_adapter  = "postgresql"
    gitlab_database_host     = "${azurerm_postgresql_server.postgresql.name}"
    gitlab_database_database = "gitlab"
    gitlab_database_username = "psqladmin"
    gitlab_database_password = "${var.password}"
    gitlab_database_port     = "5432"
    gitlab_database_encoding = "utf8"
  }

  deployment_mode = "Incremental"
}
