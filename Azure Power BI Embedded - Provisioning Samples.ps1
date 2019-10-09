#-------------------------------------------------------------------------
# Copyright (c) Microsoft.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#--------------------------------------------------------------------------

# Authenticate to Azure - can automate with Azure AD Service Principal credentials

    Connect-AzAccount 

# Select Azure Subscription - can automate with specific Azure subscriptionId

    $subscriptionId = 
        (Get-AzSubscription |
         Out-GridView `
            -Title "Select an Azure Subscription ..." `
            -PassThru).SubscriptionId

# Create Resource Group

    $rgName = "kem-pbie-01-rg"
    $location = "westcentralus"
    $rg = New-AzResourceGroup -Name $rgName -Location $location -Force

# Create Power BI Embedded Capacity

    $resourceName = "kempbie03"
    $sku = "A1"
    $adminNames = "kmayer@microsoft.com"
    if (!Test-AzPowerBIEmbeddedCapacity -Name $resourceName -Debug) {
        $pbieCapacity = New-AzPowerBIEmbeddedCapacity -Name $resourceName -ResourceGroupName $rgName -Location $location -Sku $sku -Administrator $adminNames -Debug
    }

    <#

    HTTP Method:
    GET

    Absolute Uri:
    https://management.azure.com/subscriptions/35481b74-e090-40a8-888b-42bc552d8369/providers/Microsoft.PowerBIDedicated/capacities?api-version=2017-10-01

    HTTP Method:
    PUT

    Absolute Uri:
    https://management.azure.com/subscriptions/35481b74-e090-40a8-888b-42bc552d8369/resourceGroups/kem-pbie-01-rg/providers/Microsoft.PowerBIDedicated/capacities/kempbie03?api-version=2017-10-01

    Headers:
    x-ms-client-request-id        : 321fc508-45b8-4ce1-8523-8a20d1ebd7ee
    accept-language               : en-US

    Body:
    {
      "properties": {
        "administration": {
          "members": [
            "kmayer@microsoft.com"
          ]
        }
      },
      "location": "westcentralus",
      "sku": {
        "name": "A1",
        "tier": "PBIE_Azure"
      }
    }

    HTTP Method:
    GET

    Absolute Uri:
    https://management.azure.com/subscriptions/35481b74-e090-40a8-888b-42bc552d8369/resourceGroups/kem-pbie-01-rg/providers/Microsoft.PowerBIDedicated/capacities/kempbie03?api-version=2017-10-01

    #>

# Scale Power BI Embedded Capacity

    $newSku = "A2"
    Update-AzPowerBIEmbeddedCapacity -Name $resourceName -Sku $newSku -Debug
    $pbieCapacity = Get-AzPowerBIEmbeddedCapacity -Name $resourceName

    <#

    HTTP Method:
    PATCH

    Absolute Uri:
    https://management.azure.com/subscriptions/35481b74-e090-40a8-888b-42bc552d8369/resourceGroups/kem-pbie-01-rg/providers/Microsoft.PowerBIDedicated/capacities/kempbie03?api-version=2017-10-01

    Headers:
    x-ms-client-request-id        : b2d18258-b5d1-4d53-9aa7-969948521304
    accept-language               : en-US

    Body:
    {
      "sku": {
        "name": "A2",
        "tier": "PBIE_Azure"
      },
      "tags": {}
    }

    HTTP Method:
    GET

    Absolute Uri:
    https://management.azure.com/subscriptions/35481b74-e090-40a8-888b-42bc552d8369/resourceGroups/kem-pbie-01-rg/providers/Microsoft.PowerBIDedicated/capacities/kempbie03?api-version=2017-10-01

    #>

# Suspend Power BI Embedded Capacity

    Suspend-AzPowerBIEmbeddedCapacity -Name $resourceName -Debug

    <#

    HTTP Method:
    POST

    Absolute Uri:
    https://management.azure.com/subscriptions/35481b74-e090-40a8-888b-42bc552d8369/resourceGroups/kem-pbie-01-rg/providers/Microsoft.PowerBIDedicated/capacities/kempbie03/suspend?api-version=2017-10-01

    #>

# Resume Power BI Embedded Capacity

    Resume-AzPowerBIEmbeddedCapacity -Name $resourceName -Debug

    <#

    HTTP Method:
    POST

    Absolute Uri:
    https://management.azure.com/subscriptions/35481b74-e090-40a8-888b-42bc552d8369/resourceGroups/kem-pbie-01-rg/providers/Microsoft.PowerBIDedicated/capacities/kempbie03/suspend?api-version=2017-10-01

    #>

# Get token and create authorization header

    $azContext = Get-AzContext
    $azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
    $profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($azProfile)
    $token = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
    $authHeader = @{
        'Authorization'='Bearer ' + $token.AccessToken
    }

# Set other REST API parameters

    $apiVersion = 
        ((Get-AzResourceProvider -ProviderNamespace Microsoft.PowerBIDedicated).ResourceTypes |
            Where-Object ResourceTypeName -eq "capacities").ApiVersions[0]
    $action = "GET"
    $contentType = "application/json"

# Invoke REST API calls

    $uri = ""

    $results = 
        Invoke-RestMethod `
            -ContentType $contentType `
            -Uri $uri `
            -Method $action `
            -Headers $authHeader 
