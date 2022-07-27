local TOCNAME, _ADDONPRIVATE = ...

---@class DtUiHelpersModule
local uiHelpersModule = DtModule.New("UiHelpers") ---@type DtUiHelpersModule

local AceGUI = LibStub("AceGUI-3.0")

function uiHelpersModule:NewFrame(title)
  local frame = AceGUI:Create("Frame")
  frame:SetTitle(title)

  return frame
end

function uiHelpersModule:NewInlineGroup()
  local inlineGroup = AceGUI:Create("InlineGroup")
  return inlineGroup
end

function uiHelpersModule:NewLabel(text)
  local label = AceGUI:Create("Label")
  label:SetText(text)
  return label
end

function uiHelpersModule:NewButton(text)
  local button = AceGUI:Create("Button")
  button:SetText(text)
  return button
end

---@return table,table A pair (scrollContainer, scrollFrame)
function uiHelpersModule:NewScrollFrame()
  local scrollcontainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
  scrollcontainer:SetFullWidth(true)
  scrollcontainer:SetFullHeight(true) -- probably?
  scrollcontainer:SetLayout("Fill") -- important!

  local scroll = AceGUI:Create("ScrollFrame")
  scroll:SetLayout("Flow")
  scroll:SetFullWidth(true)

  -- This script needed to allow the scrollframe resize whenever content
  -- changes or vertical size is moved
  scroll.frame:SetScript("OnUpdate", function()
    scroll:SetHeight(scroll.frame:GetHeight() - 255)
  end)

  scrollcontainer:AddChild(scroll)

  return scrollcontainer, scroll
end

