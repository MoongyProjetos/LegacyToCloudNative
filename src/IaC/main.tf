terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.100.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# --------------------
# Inputs
# --------------------
variable "location" {
  type        = string
  description = "Região onde os recursos serão criados."
  default     = "westeurope"
}

variable "resource_group_name" {
  type        = string
  description = "Nome do Resource Group."
}

variable "web_app_name" {
  type        = string
  description = "Nome da Web App."
  default     = "MoongyWebApp"
}

variable "sql_admin_login" {
  type        = string
  description = "Login do admin do SQL Server."
}

variable "sql_admin_password" {
  type        = string
  description = "Senha do admin do SQL Server."
  sensitive   = true
}

# --------------------
# Resource Group
# --------------------
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Unique suffix for globally-unique SQL Server name
resource "random_string" "suffix" {
  length  = 8
  upper   = false
  lower   = true
  numeric = true
  special = false
}

locals {
  app_service_plan_name = "${var.web_app_name}-plan"
  log_analytics_name    = "${var.web_app_name}-law"
  app_insights_name     = "${var.web_app_name}-ai"
  sql_database_name     = "${var.web_app_name}-db"
  sql_server_name       = lower("${var.web_app_name}-sql-${random_string.suffix.result}")
}

# --------------------
# App Service Plan (Windows)
# --------------------
resource "azurerm_service_plan" "plan" {
  name                = local.app_service_plan_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  os_type  = "Windows"
  sku_name = "B1"
}

# --------------------
# Log Analytics Workspace
# --------------------
resource "azurerm_log_analytics_workspace" "law" {
  name                = local.log_analytics_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku               = "PerGB2018"
  retention_in_days = 30
}

# --------------------
# Application Insights (workspace-based)
# --------------------
resource "azurerm_application_insights" "ai" {
  name                = local.app_insights_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id
}

# --------------------
# SQL Server + Database
# --------------------
resource "azurerm_mssql_server" "sql" {
  name                = local.sql_server_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password

  minimum_tls_version          = "1.2"
  public_network_access_enabled = true
}

# Allow Azure services (0.0.0.0)
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_database" "db" {
  name      = local.sql_database_name
  server_id = azurerm_mssql_server.sql.id

  sku_name  = "Basic"
  collation = "SQL_Latin1_General_CP1_CI_AS"
}

# --------------------
# Web App (Windows)
# --------------------
resource "azurerm_windows_web_app" "web" {
  name                = var.web_app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azururerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  https_only = true

  site_config {
    always_on = false
  }

  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING"     = azurerm_application_insights.ai.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
  }

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Server=tcp:${azurerm_mssql_server.sql.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.db.name};Persist Security Info=False;User ID=${var.sql_admin_login};Password=${var.sql_admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
}

# --------------------
# Outputs úteis
# --------------------
output "web_app_url" {
  value = "https://${azurerm_windows_web_app.web.default_hostname}"
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.sql.fully_qualified_domain_name
}

output "app_insights_connection_string" {
  value     = azurerm_application_insights.ai.connection_string
  sensitive = true
}
