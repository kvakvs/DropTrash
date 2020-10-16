local TOCNAME, DtMod = ...
local Const = DtMod.Const

DtMod.DropButtonMoved = function(self)
  local x, y = self:GetLeft(), self:GetTop() - UIParent:GetHeight();

  DtMod.SetOption(Const.ButtonPosX, x);
  DtMod.SetOption(Const.ButtonPosY, y);
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

DtMod.OnDropButtonClick = function(self)
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
