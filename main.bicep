targetScope = 'subscription'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'charles-eventgrid'
  location: 'canadacentral'
  tags:{
    'owner': 'charles'   
  }
}

module EventGridModule 'eventsubscrip.bicep' = {
  name: 'eventgridmodule'
  scope: resourceGroup
}
