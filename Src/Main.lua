local TOCNAME, _ADDONPRIVATE = ...

---@class DtMainModule
local mainModule = DtModule.New("Main") ---@type DtMainModule

local constModule = DtModule.Import("Const") ---@type DtConstModule
local optionsModule = DtModule.Import("Options") ---@type DtOptionsModule
local maintenanceModule = DtModule.Import("ListMaintenance") ---@type DtListMaintenanceModule

local DT = LibStub("AceAddon-3.0"):NewAddon(
    TOCNAME, "AceConsole-3.0", "AceEvent-3.0") ---@type DtAddon
local AceGUI = LibStub("AceGUI-3.0")

---@type DtAddon
DT_ADDON = DT

DT.Const = {
  ButtonPosX = "ButtonPosX",
  ButtonPosY = "ButtonPosY",
}
local Const = DT.Const

function DT.SetOption(parameter, value)
  local realmname = GetRealmName();
  local playername = UnitName("player");

  -- Character level config: create realm if not found in options
  if not DropTrashOptions[realmname] then
    DropTrashOptions[realmname] = {};
  end

  -- Character level config: create character section if not found in options
  if not DropTrashOptions[realmname][playername] then
    DropTrashOptions[realmname][playername] = {};
  end

  -- Set the value
  DropTrashOptions[realmname][playername][parameter] = value;
end

function DT.GetOption(parameter, defaultValue)
  local realmname = GetRealmName();
  local playername = UnitName("player");

  -- Character level
  if DropTrashOptions[realmname] then
    if DropTrashOptions[realmname][playername] then
      if DropTrashOptions[realmname][playername][parameter] then
        local value = DropTrashOptions[realmname][playername][parameter];
        if (type(value) == "table") or not (value == "") then
          return value;
        end
      end
    end
  end

  return defaultValue;
end

local function DropTrash_InitializeConfigSettings()
  if not DropTrashOptions then
    DropTrashOptions = --[[---@type DtAddonOptions]] {}
  end

  local x, y = DropTrashButton:GetPoint();
  DT.SetOption(Const.ButtonPosX, DT.GetOption(Const.ButtonPosX, x))
  DT.SetOption(Const.ButtonPosY, DT.GetOption(Const.ButtonPosY, y))
end

function DT:OnEvent(evType, event, ...)
  if (event == "ADDON_LOADED") then
    local addonname = ...;
    if addonname == "DropTrash" then
      DropTrash_InitializeConfigSettings();
    end
  end
end

function DT:OnLoad()
  DropTrashEventFrame:RegisterEvent("ADDON_LOADED");

  -- DtMod.DropButtonMoved(DropTrashButton);
end

---This is displayed in config scroll frame
function DT:ShowConfig()
  self:Scrollbar_Update(DropTrashConfigScroll)
  -- DropTrashConfigFrame:Show()

  if DT.confFrame then
    AceGUI:Release(DT.confFrame)
    _G["DropTrashConfigFrame"] = nil
    DT.confFrame = nil
  end

  DT.confFrame = maintenanceModule:CreateConfFrame()
  _G["DropTrashConfigFrame"] = DT.confFrame
  tinsert(UISpecialFrames, "DropTrashConfigFrame")

  DT.confFrame:SetCallback("OnClose", function(widget)
    AceGUI:Release(widget)
    DT.confFrame = nil
  end)

  DT.confFrame:Show()
end

local function DT_CountRules()
  local n = 0
  for _, _ in pairs(DropTrashRules) do
    n = n + 1
  end
  return n
end

local VISIBLE_HEIGHT = 10 -- matches count of table row buttons in the Config Frame
local ROW_HEIGHT = 16 -- units height of a table row

function DT:Scrollbar_Update()
  local rulesCount = DT_CountRules()

  FauxScrollFrame_Update(DropTrashConfigScroll, rulesCount, VISIBLE_HEIGHT, ROW_HEIGHT);

  for line = 1, VISIBLE_HEIGHT do
    local linePlusOffset = line + FauxScrollFrame_GetOffset(DropTrashConfigScroll);
    local rowLabel = getglobal("DropTrashRuleRow" .. line)

    if linePlusOffset <= rulesCount then
      rowLabel:SetText(DropTrashRules[linePlusOffset]);
      rowLabel:Show();
    else
      rowLabel:Hide();
    end
  end
end

-- Row of config rule list is clicked - delete
function DT:ClickRulesRow(line)
  local linePlusOffset
  linePlusOffset = line + FauxScrollFrame_GetOffset(DropTrashConfigScroll);

  -- Shift all table contents down 1 over the deleted item
  table.remove(DropTrashRules, linePlusOffset)

  DT:ShowConfig()
end

---AceAddon handler
function DT:OnInitialize()
  -- do init tasks here, like loading the Saved Variables,
  -- or setting up slash commands.
end

---AceAddon handler
function DT:OnEnable()
  DropTrashRules = (DropTrash_Rules or DropTrashRules) or {}
  if DropTrash_Rules then
    DropTrash_Rules = nil
  end
  DropTrashOptions = (DropTrash_Options or DropTrashOptions) or {}
  if DropTrash_Options then
    DropTrash_Options = nil
  end

  DT.Rules = DropTrashRules
  DT.Options = DropTrashOptions

  -- Do more initialization here, that really enables the use of your addon.
  -- Register Events, Hook functions, Create Frames, Get information from
  -- the game that wasn't available in OnInitialize

  -- OPTIONS
  LibStub("AceConfig-3.0"):RegisterOptionsTable(TOCNAME, optionsModule:CreateOptionsTable(), {})

  self.optionsFrames = {
    general = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(
        TOCNAME, constModule.SHORT_TITLE, nil)
  }

  -- CONSOLE COMMANDS
  --
  SLASH_DROPTRASH_TRASH1 = "/trash"
  SlashCmdList["DROPTRASH_TRASH"] = function(msg)
    local _, _, option = string.find(msg, "(%S*)")
    DT:ShowConfig()
  end

  SLASH_FRAMESTK1 = "/fs"; -- new slash command for showing framestack tool
  SlashCmdList.FRAMESTK = function()
    LoadAddOn("Blizzard_DebugTools");
    FrameStackTooltip_Toggle();
  end

  -- Key Binding section header and key translations (see Bindings.XML)
  BINDING_HEADER_DROPTRASH = "Drop Trash"
  BINDING_NAME_TAKEOUTTRASH = "Take out the trash"
  BINDING_NAME_SHOWTRASHWINDOW = "Show Config window"

  GameTooltip:HookScript("OnTooltipSetItem", DT.Tooltip_SetItem)

  if DropTrashOptions.HideFloatingButton then
    DropTrashButton:Hide()
  end

  if not DropTrashOptions.HideGreetingMessage then
    DT:Print("Ready")
  end
end

---AceAddon handler
function DT:OnDisable()
end

function DT:Config_Close()
  --DropTrashConfigFrame:Hide()
end

function DT:AddItem(text)
  local itemName, itemLink, itemRarity = GetItemInfo(text)

  if itemRarity >= 3 then
    -- Popup with text and OK button
    message("Items of |cFF0070DDblue|r quality or |cFFA335EEbetter|r cannot be " ..
        "added here. There is no destruction confirmation, " ..
        "this will shred everything!")
    return
  end

  for _, value in ipairs(DropTrashRules) do
    if value == itemName then
      return -- already exists
    end
  end

  tinsert(DropTrashRules, itemName)
  table.sort(DropTrashRules)
  DT:ShowConfig()
end

function DT:OnDropItem()
  local infoType, _, info2 = GetCursorInfo()
  if infoType == "item" then
    self:AddItem(info2)
    ClearCursor()
  end
end

function DT.Tooltip_SetItem(tooltip)
  --local match = string.match
  --local strsplit = strsplit
  local itemName, link = tooltip:GetItem()
  if not link then
    return ;
  end

  if DT.MatchItemName(itemName) then
    --tooltip:AddLine(" ") --blank line
    tooltip:AddLine("|c80808080DropTrash|r: This item is marked as trash")
  end
end

function DT:OnSettings()
  LibStub("AceConfigDialog-3.0"):Open(TOCNAME)
end
