@description('Região onde os recursos serão criados.')
param location string = resourceGroup().location

@description('Nome da Web App.')
param webAppName string = 'MoongyWebApp'

@description('Nome do App Service Plan.')
param appServicePlanName string = '${webAppName}-plan'

@description('Nome do SQL Server (precisa ser globalmente único no Azure).')
param sqlServerName string = toLower('${webAppName}-sql-${uniqueString(resourceGroup().id)}')

@description('Nome do banco de dados.')
param sqlDatabaseName string = '${webAppName}-db'

@description('Login do admin do SQL Server.')
param sqlAdminLogin string

@description('Senha do admin do SQL Server.')
@secure()
param sqlAdminPassword string

@description('Nome do Application Insights.')
param appInsightsName string = '${webAppName}-ai'

@description('Nome do Log Analytics Workspace (recomendado para App Insights).')
param logAnalyticsName string = '${webAppName}-law'

// --------------------
// App Service Plan
// --------------------
resource plan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
    capacity: 1
  }
  properties: {
    reserved: false // Windows. (Se quiser Linux, me avisa que eu ajusto)
  }
}

// --------------------
// Log Analytics (para Application Insights workspace-based)
// --------------------
resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// --------------------
// Application Insights
// --------------------
resource ai 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: law.id
  }
}

// --------------------
// SQL Server + Database
// --------------------
resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
    publicNetworkAccess: 'Enabled'
    minimalTlsVersion: '1.2'
  }
}

// Regra de firewall simples para permitir serviços Azure acessarem o SQL.
// (Para dev/demo funciona bem; para produção você provavelmente vai querer Private Endpoint ou regras específicas.)
resource allowAzureServices 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = {
  name: '${sqlServer.name}/AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource sqlDb 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  name: '${sqlServer.name}/${sqlDatabaseName}'
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
}

// --------------------
// Web App
// --------------------
resource web 'Microsoft.Web/sites@2023-12-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
    siteConfig: {
      appSettings: [
        // App Insights
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: ai.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
      ]
      connectionStrings: [
        {
          name: 'DefaultConnection'
          type: 'SQLAzure'
          value: 'Server=tcp:${sqlServerName}.database.windows.net,1433;Initial Catalog=${sqlDatabaseName};Persist Security Info=False;User ID=${sqlAdminLogin};Password=${sqlAdminPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
        }
      ]
    }
  }
}

// --------------------
// Outputs úteis
// --------------------
output webAppUrl string = 'https://${web.properties.defaultHostName}'
output sqlServerFqdn string = '${sqlServerName}.database.windows.net'
output appInsightsConnectionString string = ai.properties.ConnectionString
