local TOCNAME, _ADDONPRIVATE = ...

---@class DtListMaintenanceModule
local maintenanceModule = DtModule.New("ListMaintenance") ---@type DtListMaintenanceModule

local uiHelpersModule = DtModule.Import("UiHelpers") ---@type DtUiHelpersModule

local DT = DT_ADDON
local AceGUI = LibStub("AceGUI-3.0")

function maintenanceModule:CreateConfFrame()
  local frame = uiHelpersModule:NewFrame("Trash List Maintenance", true)
  frame:SetLayout("Fill") -- stack stuff vertically

  local scrollContainer, scroll = uiHelpersModule:NewScrollFrame()
  --scrollContainer:SetHeight(400)
  frame:SetStatusText(
      -- "Drag items to the Add button and click to release the item into the button. "
      "Items of quality |cFF0070DDblue|r or |cFFA335EEbetter|r are not accepted.")
  frame:AddChild(scrollContainer)

  --
  -- Add inline group for adding new items
  --
  local addButtonInlineGroup = uiHelpersModule:NewInlineGroup()
  addButtonInlineGroup:SetLayout("Flow") -- flow contained controls
  local addButton = uiHelpersModule:NewButton("Drag item and click here to add")
  addButton:SetWidth(250)
  addButton:SetHeight(24)

  local endDragFn = function() DT:OnDropItem() end
  addButton:SetCallback("OnClick", endDragFn)
  addButton:SetCallback("OnMouseUp", endDragFn)
  addButton:SetCallback("OnReceiveDrag", endDragFn)

  addButtonInlineGroup:AddChild(addButton)
  scroll:AddChild(addButtonInlineGroup)

  --
  -- Add group for each droppable item with delete button
  --
  local rules = DropTrashRules

  for index, itemName in ipairs(rules) do
    local inlineGroup = uiHelpersModule:NewInlineGroup()
    inlineGroup:SetWidth(300)
    inlineGroup:SetLayout("Flow") -- flow contained controls

    local label = uiHelpersModule:NewLabel(itemName)
    label:SetWidth(220)
    label:SetHeight(24)
    inlineGroup:AddChild(label)

    local button = uiHelpersModule:NewButton("X")
    button:SetWidth(40)
    button:SetHeight(24)

    local removeIndex = 1 * index
    button:SetCallback("OnClick", function()
      label:SetText("[Removed] " .. itemName)
      button:SetText("")
      button:SetDisabled(true)
      table.remove(rules, removeIndex)
    end)
    inlineGroup:AddChild(button)

    scroll:AddChild(inlineGroup)
  end

  return frame
end

