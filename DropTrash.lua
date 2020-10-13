local DTOPTION_ButtonPosX = "ButtonPosX";
local DTOPTION_ButtonPosY = "ButtonPosY";

-- Persisted information:
DropTrash_Rules = {}
DropTrash_Options = {}

function DropTrash_SetOption(parameter, value)
  local realmname = GetRealmName();
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

function DropTrash_GetOption(parameter, defaultValue)
  local realmname = GetRealmName();
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

function DropTrash_ButtonMoved(self)
  local x, y = self:GetLeft(), self:GetTop() - UIParent:GetHeight();

  DropTrash_SetOption(DTOPTION_ButtonPosX, x);
  DropTrash_SetOption(DTOPTION_ButtonPosY, y);
end

function DropTrash_InitializeConfigSettings()
  if not DropTrash_Options then
    DropTrash_Options = {};
  end

  local x, y = DropTrashButton:GetPoint();
  DropTrash_SetOption(DTOPTION_ButtonPosX, DropTrash_GetOption(DTOPTION_ButtonPosX, x))
  DropTrash_SetOption(DTOPTION_ButtonPosY, DropTrash_GetOption(DTOPTION_ButtonPosY, y))
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

  DropTrash_ButtonMoved(DropTrashButton);
end

function DT_MatchRule(itemName)
  for _, matchString in pairs(DropTrash_Rules) do
    -- Do not allow too short strings (4+)
    -- string.find(itemName, matchString)
    if string.len(matchString) > 3 and itemName == matchString then
      return true
    end
   end
   return false
end

function DropTrash_OnClick(self)
  local count = 0

  -- For all bags
  for bagId = 0, 4 do
    -- For all bag slots
    for bagSlotId = 1, 36 do
      local text = GetContainerItemLink(bagId, bagSlotId)
      if text then
        local itemName = GetItemInfo(text)
        if DT_MatchRule(itemName) then
          -- Drag item and destroy item on cursor
          PickupContainerItem(bagId, bagSlotId)
          DeleteCursorItem()
          count = count + 1
        end
      end
    end
  end

  print("DropTrash: Destroyed", count, "bagslots of items")
end

-- this is displayed in config scroll frame
function DropTrashConfig_Show()
  DropTrashConfigScrollbar_Update(DropTrashConfigScroll)
  DropTrashConfigFrame:Show()
end

function DT_CountRules()
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

  local line
  local linePlusOffset
  local rowLabel

  for line = 1, VISIBLE_HEIGHT do
    linePlusOffset = line + FauxScrollFrame_GetOffset(DropTrashConfigScroll);
    rowLabel = getglobal("DropTrashRuleRow" .. line)

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

  DropTrashConfig_Show()
end

-- CONSOLE COMMANDS
--
SLASH_DROPTRASH_TRASH1 = "/trash"
SlashCmdList["DROPTRASH_TRASH"] = function(msg)
  local _, _, option = string.find(msg, "(%S*)")
  DropTrashConfig_Show()
end

SLASH_FRAMESTK1 = "/fs"; -- new slash command for showing framestack tool
SlashCmdList.FRAMESTK = function()
  LoadAddOn("Blizzard_DebugTools");
  FrameStackTooltip_Toggle();
end

function DropTrashConfig_Close()
  DropTrashConfigFrame:Hide()
end

function DT_AddItem(text)
  local itemName, itemLink, itemRarity = GetItemInfo(text)

  if itemRarity >= 3 then
    message("Items of blue quality or better cannot be added here. " ..
      "There is no destruction confirmation, this will shred everything!")
    return
  end

  for _, value in ipairs(DropTrash_Rules) do
    if value == itemName then
      return -- already exists
    end
  end

  tinsert(DropTrash_Rules, itemName)
  table.sort(DropTrash_Rules)
  DropTrashConfig_Show()
end

function DT_OnDropItem()
  local infoType, _, info2 = GetCursorInfo()
  if infoType == "item" then
    DT_AddItem(info2)
    ClearCursor()
  end
end
