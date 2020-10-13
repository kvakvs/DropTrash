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

function DropTrash_OnClick(self)
  local count = 0

  -- For all bags
  for b = 0, 4 do
    -- For all bag slots
    for s = 1, 36 do
      local n = GetContainerItemLink(b, s)
      if n and string.find(n, "Bottle of Dalaran Noir") then
        -- Drag item and destroy item on cursor
        PickupContainerItem(b, s)
        DeleteCursorItem()
        count = count + 1
      end
    end
  end

  print("DropTrash: Destroyed", count, "bagslots of items")
end
