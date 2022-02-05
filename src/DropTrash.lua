---@type DropTrashAddon
local _TOCNAME, DT = ...

---@type DropTrashAddon
DROPTRASH_MOD      = DT

-- Persisted information:
DropTrash_Rules    = DropTrash_Rules or {}
DropTrash_Options  = DropTrash_Options or {}

DT.Rules           = DropTrash_Rules
DT.Options         = DropTrash_Options

DT.Const           = {
  ButtonPosX = "ButtonPosX",
  ButtonPosY = "ButtonPosY",
}
local Const        = DT.Const

---Print a text with "DropTrash: " prefix in the game chat window
---@param t string
function DT.Print(t)
  local name = "DropTrash"
  DEFAULT_CHAT_FRAME:AddMessage("|c80808080" .. name .. "|r: " .. t)
end

function DT.SetOption(parameter, value)
  local realmname  = GetRealmName();
  local playername = UnitName("player");

  -- Character level config: create realm if not found in options
  if not DropTrash_Options[realmname] then
    DropTrash_Options[realmname] = {};
  end

  -- Character level config: create character section if not found in options
  if not DropTrash_Options[realmname][playername] then
    DropTrash_Options[realmname][playername] = {};
  end

  -- Set the value
  DropTrash_Options[realmname][playername][parameter] = value;
end

function DT.GetOption(parameter, defaultValue)
  local realmname  = GetRealmName();
  local playername = UnitName("player");

  -- Character level
  if DropTrash_Options[realmname] then
    if DropTrash_Options[realmname][playername] then
      if DropTrash_Options[realmname][playername][parameter] then
        local value = DropTrash_Options[realmname][playername][parameter];
        if (type(value) == "table") or not (value == "") then
          return value;
        end
      end
    end
  end

  return defaultValue;
end

local function DropTrash_InitializeConfigSettings()
  if not DropTrash_Options then
    DropTrash_Options = {};
  end

  local x, y = DropTrashButton:GetPoint();
  DT.SetOption(Const.ButtonPosX, DT.GetOption(Const.ButtonPosX, x))
  DT.SetOption(Const.ButtonPosY, DT.GetOption(Const.ButtonPosY, y))
end

function DropTrash_OnEvent(self, event, ...)
  if (event == "ADDON_LOADED") then
    local addonname = ...;
    if addonname == "DropTrash" then
      DropTrash_InitializeConfigSettings();
    end
  end
end

function DropTrash_OnLoad()
  DropTrashEventFrame:RegisterEvent("ADDON_LOADED");

  -- DtMod.DropButtonMoved(DropTrashButton);
end

---This is displayed in config scroll frame
function DT.ShowConfig()
  DropTrashConfigScrollbar_Update(DropTrashConfigScroll)
  DropTrashConfigFrame:Show()
end

local function DT_CountRules()
  local n = 0
  for _, _ in pairs(DropTrash_Rules) do
    n = n + 1
  end
  return n
end

VISIBLE_HEIGHT = 10 -- matches count of table row buttons in the Config Frame

function DropTrashConfigScrollbar_Update(self)
  -- 16 is pixel height of each line
  local rulesCount
  rulesCount = DT_CountRules()

  FauxScrollFrame_Update(DropTrashConfigScroll, rulesCount, VISIBLE_HEIGHT, 16);

  local linePlusOffset
  local rowLabel

  for line = 1, VISIBLE_HEIGHT do
    linePlusOffset = line + FauxScrollFrame_GetOffset(DropTrashConfigScroll);
    rowLabel       = getglobal("DropTrashRuleRow" .. line)

    if linePlusOffset <= rulesCount then
      rowLabel:SetText(DropTrash_Rules[linePlusOffset]);
      rowLabel:Show();
    else
      rowLabel:Hide();
    end
  end
end

-- Row of config rule list is clicked - delete
function DT_ClickRulesRow(line)
  local linePlusOffset
  linePlusOffset = line + FauxScrollFrame_GetOffset(DropTrashConfigScroll);

  -- Shift all table contents down 1 over the deleted item
  table.remove(DropTrash_Rules, linePlusOffset)

  DT.ShowConfig()
end

-- CONSOLE COMMANDS
--
SLASH_DROPTRASH_TRASH1          = "/trash"
SlashCmdList["DROPTRASH_TRASH"] = function(msg)
  local _, _, option = string.find(msg, "(%S*)")
  DT.ShowConfig()
end

SLASH_FRAMESTK1                 = "/fs"; -- new slash command for showing framestack tool
SlashCmdList.FRAMESTK           = function()
  LoadAddOn("Blizzard_DebugTools");
  FrameStackTooltip_Toggle();
end

function DropTrashConfig_Close()
  DropTrashConfigFrame:Hide()
end

local function DT_AddItem(text)
  local itemName, itemLink, itemRarity = GetItemInfo(text)

  if itemRarity >= 3 then
    message("Items of |cFF0070DDblue|r quality or |cFFA335EEbetter|r cannot be " ..
        "added here. There is no destruction confirmation, " ..
        "this will shred everything!")
    return
  end

  for _, value in ipairs(DropTrash_Rules) do
    if value == itemName then
      return -- already exists
    end
  end

  tinsert(DropTrash_Rules, itemName)
  table.sort(DropTrash_Rules)
  DT.ShowConfig()
end

function DT_OnDropItem()
  local infoType, _, info2 = GetCursorInfo()
  if infoType == "item" then
    DT_AddItem(info2)
    ClearCursor()
  end
end

local function DT_Tooltip_SetItem(tooltip)
  --local match = string.match
  --local strsplit = strsplit
  local itemName, link = tooltip:GetItem()
  if not link then return; end
  --
  --local itemString = match(link, "item[%-?%d:]+")
  --local itemName, _itemId = strsplit(":", itemString)
  --
  ----From idTip: http://www.wowinterface.com/downloads/info17033-idTip.html
  --if itemId == "0" and TradeSkillFrame ~= nil and TradeSkillFrame:IsVisible() then
  --  if (GetMouseFocus():GetName()) == "TradeSkillSkillIcon" then
  --    itemId = GetTradeSkillItemLink(TradeSkillFrame.selectedSkill):match("item:(%d+):") or nil
  --  else
  --    for i = 1, 8 do
  --      if (GetMouseFocus():GetName()) == "TradeSkillReagent"..i then
  --        itemId = GetTradeSkillReagentItemLink(TradeSkillFrame.selectedSkill, i):match("item:(%d+):") or nil
  --        break
  --      end
  --    end
  --  end
  --end

  if DT.MatchItemName(itemName) then
    --tooltip:AddLine(" ") --blank line
    tooltip:AddLine("|c80808080DropTrash|r: This item is marked as trash")
  end
end

function DT.Init()
  -- Key Binding section header and key translations (see Bindings.XML)
  BINDING_HEADER_DROPTRASH = "Drop Trash"
  BINDING_NAME_TAKEOUTTRASH = "Take out the trash"
  BINDING_NAME_SHOWTRASHWINDOW = "Show Config window"

  GameTooltip:HookScript("OnTooltipSetItem", DT_Tooltip_SetItem)

  DT.Print("Ready")
end
