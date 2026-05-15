resource "azurerm_logic_app_workflow" "tag_remediation" {
  name                = "tag-remediation-workflow"
  location            = var.location
  resource_group_name = var.resource_group_name

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_queue" "custodian_findings" {
  name                 = "custodian-findings"
  storage_account_name = var.storage_account_name
}

resource "azurerm_logic_app_trigger_custom" "custodian_findings_trigger" {
  name         = "custodian-findings-trigger"
  logic_app_id = azurerm_logic_app_workflow.tag_remediation.id

  body = <<BODY
{
  "recurrence": {
    "frequency": "Day",
    "interval": 1
  },
  "type": "Recurrence"
}
BODY
}

resource "azurerm_logic_app_action_custom" "parse_message" {
  name         = "parse-message"
  logic_app_id = azurerm_logic_app_workflow.tag_remediation.id

  body = jsonencode({
    type = "ParseJson"
    inputs = {
      content = "@triggerBody()?['MessageText']"
      schema = {
        type = "object"
        properties = {
          resource_id = { type = "string" }
          policy_name = { type = "string" }
        }
      }
    }
    runAfter = {}
  })
}

resource "azurerm_logic_app_action_http" "apply_tag" {
  name         = "apply-tag"
  logic_app_id = azurerm_logic_app_workflow.tag_remediation.id
  method       = "PATCH"
  uri          = "https://management.azure.com/@{body('parse-message')?['resource_id']}/providers/Microsoft.Resources/tags/default?api-version=2021-04-01"

  body = jsonencode({
    operation = "Merge"
    properties = {
      tags = {
        environment = "dev"
      }
    }
  })

  headers = {
    "Content-Type" = "application/json"
  }

  run_after {
    action_name   = "parse-message"
    action_result = "Succeeded"
  }
}


data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_role_assignment" "logic_app_tag_contributor" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Tag Contributor"
  principal_id         = azurerm_logic_app_workflow.tag_remediation.identity[0].principal_id
}


resource "azurerm_monitor_diagnostic_setting" "logic_app_diagnostics" {
  name                       = "logic-app-diagnostics"
  target_resource_id         = azurerm_logic_app_workflow.tag_remediation.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
        category = "WorkflowRuntime"
    }

 metric {
  category = "AllMetrics"
}
}