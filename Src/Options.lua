local _TOCNAME, _ADDONPRIVATE = ...
local DT = DT_ADDON ---@type DtAddon

---@class DtOptionsModule
local optionsModule = DtModule.DeclareModule("Options") ---@type DtOptionsModule
optionsModule.optionsOrder = 0

---@param dict table|nil
---@param key string|nil
---@param notify function|nil Call this with (key, value) on option change
function optionsModule:TemplateCheckbox(name, tooltip, dict, key, notify)
  self.optionsOrder = self.optionsOrder + 1

  return {
    name  = name,
    desc  = tooltip,
    type  = "toggle",
    width = "full",
    order = self.optionsOrder,

    set   = function(info, val)
      dict[key] = val
      if notify then
        notify(key, val)
      end
    end,
    get   = function(info)
      return dict[key] == true
    end,
  }
end

function optionsModule:CreateOptionsTable()
  self.optionsOrder = 0

  return {
    type = "group",
    args = {
      showFloatingButton  = self:TemplateCheckbox(
          "Hide floating button",
          "Hide floating button. If you hide the button, the functionality is still available using keyboard shortcuts",
          DropTrash_Options, "HideFloatingButton",
          function(key, value)
            if value then
              DropTrashButton:Hide()
            else
              DropTrashButton:Show()
            end
          end),
      hideGreetingMessage = self:TemplateCheckbox(
          "Hide greeting message", "Hide 'DropTrash: Ready' greeting message",
          DropTrash_Options, "HideGreetingMessage"),
    } -- end args
  } -- end
end
