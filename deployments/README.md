## Setup

Install Bicep CLI

https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#azure-cli

## Create parameters.json

## Deployment from Bicep

Create the resource group in the desired location

```bash
az group create --name exampleRG --location eastus
```

Deploy the Bicep template in that resource group and pass in required parameters

```bash
az deployment group create --resource-group exampleRG --template-file main.bicep --parameters @parameters.json
```
