#!/bin/bash
RG="rg-azure-vuln-platform-dev"
SA="utfstateazurevulnplatdev"
CONTAINER="tfstate"
LOCATION="westcentralus"

az group create --name "$RG" --location "$LOCATION"

az storage account create \
  --name "$SA" \
  --resource-group "$RG" \
  --location "$LOCATION" \
  --sku "Standard_LRS" \
  --kind "StorageV2" \
  --allow-blob-public-access false

az storage container create \
  --name "$CONTAINER" \
  --account-name "$SA" \
  --auth-mode login

az role assignment create \
  --role "Storage Blob Data Contributor" \
  --assignee $(az ad signed-in-user show --query id -o tsv) \
  --scope $(az storage account show \
    --name "$SA" \
    --resource-group "$RG" \
    --query id -o tsv)

echo "Bootstrap complete. Backend storage ready."