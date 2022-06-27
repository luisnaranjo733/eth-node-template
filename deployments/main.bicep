@description('The name of you Virtual Machine.')
param vmName string = 'ethNodeVM'

@description('Username for the Virtual Machine.')
param adminUsername string

@description('Type of authentication to use on the Virtual Machine. SSH key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'password'

@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsLabelPrefix string = toLower('${vmName}-${uniqueString(resourceGroup().id)}')

@description('The Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version.')
@allowed([
  '12.04.5-LTS'
  '14.04.5-LTS'
  '16.04.0-LTS'
  '18.04-LTS' 
])
param ubuntuOSVersion string = '18.04-LTS'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The size of the VM')
param vmSize string = 'Standard_B2s'

@description('Name of the VNET')
param virtualNetworkName string = 'vNet'

@description('Name of the subnet in the virtual network')
param mainSubnetName string = 'mainSubnet'

@description('Name of the Network Security Group')
param networkSecurityGroupName string = 'SecGroupNet'

var nodePublicIPAddressName = '${vmName}PublicIP'
var bastionPublicIPAddressName = 'bastion${vmName}PublicIP'
var networkInterfaceName = '${vmName}NetInt'
var osDiskType = 'Standard_LRS'
// var bastionSubnetAddressPrefix = '10.1.1.0/26'
var mainSubnetAddressPrefix = '10.1.0.0/24'
var vnetAddressPrefix = '10.1.0.0/16'
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: adminPasswordOrKey
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }
}

// resource bastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
//   parent: vnet
//   name: 'AzureBastionSubnet'
//   properties: {
//     addressPrefix: bastionSubnetAddressPrefix
//   }
// }

resource mainSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: vnet
  name: mainSubnetName
  properties: {
    addressPrefix: mainSubnetAddressPrefix
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource nodePublicIP 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: nodePublicIPAddressName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
    idleTimeoutInMinutes: 4
  }
}

// resource bastionPublicIp 'Microsoft.Network/publicIpAddresses@2020-05-01' = {
//   name: bastionPublicIPAddressName
//   location: location
//   sku: {
//     name: 'Standard'
//   }
//   properties: {
//     publicIPAllocationMethod: 'Static'
//   }
// }

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'SSH'
        properties: {
          priority: 1000
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
      {
        name: 'Execution client (TCP)'
        properties: {
          priority: 100
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '30303'
        }
      }
      {
        name: 'Execution client (UDP)'
        properties: {
          priority: 101
          protocol: 'Udp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '30303'
        }
      }
      {
        name: 'Consensus client (TCP)'
        properties: {
          priority: 102
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '9000'
        }
      }
      {
        name: 'Consensus client (UDP)'
        properties: {
          priority: 103
          protocol: 'Udp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '9000'
        }
      }
    ]
  }
}


resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: mainSubnet.id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: nodePublicIP.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: ubuntuOSVersion
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? null : linuxConfiguration)
    }
  }
}

// resource bastionHost 'Microsoft.Network/bastionHosts@2020-05-01' = {
//   name: 'bastion-host'
//   location: location
//   dependsOn: [
//     vnet
//   ]
//   properties: {
//     ipConfigurations: [
//       {
//         name: 'IpConf'
//         properties: {
//           subnet: {
//             id: bastionSubnet.id
//           }
//           publicIPAddress: {
//             id: bastionPublicIp.id
//           }
//         }
//       }
//     ]
//   }
// }

output adminUsername string = adminUsername
output hostname string = nodePublicIP.properties.dnsSettings.fqdn
output sshCommand string = 'ssh -i <private key path> ${adminUsername}@${nodePublicIP.properties.dnsSettings.fqdn}'
// output bastionHost string = bastionPublicIp.properties.ipAddress
