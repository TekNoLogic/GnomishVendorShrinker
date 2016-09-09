
local myname, ns = ...


local ICONSIZE, PADDING = 17, 2
local icons, texts = {}, {}
local indexes, ids = {}, {}


local function OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetMerchantCostItem(indexes[self], ids[self])
end


local function OnLeave()
	GameTooltip:Hide()
	ResetCursor()
end


local function GetCurencyCount(item)
	for i=1,GetCurrencyListSize() do
		local name, _, _, _, _, count = GetCurrencyListInfo(i)
		if item == name then return count end
	end
end


local function GetQtyOwned(item)
	local id = ns.ids[item]
	if id then return GetItemCount(id, true) or 0 end

	return GetCurencyCount(item) or 0
end


local function GetTextColor(price, link)
	if link and (GetQtyOwned(link) < price) then return "|cffff9999" end
	return ""
end


local function SetValue(self, i, j)
	indexes[self], ids[self] = i, j

	local texture, price, link, name = GetMerchantItemCostItem(i, j)
	icons[self]:SetTexture(texture)
	texts[self]:SetText(GetTextColor(price, (link or name)).. price)

	self:Show()

	local _, _, width, height = self:GetBoundsRect()
	self:SetSize(width, height)
end


function ns.NewAltCurrencyItemFrame(parent)
	local frame = CreateFrame("Frame", nil, parent)

	frame:SetSize(ICONSIZE, ICONSIZE)

	local text = frame:CreateFontString(nil, nil, "NumberFontNormalSmall")
	text:SetPoint("LEFT")
	texts[frame] = text

	local icon = frame:CreateTexture()
	icon:SetSize(ICONSIZE, ICONSIZE)
	icon:SetPoint("LEFT", text, "RIGHT", PADDING, 0)
	icons[frame] = icon

	frame.SetValue = SetValue

	frame:EnableMouse(true)
	frame:SetScript("OnEnter", OnEnter)
	frame:SetScript("OnLeave", OnLeave)

	return frame
end
