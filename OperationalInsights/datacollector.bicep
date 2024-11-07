
@description('Name of required log analytics resource')
param logAnalyticsName string

resource logs 'Microsoft.OperationalInsights/workspaces@2020-08-01' existing = {
  name: logAnalyticsName
}

resource dc 'Microsoft.SecurityInsights/dataConnectors@2023-02-01-preview' = {
  scope: logs
  name: 'MyTest'
  kind: 'RestApiPoller'
}

@description('Not used, but needed to pass arm-ttk test `Location-Should-Not-Be-Hardcoded`.  We instead use the `workspace-location` which is derived from the LA workspace')
@minLength(1)
param location string = resourceGroup().location

@description('Workspace name for Log Analytics where Microsoft Sentinel is setup')
param workspace string = ''

var _solutionName = 'OnePassword'
var _solutionVersion = '3.0.0'
var _solutionAuthor = 'Rogier Dijkman'
var _solutionPublisher = '1Password'
var _solutionTier = 'Community'
var solutionId = '1Password_Azurekid'
var _solutionId = solutionId
var dataConnectorVersionConnections = '1.0.0'
var _dataConnectorContentIdConnectorDefinition = '1Password-CodelessConnector'
var dataConnectorTemplateNameConnectorDefinition = 'contentTemplate-${uniqueString(_dataConnectorContentIdConnectorDefinition)}'
var _dataConnectorContentIdConnections = '1PasswordEvents'
var dataConnectorTemplateNameConnections = '${workspace}-dc-${uniqueString(_dataConnectorContentIdConnections)}'
var _solutioncontentProductId = '${take(_solutionId,50)}-sl-${uniqueString('${_solutionId}-Solution-${_solutionId}-${_solutionVersion}')}'

resource ct 'Microsoft.SecurityInsights/contentTemplates@2024-03-01' = {
  scope: logs
  name: '${dataConnectorTemplateNameConnectorDefinition}-v${dataConnectorVersionConnections}'
  properties: {
    mainTemplate: {
      resources: [

      ]
    }
  }
}

resource md 'Microsoft.SecurityInsights/metadata@2024-03-01' = {
  scope: logs
  name: 'metadata'
}

resource workspace_Microsoft_SecurityInsights_dataConnectorTemplateNameConnectorDefinition_v_dataConnectorVersionConnections 'Microsoft.OperationalInsights/workspaces/providers/contentTemplates@2023-04-01-preview' = {
  name: '${workspace}/Microsoft.SecurityInsights/${dataConnectorTemplateNameConnectorDefinition}-v${dataConnectorVersionConnections}'
  location: location
  properties: {
    contentId: _dataConnectorContentIdConnectorDefinition
    displayName: _dataConnectorContentIdConnectorDefinition
    contentKind: 'DataConnector'
    packageKind: 'Solution'
    packageVersion: _solutionVersion
    packageName: _solutionName
    contentProductId: '${take(_solutionId,50)}-dc-${uniqueString('${_solutionId}-DataConnector-${_dataConnectorContentIdConnectorDefinition}-${dataConnectorVersionConnections}')}'
    packageId: _solutionId
    contentSchemaVersion: '3.0.0'
    version: dataConnectorVersionConnections
    mainTemplate: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: dataConnectorVersionConnections
      parameters: {}
      variables: {}
      resources: [
        {
          name: '${workspace}/Microsoft.SecurityInsights/DataConnector-${_dataConnectorContentIdConnectorDefinition}'
          apiVersion: '2022-01-01-preview'
          type: 'Microsoft.OperationalInsights/workspaces/providers/metadata'
          properties: {
            parentId: extensionResourceId(
              resourceId('Microsoft.OperationalInsights/workspaces', workspace),
              'Microsoft.SecurityInsights/dataConnectorDefinitions',
              _dataConnectorContentIdConnectorDefinition
            )
            contentId: _dataConnectorContentIdConnectorDefinition
            kind: 'DataConnector'
            version: dataConnectorVersionConnections
            source: {
              sourceId: _solutionId
              name: _solutionName
              kind: 'Solution'
            }
            author: {
              name: _solutionAuthor
            }
            support: {
              name: _solutionAuthor
              tier: _solutionTier
            }
            dependencies: {
              criteria: [
                {
                  version: dataConnectorVersionConnections
                  contentId: _dataConnectorContentIdConnections
                  kind: 'ResourcesDataConnector'
                }
              ]
            }
          }
        }
        {
          type: 'Microsoft.Insights/dataCollectionRules'
          apiVersion: '2021-09-01-preview'
          name: '1Password'
          location: location
          properties: {
            dataCollectionEndpointId: '${resourceGroup().id}/providers/Microsoft.Insights/dataCollectionEndpoints/${workspace}'
            destinations: {
              logAnalytics: [
                {
                  workspaceResourceId: resourceId('Microsoft.OperationalInsights/workspaces', workspace)
                  name: workspace
                }
              ]
            }
            dataFlows: [
              {
                streams: [
                  'Custom-OnePasswordEventLogs_CL'
                ]
                destinations: [
                  workspace
                ]
                outputStream: 'Custom-OnePasswordEventLogs_CL'
                transformKql: 'source | extend TimeGenerated = now(), log_source = case(isnotempty(used_version) or isnotempty(aux_id), \'itemusages\', isnotempty(country), \'signinattempts\', isempty(used_version) and isempty(aux_id) and isempty(country), \'auditevents\', \'unknown\')'
              }
            ]
          }
        }
        {
          name: 'OnePasswordEventLogs_CL'
          apiVersion: '2022-10-01'
          type: 'Microsoft.OperationalInsights/workspaces/tables'
          location: location
          kind: null
          properties: {
            schema: {
              name: 'OnePasswordEventLogs_CL'
              columns: [
                {
                  name: 'SourceSystem'
                  type: 'string'
                }
                {
                  name: 'TimeGenerated'
                  type: 'datetime'
                }
                {
                  name: 'uuid_s'
                  type: 'string'
                }
                {
                  name: 'session_uuid'
                  type: 'string'
                }
                {
                  name: 'timestamp'
                  type: 'datetime'
                }
                {
                  name: 'country'
                  type: 'string'
                }
                {
                  name: 'category'
                  type: 'string'
                }
                {
                  name: 'action_type'
                  type: 'string'
                }
                {
                  name: 'details'
                  type: 'dynamic'
                }
                {
                  name: 'target_user'
                  type: 'dynamic'
                }
                {
                  name: 'client'
                  type: 'dynamic'
                }
                {
                  name: 'location'
                  type: 'dynamic'
                }
                {
                  name: 'actor_uuid'
                  type: 'string'
                }
                {
                  name: 'actor_details'
                  type: 'dynamic'
                }
                {
                  name: 'action'
                  type: 'string'
                }
                {
                  name: 'object_type'
                  type: 'string'
                }
                {
                  name: 'object_uuid'
                  type: 'string'
                }
                {
                  name: 'object_details'
                  type: 'dynamic'
                }
                {
                  name: 'aux_id'
                  type: 'int'
                }
                {
                  name: 'aux_uuid'
                  type: 'string'
                }
                {
                  name: 'aux_details'
                  type: 'dynamic'
                }
                {
                  name: 'aux_info'
                  type: 'string'
                }
                {
                  name: 'session'
                  type: 'dynamic'
                }
                {
                  name: 'used_version'
                  type: 'int'
                }
                {
                  name: 'vault_uuid'
                  type: 'string'
                }
                {
                  name: 'item_uuid'
                  type: 'string'
                }
                {
                  name: 'user'
                  type: 'dynamic'
                }
                {
                  name: 'log_source'
                  type: 'string'
                }
              ]
            }
          }
        }
      ]
    }
  }
  dependsOn: [
    extensionResourceId(
      resourceId('Microsoft.OperationalInsights/workspaces', workspace),
      'Microsoft.SecurityInsights/contentPackages',
      _solutionId
    )
  ]
}

resource workspace_Microsoft_SecurityInsights_dataConnectorContentIdConnectorDefinition 'Microsoft.OperationalInsights/workspaces/providers/dataConnectorDefinitions@2022-09-01-preview' = {
  name: '${workspace}/Microsoft.SecurityInsights/${_dataConnectorContentIdConnectorDefinition}'
  location: location
  kind: 'Customizable'
  properties: {
    connectorUiConfig: {
      id: _dataConnectorContentIdConnectorDefinition
      title: '1Password (Serverless)'
      publisher: _solutionPublisher
      descriptionMarkdown: 'The 1Password CCP connector allows the user to ingest 1Password Audit, Signin & ItemUsage events into Microsoft Sentinel.'
      graphQueriesTableName: 'OnePasswordEventLogs_CL'
      graphQueries: [
        {
          metricName: 'Total Sign In Attempts received'
          legend: 'SignIn Attempts'
          baseQuery: '{{graphQueriesTableName}} | where log_source == \'signinattempts\''
        }
        {
          metricName: 'Total Audit Events received'
          legend: 'Audit Events'
          baseQuery: '{{graphQueriesTableName}} | where log_source == \'auditevents\''
        }
        {
          metricName: 'Total Item Usage Events received'
          legend: 'Item Usage Events'
          baseQuery: '{{graphQueriesTableName}} | where log_source == \'itemusages\''
        }
      ]
      sampleQueries: [
        {
          description: 'Get Sample of 1Password events'
          query: '{{graphQueriesTableName}}\n | take 10'
        }
      ]
      dataTypes: [
        {
          name: 'OnePasswordEventLogs_CL'
          lastDataReceivedQuery: '{{graphQueriesTableName}}\n | where TimeGenerated > ago(7d) | summarize Time = max(TimeGenerated)\n | where isnotempty(Time)'
        }
      ]
      connectivityCriteria: [
        {
          type: 'HasDataConnectors'
        }
      ]
      availability: {
        isPreview: false
      }
      permissions: {
        resourceProvider: [
          {
            provider: 'Microsoft.OperationalInsights/workspaces'
            permissionsDisplayText: 'Read and Write permissions are required.'
            providerDisplayName: 'Workspace'
            scope: 'Workspace'
            requiredPermissions: {
              write: true
              read: true
              delete: true
            }
          }
        ]
        customs: [
          {
            name: '1Password API token'
            description: 'A 1Password API Token is required. See the [1Password documentation](https://support.1password.com/events-reporting/#appendix-issue-or-revoke-bearer-tokens) on how to create an API token.'
          }
        ]
      }
      instructionSteps: [
        {
          title: 'STEP 1 - Create a 1Password API token:'
          description: 'Follow the [1Password documentation](https://support.1password.com/events-reporting/#appendix-issue-or-revoke-bearer-tokens) for guidance on this step.'
        }
        {
          title: 'STEP 2 - Choose the correct base URL:'
          description: 'There are multiple 1Password servers which might host your events. The correct server depends on your license and region. Follow the [1Password documentation](https://developer.1password.com/docs/events-api/reference/#servers) to choose the correct server. Input the base URL as displayed by the documentation (including \'https://\' and without a trailing \'/\').'
        }
        {
          title: 'STEP 3 - Enter your 1Password Details:'
          description: 'Enter the 1Password base URL & API Token below:'
          instructions: [
            {
              type: 'Textbox'
              parameters: {
                label: 'Base Url'
                placeholder: 'Enter your Base Url'
                type: 'text'
                name: 'BaseUrl'
              }
            }
            {
              type: 'Textbox'
              parameters: {
                label: 'API Token'
                placeholder: 'Enter your API Token'
                type: 'password'
                name: 'ApiToken'
              }
            }
            {
              type: 'ConnectionToggleButton'
              parameters: {
                connectLabel: 'connect'
                name: 'connect'
              }
            }
          ]
        }
      ]
    }
  }
}

resource workspace_Microsoft_SecurityInsights_DataConnector_dataConnectorContentIdConnectorDefinition 'Microsoft.OperationalInsights/workspaces/providers/metadata@2022-01-01-preview' = {
  name: '${workspace}/Microsoft.SecurityInsights/DataConnector-${_dataConnectorContentIdConnectorDefinition}'
  properties: {
    parentId: extensionResourceId(
      resourceId('Microsoft.OperationalInsights/workspaces', workspace),
      'Microsoft.SecurityInsights/dataConnectorDefinitions',
      _dataConnectorContentIdConnectorDefinition
    )
    contentId: _dataConnectorContentIdConnectorDefinition
    kind: 'DataConnector'
    version: dataConnectorVersionConnections
    source: {
      sourceId: _solutionId
      name: _solutionName
      kind: 'Solution'
    }
    author: {
      name: _solutionAuthor
    }
    support: {
      name: _solutionAuthor
      tier: _solutionTier
    }
    dependencies: {
      criteria: [
        {
          version: dataConnectorVersionConnections
          contentId: _dataConnectorContentIdConnections
          kind: 'ResourcesDataConnector'
        }
      ]
    }
  }
}

resource workspace_Microsoft_SecurityInsights_dataConnectorTemplateNameConnections_dataConnectorVersionConnections 'Microsoft.OperationalInsights/workspaces/providers/contentTemplates@2023-04-01-preview' = {
  name: '${workspace}/Microsoft.SecurityInsights/${dataConnectorTemplateNameConnections}${dataConnectorVersionConnections}'
  location: location
  properties: {
    contentId: _dataConnectorContentIdConnections
    displayName: _dataConnectorContentIdConnectorDefinition
    contentKind: 'ResourcesDataConnector'
    packageKind: 'Solution'
    packageVersion: _solutionVersion
    packageName: _solutionName
    contentProductId: '${take(_solutionId,50)}-rdc-${uniqueString('${_solutionId}-ResourcesDataConnector-${_dataConnectorContentIdConnections}-${dataConnectorVersionConnections}')}'
    packageId: _solutionId
    contentSchemaVersion: '3.0.0'
    version: dataConnectorVersionConnections
    mainTemplate: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: dataConnectorVersionConnections
      parameters: {
        BaseUrl: {
          defaultValue: '-NA-'
          type: 'string'
          minLength: 1
        }
        ApiToken: {
          defaultValue: '-NA-'
          type: 'securestring'
          minLength: 1
        }
        connectorDefinitionName: {
          defaultValue: _dataConnectorContentIdConnectorDefinition
          type: 'string'
          minLength: 1
        }
        workspace: {
          defaultValue: workspace
          type: 'string'
        }
        dcrConfig: {
          defaultValue: {
            dataCollectionEndpoint: 'data collection Endpoint'
            dataCollectionRuleImmutableId: 'data collection rule immutableId'
          }
          type: 'object'
        }
        AuthorizationCode: {
          defaultValue: '-NA-'
          type: 'securestring'
          minLength: 1
        }
      }
      variables: {
        _dataConnectorContentIdConnections: _dataConnectorContentIdConnections
      }
      resources: [
        {
          name: '${workspace}/Microsoft.SecurityInsights/DataConnector-${_dataConnectorContentIdConnections}'
          apiVersion: '2022-01-01-preview'
          type: 'Microsoft.OperationalInsights/workspaces/providers/metadata'
          properties: {
            parentId: extensionResourceId(
              resourceId('Microsoft.OperationalInsights/workspaces', workspace),
              'Microsoft.SecurityInsights/dataConnectors',
              _dataConnectorContentIdConnections
            )
            contentId: _dataConnectorContentIdConnections
            kind: 'ResourcesDataConnector'
            version: dataConnectorVersionConnections
            source: {
              sourceId: _solutionId
              name: _solutionName
              kind: 'Solution'
            }
            author: {
              name: _solutionAuthor
            }
            support: {
              name: _solutionAuthor
              tier: _solutionTier
            }
          }
        }
        {
          name: '${workspace}/Microsoft.SecurityInsights/OnePasswordSignInEvents'
          apiVersion: '2023-02-01-preview'
          type: 'Microsoft.OperationalInsights/workspaces/providers/dataConnectors'
          location: location
          kind: 'RestApiPoller'
          properties: {
            connectorDefinitionName: _dataConnectorContentIdConnectorDefinition
            dataType: 'OnePasswordEventLogs_CL'
            dcrConfig: {
              streamName: 'Custom-OnePasswordEventLogs_CL'
              dataCollectionEndpoint: '[parameters(\'dcrConfig\').dataCollectionEndpoint]'
              dataCollectionRuleImmutableId: '[parameters(\'dcrConfig\').dataCollectionRuleImmutableId]'
            }
            auth: {
              type: 'APIKey'
              ApiKey: '[parameters(\'ApiToken\')]'
              ApiKeyName: 'Authorization'
              ApiKeyIdentifier: 'Bearer'
            }
            request: {
              apiEndpoint: '[format(\'{0}/api/v1/signinattempts\', parameters(\'BaseUrl\'))]'
              httpMethod: 'Post'
              queryWindowInMin: 5
              queryTimeFormat: 'yyyy-MM-ddTHH:mm:ssZ'
              rateLimitQps: 1
              retryCount: 3
              timeoutInSeconds: 60
              headers: {
                'Content-Type': 'application/json'
              }
              queryParametersTemplate: '{"limit": 1000, "start_time": "{_QueryWindowStartTime}", "end_time": "{_QueryWindowEndTime}" }'
              isPostPayloadJson: true
            }
            response: {
              format: 'json'
              eventsJsonPaths: [
                '$.items'
              ]
            }
            paging: {
              pagingType: 'NextPageToken'
              nextPageParaName: 'cursor'
              nextPageTokenJsonPath: '$.cursor'
              hasNextFlagJsonPath: '$.has_more'
            }
          }
        }
        {
          name: '${workspace}/Microsoft.SecurityInsights/OnePasswordAuditEvents'
          apiVersion: '2023-02-01-preview'
          type: 'Microsoft.OperationalInsights/workspaces/providers/dataConnectors'
          location: location
          kind: 'RestApiPoller'
          properties: {
            connectorDefinitionName: _dataConnectorContentIdConnectorDefinition
            dataType: 'OnePasswordEventLogs_CL'
            dcrConfig: {
              streamName: 'Custom-OnePasswordEventLogs_CL'
              dataCollectionEndpoint: '[parameters(\'dcrConfig\').dataCollectionEndpoint]'
              dataCollectionRuleImmutableId: '[parameters(\'dcrConfig\').dataCollectionRuleImmutableId]'
            }
            auth: {
              type: 'APIKey'
              ApiKey: '[parameters(\'ApiToken\')]'
              ApiKeyName: 'Authorization'
              ApiKeyIdentifier: 'Bearer'
            }
            request: {
              apiEndpoint: '[format(\'{0}/api/v1/auditevents\', parameters(\'BaseUrl\'))]'
              httpMethod: 'Post'
              queryWindowInMin: 5
              queryTimeFormat: 'yyyy-MM-ddTHH:mm:ssZ'
              rateLimitQps: 1
              retryCount: 3
              timeoutInSeconds: 60
              headers: {
                'Content-Type': 'application/json'
              }
              queryParametersTemplate: '{"limit": 1000, "start_time": "{_QueryWindowStartTime}", "end_time": "{_QueryWindowEndTime}" }'
              isPostPayloadJson: true
            }
            response: {
              format: 'json'
              eventsJsonPaths: [
                '$.items'
              ]
            }
            paging: {
              pagingType: 'NextPageToken'
              nextPageParaName: 'cursor'
              nextPageTokenJsonPath: '$.cursor'
              hasNextFlagJsonPath: '$.has_more'
            }
          }
        }
        {
          name: '${workspace}/Microsoft.SecurityInsights/OnePasswordItemUsageEvents'
          apiVersion: '2023-02-01-preview'
          type: 'Microsoft.OperationalInsights/workspaces/providers/dataConnectors'
          location: location
          kind: 'RestApiPoller'
          properties: {
            connectorDefinitionName: _dataConnectorContentIdConnectorDefinition
            dataType: 'OnePasswordEventLogs_CL'
            dcrConfig: {
              streamName: 'Custom-OnePasswordEventLogs_CL'
              dataCollectionEndpoint: '[parameters(\'dcrConfig\').dataCollectionEndpoint]'
              dataCollectionRuleImmutableId: '[parameters(\'dcrConfig\').dataCollectionRuleImmutableId]'
            }
            auth: {
              type: 'APIKey'
              ApiKey: '[parameters(\'ApiToken\')]'
              ApiKeyName: 'Authorization'
              ApiKeyIdentifier: 'Bearer'
            }
            request: {
              apiEndpoint: '[format(\'{0}/api/v1/itemusages\', parameters(\'BaseUrl\'))]'
              httpMethod: 'Post'
              queryWindowInMin: 1
              queryTimeFormat: 'yyyy-MM-ddTHH:mm:ssZ'
              rateLimitQps: 5
              retryCount: 3
              timeoutInSeconds: 60
              headers: {
                'Content-Type': 'application/json'
              }
              queryParametersTemplate: '{"limit": 1000, "start_time": "{_QueryWindowStartTime}", "end_time": "{_QueryWindowEndTime}" }'
              isPostPayloadJson: true
            }
            response: {
              format: 'json'
              eventsJsonPaths: [
                '$.items'
              ]
            }
            paging: {
              pagingType: 'NextPageToken'
              nextPageParaName: 'cursor'
              nextPageTokenJsonPath: '$.cursor'
              hasNextFlagJsonPath: '$.has_more'
            }
          }
        }
      ]
    }
  }
  dependsOn: [
    extensionResourceId(
      resourceId('Microsoft.OperationalInsights/workspaces', workspace),
      'Microsoft.SecurityInsights/contentPackages',
      _solutionId
    )
  ]
}

resource workspace_Microsoft_SecurityInsights_solutionId 'Microsoft.OperationalInsights/workspaces/providers/contentPackages@2023-04-01-preview' = {
  name: '${workspace}/Microsoft.SecurityInsights/${_solutionId}'
  location: location
  properties: {
    version: '1.0.3'
    kind: 'Solution'
    contentSchemaVersion: '1.0.0'
    displayName: _solutionName
    publisherDisplayName: _solutionPublisher
    descriptionHtml: '<p><strong>Note:</strong> <em>There may be <a href="https://aka.ms/sentinelsolutionsknownissues">known issues</a> pertaining to this Solution, please refer to them before installing.</em></p>'
    contentKind: 'Solution'
    contentProductId: _solutioncontentProductId
    id: _solutioncontentProductId
    contentId: _solutionId
    parentId: _solutionId
    source: {
      kind: 'Solution'
      name: '1Password'
      sourceId: _solutionId
    }
    author: {
      name: _solutionAuthor
    }
    support: {
      name: _solutionAuthor
      tier: _solutionTier
    }
    dependencies: {
      operator: 'AND'
      criteria: [
        {
          kind: 'DataConnector'
          contentId: _dataConnectorContentIdConnections
          version: dataConnectorVersionConnections
        }
      ]
    }
    firstPublishDate: '2024-03-01'
    providers: [
      '1Password'
    ]
    categories: {
      domains: [
        'Security - Threat Protection'
      ]
    }
  }
}
