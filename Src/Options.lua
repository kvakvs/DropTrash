--local _TOCNAME, _ADDONPRIVATE = ...
--local DT = DT_ADDON ---@type DtAddon

---@class DtOptionsModule
local optionsModule = DtModule.New("Options") ---@type DtOptionsModule
local reserveExplanation = "When soulshards are marked as trash, stop deleting at N remaining in the bags. Convenience option for affliction warlocks. Minimum to reserve is 1."
optionsModule.language = --[[---@type {[string]:string} ]] {
  ["options.category.General"] = "General",

  ["options.short.hideFloatingButton"] = "Hide floating button",
  ["options.long.hideFloatingButton"] = "Hide floating button. If you hide the button, the functionality is still available using keyboard shortcuts",

  ["options.short.hideGreetingMessage"] = "Hide greeting message",
  ["options.long.hideGreetingMessage"] = "Hide 'DropTrash: Ready' greeting message",

  ["options.short.reserveSoulshards"] = "Reserve soulshards",
  ["options.short.reserveSoulshardsParty"] = "Reserve soulshards (5-man party)",
  ["options.short.reserveSoulshardsRaid"] = "Reserve soulshards (Raid)",
  ["options.long.reserveSoulshards"] = reserveExplanation .. " Works only when not in a group.",
  ["options.long.reserveSoulshardsParty"] = reserveExplanation .. " Works in 5-man party only.",
  ["options.long.reserveSoulshardsRaid"] = reserveExplanation .. " Works in raid only.",
}

local kvOptionsModule = KvModuleManager.optionsModule

---@param key string
---@return string
local function _t(key)
  return optionsModule.language[key] or "→" .. key
end

---@param dict table|nil
---@param key string|nil
---@param notify function|nil Call this with (key, value) on option change
function optionsModule:TemplateCheckbox(name, dict, key, notify)
  return kvOptionsModule:TemplateCheckbox(name, dict or DropTrashOptions, key or name, notify, _t)
end

---@param name string
---@param onClick function Call this when button is pressed
function optionsModule:TemplateButton(name, onClick)
  return kvOptionsModule:TemplateButton(name, onClick, _t)
end

---@param values table|function Key is sent to the setter, value is the string displayed
---@param dict table|nil
---@param key string|nil
---@param notifyFn function|nil Call this with (key, value) on option change
function optionsModule:TemplateMultiselect(name, values, dict, notifyFn, setFn, getFn)
  return kvOptionsModule:TemplateMultiselect(name, values, dict or DropTrashOptions, notifyFn, setFn, getFn, _t)
end

---@param values table|function Key is sent to the setter, value is the string displayed
---@param dict table|nil
---@param style string|nil "dropdown" or "radio"
---@param notifyFn function|nil Call this with (key, value) on option change
function optionsModule:TemplateSelect(name, values, style, dict, notifyFn, setFn, getFn)
  return kvOptionsModule:TemplateSelect(name, values, style, dict or DropTrashOptions, notifyFn, setFn, getFn, _t)
end

---@param dict table|nil
---@param key string|nil
---@param notify function|nil Call this with (key, value) on option change
function optionsModule:TemplateInput(type, name, dict, key, notify)
  return kvOptionsModule:TemplateInput(type, name, dict or DropTrashOptions, key or name, notify, _t)
end

---@param dict table|nil
---@param key string|nil
---@param notify function|nil Call this with (key, value) on option change
function optionsModule:TemplateRange(name, rangeFrom, rangeTo, step, dict, key, notify)
  return kvOptionsModule:TemplateRange(name, rangeFrom, rangeTo, step, dict or DropTrashOptions, key or name, notify, _t)
end
--
-----@param dict table|nil
-----@param key string|nil
-----@param notify function|nil Call this with (key, value) on option change
--function optionsModule:TemplateCheckbox(name, tooltip, dict, key, notify)
--  self.optionsOrder = self.optionsOrder + 1
--
--  return {
--    name  = name,
--    desc  = tooltip,
--    type  = "toggle",
--    width = "full",
--    order = self.optionsOrder,
--
--    set   = function(info, val)
--      dict[key] = val
--      if notify then
--        notify(key, val)
--      end
--    end,
--    get   = function(info)
--      return dict[key] == true
--    end,
--  }
--end

function optionsModule:CreateOptionsTable()
  kvOptionsModule.optionsOrder = 0

  return {
    type = "group",
    args = {
      hideFloatingButton = self:TemplateCheckbox(
          "hideFloatingButton",
          DropTrashOptions, "HideFloatingButton",
          function(key, value)
            if value then
              DropTrashButton:Hide()
            else
              DropTrashButton:Show()
            end
          end),
      hideGreetingMessage = self:TemplateCheckbox("hideGreetingMessage",
          DropTrashOptions, "HideGreetingMessage", nil),
      reserveSoulshards = self:TemplateRange("reserveSoulshards", 1, 32, 1,
          DropTrashOptions, "ReserveSoulshards", nil),
      reserveSoulshardsParty = self:TemplateRange("reserveSoulshardsParty", 1, 32, 1,
          DropTrashOptions, "ReserveSoulshardsParty", nil),
      reserveSoulshardsRaid = self:TemplateRange("reserveSoulshardsRaid", 1, 32, 1,
          DropTrashOptions, "ReserveSoulshardsRaid", nil),
    } -- end args
  } -- end
end
