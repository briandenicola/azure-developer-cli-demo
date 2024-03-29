# Overview
This repo is a simple example to show how to use the [Azure Developer Cli](https://docs.microsoft.com/en-us/azure/developer/azure-developer-cli/reference) for inner loop development in Azure.  
It leverages Github Codespaces as a hosted developer environment. 

## Github Action
The repo also has two Github Action workflows that would be used to promote code into upper environments after changes are merged into the main branch. 
* Create Azure Container Apps Environment 
* Update a deployment to Azure Container Apps

### Required Action Secrets
| Variable | Usage |
--------------- | --------------- 
| SIMPLE_AZURE_CREDENTIALS | [Creds to access Azure](https://docs.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Cwindows)| 
| CONTAINER_APP_RG | Resource Group Name for the Upper Environment  | 
| CONTAINER_APP_NAME | Container App Environment Name for the Upper Environment | 
| DOCKER_REPO | Container Registry for Upper Environment |
| SIMPLE_REGISTRY_USERNAME | User name for Container Registry | 
| SIMPLE_REGISTRY_PASSWORD | User password for Container Registry | 

## Prerequisite 
* Azure Subscrption
* Github Codespaces

## Deployed Azure Resources 
* Azure Container Registry 
* Azure Container Environment 
* Azure Container App
* Azure PostgreSQL

# Deploy Environment
``` bash
    git checkout -b branch/feature1
    azd login --tenant-id $ARM_TENANT_ID --client-id $ARM_CLIENT_ID --client-secret $ARM_CLIENT_SECRET
    azd init 
        - Environment Name: dev
        - Azure Location: (US) Southcentral US
        - Azure Subscription: <ENTER> 
    azd up
    ./scripts/update-ui.sh
```

# Validate
```bash
    ./scripts/validate.sh
```

# Update Deployment
```C#
    //Update line 9 from 
    app.MapGet( "/", () =>  $"Hello World! The time now is {DateTime.Now}" );
    //To 
    app.MapGet( "/", () =>  $"Hello World, Updated! The time now is {DateTime.Now}" );
```

## Redeploy and Validate 
``` bash
    azd deploy 
    ./scripts/validate.sh
```

## Pull Request
* At this point, a developer would commit the code upstream to their branch and create a pull request. After approved then the _Update a deployment to Azure Container Apps_ Github Action workflow will deploy the change to the upper environments. 

# Clean Up
``` bash
    azd down
```

# Backlog
- [X] Create script to build and push docker image
- [X] Create script to upate Container App with latest image
- [X] Migrate to Dapr/PostgreSQL from InMemory Database