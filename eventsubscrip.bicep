param storageName string = 'charlesstorage1118'
param subscriptionId string = ''

param storageNameId string = '/subscriptions/${subscriptionId}/resourceGroups/charles-eventgrid/providers/Microsoft.Storage/StorageAccounts/'

// Create Event Source
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageName
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

// Create Event Source Container
resource containereName 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: '${storageAccount.name}/default/charlescontainer'
}

// Create Event Grid Topic
resource eventTopic 'Microsoft.EventGrid/systemTopics@2021-06-01-preview' = {
  name: 'charlestopic1118'
  location: 'canadacentral'
  tags: {
    tagName1: 'fish'
    tagName2: 'lobster'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    source: '${storageNameId}${storageAccount.name}'
    topicType: 'Microsoft.Storage.StorageAccounts'
  }
}

// Create an Event Hub Namespace
resource EventHubsNamespace 'Microsoft.EventHub/namespaces@2021-06-01-preview' = {
  name: 'charleseventhubns1118'
  location: 'Canada Central'
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 1
  }
  properties: {
    disableLocalAuth: false
    zoneRedundant: true
    isAutoInflateEnabled: false
    maximumThroughputUnits: 0
    kafkaEnabled: false
  }
}

// Create an Event Hub in EventsHub Namespace
resource EventHubsNamespaceEventHub 'Microsoft.EventHub/namespaces/eventhubs@2021-06-01-preview' = {
  parent: EventHubsNamespace
  name: 'charleseventhub1118'
  properties: {
    messageRetentionInDays: 1
    partitionCount: 2
    status: 'Active'
  }
}

// Create Event Grid Subscription
param maxDeliveryAttempts int = 30
param eventTimeToLiveInMinutes int = 1440
resource EventGridSubscription 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2021-06-01-preview' = {
  parent: eventTopic
  name: 'charlevgrdsubscrip1118'
  properties: {
    deliveryWithResourceIdentity: {
      identity: {
        type: 'SystemAssigned'
      }
      destination: {
        properties: {
          resourceId: EventHubsNamespaceEventHub.id
        }
        endpointType: 'EventHub'
      }
    }
    filter: {
      includedEventTypes: [
        'Microsoft.Storage.BlobCreated'
        'Microsoft.Storage.BlobDeleted'
      ]
      enableAdvancedFilteringOnArrays: true
    }
    labels: []
    eventDeliverySchema: 'EventGridSchema'
    retryPolicy: {
      maxDeliveryAttempts: maxDeliveryAttempts
      eventTimeToLiveInMinutes: eventTimeToLiveInMinutes
    }
  }
}
