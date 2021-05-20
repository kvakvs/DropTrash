---@type DropTrashAddon
local _, DT = ...

DT.Const = DT.Const or {}
local Const = DT.Const

--function DtMod:CreateMainButton()
--  local btn;
--  btn = CreateFrame("Frame", "DropTrashButton", UIParent, "SecureActionButtonTemplate")
--  btn.width = 32
--  btn.height = 32
--  btn:SetSize(btn.width, btn.height)
--  btn:SetPoint("CENTER", UIParent, "TOPLEFT",
--    DtMod.GetOption(Const.ButtonPos.X),
--    DtMod.GetOption(Const.ButtonPos.Y))
--  btn:SetFrameStrata("LOW")
--  btn:SetMovable(true)
--  --btn:EnableMouse(true)
--  btn:RegisterForDrag("LeftButton")
--  btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
--  btn:EnableKeyboard(false)
--
--  btn:SetScript("PreClick", DtMod.OnDropButtonClick)
--
--  btn:title = btn:CreateFontString(nil, "OVERLAY")
--  btn:title:SetFont("Fonts\\ARIALN.ttf", 9)
--  btn:title:SetTextColor(1, 1, 0)
--  btn:title:SetAllPoints(self)
--  btn:title:SetText("Drop\nTrash")
--
--  btn:SetAttribute("type", "spell");
--  btn:SetAttribute("unit", nil);
--  btn:SetAttribute("spell", nil);
--  btn:SetAttribute("item", nil);
--  btn:SetAttribute("target-slot", nil);
--end

function DT_DropButtonMoved(self)
  local x, y = self:GetLeft(), self:GetTop() - UIParent:GetHeight();

  DT.SetOption(Const.ButtonPosX, x);
  DT.SetOption(Const.ButtonPosY, y);
end

---@param itemName string
function DT.MatchItemName(itemName)
  for _, matchString in pairs(DropTrash_Rules) do
    -- Do not allow too short strings (4+)
    -- string.find(itemName, matchString)
    if string.len(matchString) > 3 and itemName == matchString then
      return true
    end
  end
  return false
end

function DT.OnDropButtonClick()
  local count = 0

  -- For all bags
  for bagId = 0, 4 do
    -- For all bag slots
    for bagSlotId = 1, 36 do
      local text = GetContainerItemLink(bagId, bagSlotId)
      if text then
        local itemName = GetItemInfo(text)
        if DT.MatchItemName(itemName) then
          -- Drag item and destroy item on cursor
          PickupContainerItem(bagId, bagSlotId)
          DeleteCursorItem()
          count = count + 1
        end
      end
    end
  end

  if count < 1 then
    DT.Print("Destroyed no items")
  else
    DT.Print("Destroyed items and freed " .. tostring(count) .. " slots")
  end
end
