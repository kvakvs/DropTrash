local _TOCNAME, _ADDONPRIVATE = ...
local DT = DT_ADDON ---@type DtAddon

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
  ---@param matchString string
  for _, matchString in pairs(DropTrashRules) do
    -- Do not allow too short strings (4+)
    -- string.find(itemName, matchString)
    if string.len(matchString) > 3 and itemName == matchString then
      return true
    end
  end
  return false
end

---@param eachSlotFn fun(bag: number, slot: number, itemLink: string, itemId: number): boolean
local function forEachBagSlot(eachSlotFn)
  for bag = 0, 4 do
    -- For all bags
    for slot = 1, 36 do
      -- For all bag slots
      local itemLink = C_Container.GetContainerItemLink(bag, slot)

      if itemLink then
        local itemId = tonumber(--[[---@not nil]] string.match(itemLink, "item:(%d+)")) or 0
        if not eachSlotFn(bag, slot, itemLink, itemId) then
          return
        end
      end -- if slot not empty
    end -- each slot
  end -- each bag
end

---Run the cleanup
function DT:OnDropButtonClick()
  local count = 0
  local SOUL_SHARD_ID = 6265

  -- First: Count special items (soul shards)
  local itemCount = --[[---@type {[number]: number}]] {}
  forEachBagSlot(function(bag, slot, itemLink, itemId)
    itemCount[itemId] = (itemCount[itemId] or 0) + 1
    return true
  end)

  -- Second: Reserve special items (soul shards)
  if itemCount[SOUL_SHARD_ID] then
    -- Minimum to reserve: 1
    local reserve = DropTrashOptions.ReserveSoulshards or 5
    if IsInRaid() then
      reserve = DropTrashOptions.ReserveSoulshardsRaid or 12
    else
      if IsInGroup() then
        reserve = DropTrashOptions.ReserveSoulshardsParty or 8
      end
    end
    itemCount[SOUL_SHARD_ID] = itemCount[SOUL_SHARD_ID] - reserve
  end

  -- Third: Drop items, as long as the count is > 0 (this will stop when 0 is reached and allow reserving)
  forEachBagSlot(function(bag, slot, itemLink, itemId)
    if itemCount[itemId] <= 0 then
      return true -- skip dropping but don't stop
    end

    local itemName = GetItemInfo(itemLink)

    if DT.MatchItemName(itemName) then
      -- Pick up item with mouse cursor, and destroy item on cursor
      C_Container.PickupContainerItem(bag, slot)
      DeleteCursorItem()
      count = count + 1
      itemCount[itemId] = itemCount[itemId] - 1
    end

    return true
  end)

  if count < 1 then
    DT:Print("Destroyed no items")
  else
    DT:Print("Destroyed items and freed " .. tostring(count) .. " slots")
  end
end
