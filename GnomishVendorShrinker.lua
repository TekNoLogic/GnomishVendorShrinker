
local myname, ns = ...


local ItemSearch = LibStub('LibItemSearch-1.0')

local NUMROWS, ICONSIZE, GAP, SCROLLSTEP = 14, 17, 4, 5


for _,f in pairs{MerchantNextPageButton, MerchantPrevPageButton, MerchantPageText} do
	f:Hide()
	f.Show = f.Hide
end


local GVS = CreateFrame("frame", nil, MerchantFrame)
GVS:SetWidth(315)
GVS:SetHeight(294)
GVS:SetPoint("TOPLEFT", 8, -67)
GVS:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)
GVS:Hide()


local function OnClick(self, button)
	if IsAltKeyDown() and not self.AltCurrency:IsShown() then self:BuyItem(true)
	elseif IsModifiedClick() then HandleModifiedItemClick(GetMerchantItemLink(self:GetID()))
	elseif self.AltCurrency:IsShown() then
		local id = self:GetID()
		local link = GetMerchantItemLink(id)
		self.link, self.texture = GetMerchantItemLink(id), self.icon:GetTexture()
		MerchantFrame_ConfirmExtendedItemCost(self)
	else self:BuyItem() end
end


local function PopoutOnClick(self, button)
	local id = self:GetParent():GetID()
	local link = GetMerchantItemLink(id)
	if not link then return end

	local _, _, _, vendorStackSize, numAvailable = GetMerchantItemInfo(id)
	local maxPurchase = GetMerchantItemMaxStack(id)
	local _, _, _, _, _, _, _, itemStackSize = GetItemInfo(link)

	local size = numAvailable > 0 and numAvailable or itemStackSize
	OpenStackSplitFrame(250, self, "LEFT", "RIGHT")
end


local function Purchase(id, quantity)
	local _, _, _, vendorStackSize, numAvailable = GetMerchantItemInfo(id)
	local maxPurchase = GetMerchantItemMaxStack(id)

	if numAvailable > 0 and numAvailable < quantity then quantity = numAvailable end
	local purchased = 0
	while purchased < quantity do
		local buyamount = math.min(maxPurchase, quantity - purchased)
		purchased = purchased + buyamount
		BuyMerchantItem(id, buyamount)
	end
end


local function BuyItem(self, fullstack)
	local id = self:GetID()
	local link = GetMerchantItemLink(id)
	if not link then return end

	local _, _, _, vendorStackSize = GetMerchantItemInfo(id)
	local _, _, _, _, _, _, _, itemStackSize = GetItemInfo(link)
	Purchase(id, fullstack and itemStackSize or vendorStackSize or 1)
end


local function PopoutSplitStack(self, qty)
	Purchase(self:GetParent():GetID(), qty)
end


local ROWHEIGHT = 21
local rows = {}
for i=1,NUMROWS do
	local row = CreateFrame('Button', nil, GVS) -- base frame
	row:SetHeight(ROWHEIGHT)
	row:SetPoint("TOP", i == 1 and GVS or rows[i-1], i == 1 and "TOP" or "BOTTOM")
	row:SetPoint("LEFT")
	row:SetPoint("RIGHT", -19, 0)

	row.BuyItem = BuyItem

	row:SetHighlightTexture("Interface\\HelpFrame\\HelpFrameButton-Highlight")
	row:GetHighlightTexture():SetTexCoord(0, 1, 0, 0.578125)

	row:RegisterForClicks("AnyUp")
	row:SetScript('OnClick', OnClick)
	row:RegisterForDrag("LeftButton")
	row:SetScript('OnDragStart', function(self, button)
		MerchantFrame.extendedCost = nil
		PickupMerchantItem(self:GetID())
		if self.extendedCost then MerchantFrame.extendedCost = self end
	end)

	local backdrop = row:CreateTexture(nil, "BACKGROUND")
	backdrop:SetAllPoints()
	backdrop:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
	row.backdrop = backdrop

	local icon = CreateFrame('Frame', nil, row)
	icon:SetHeight(ICONSIZE)
	icon:SetWidth(ICONSIZE)
	icon:SetPoint('LEFT', 2, 0)

	row.icon = icon:CreateTexture(nil, "BORDER")
	row.icon:SetAllPoints()

	local popout = CreateFrame("Button", nil, row)
	popout:SetPoint("RIGHT")
	popout:SetWidth(ROWHEIGHT/2) popout:SetHeight(ROWHEIGHT)
	popout:SetNormalTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-FlyoutButton")
	popout:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-FlyoutButton")
	popout:GetNormalTexture():SetTexCoord(0.15625, 0.5, 0.84375, 0.5, 0.15625, 0, 0.84375, 0)
	popout:GetHighlightTexture():SetTexCoord(0.15625, 1, 0.84375, 1, 0.15625, 0.5, 0.84375, 0.5)
	popout:SetScript("OnClick", PopoutOnClick)
	popout.SplitStack = PopoutSplitStack
	row.popout = popout

	local ItemPrice = row:CreateFontString(nil, nil, "NumberFontNormal")
	ItemPrice:SetPoint('RIGHT', popout, "LEFT", -2, 0)
	row.ItemPrice = ItemPrice

	local AltCurrency = ns.NewAltCurrencyFrame(row)
	AltCurrency:SetPoint("RIGHT", ItemPrice, "LEFT")
	row.AltCurrency = AltCurrency

	local ItemName = row:CreateFontString(nil, nil, "GameFontNormalSmall")
	ItemName:SetPoint("LEFT", icon, "RIGHT", GAP, 0)
	ItemName:SetPoint("RIGHT", AltCurrency, "LEFT", -GAP, 0)
	ItemName:SetJustifyH("LEFT")
	row.ItemName = ItemName

	row:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetMerchantItem(self:GetID())
		GameTooltip_ShowCompareItem()
		MerchantFrame.itemHover = self:GetID()
		if IsModifiedClick("DRESSUP") then ShowInspectCursor() else ResetCursor() end
	end)
	row:SetScript('OnLeave', function()
		GameTooltip:Hide()
		ResetCursor()
		MerchantFrame.itemHover = nil
	end)

	rows[i] = row
end


local function ShowMerchantItem(row, i)
	row:SetID(i)
	row:Show()

	local name, itemTexture, itemPrice, itemStackCount, numAvailable, isUsable, extendedCost = GetMerchantItemInfo(i)
	local link = GetMerchantItemLink(i)

	local gradient, shown = ns.GetRowGradient(i)
	row.backdrop:SetGradientAlpha("HORIZONTAL", unpack(gradient))
	row.backdrop:SetShown(shown)

	row.icon:SetTexture(itemTexture)

	local textcolor = ns.GetRowTextColor(i)
	row.ItemName:SetText((numAvailable > -1 and ("["..numAvailable.."] ") or "").. textcolor.. (name or "<Loading item data>").. (itemStackCount > 1 and ("|r x"..itemStackCount) or ""))

	row.AltCurrency:SetValue(i)

	if extendedCost then
		row.link, row.texture, row.extendedCost = link, itemTexture, true
	end
	if itemPrice > 0 then
		row.ItemPrice:SetText(ns.GSC(itemPrice))
		row.Price = itemPrice
	end
	if extendedCost and (itemPrice <= 0) then
		row.ItemPrice:SetText("")
		row.Price = 0
	elseif extendedCost and (itemPrice > 0) then
		row.ItemPrice:SetText(ns.GSC(itemPrice))
	else
		row.extendedCost = nil
	end

	row.icon:SetVertexColor(ns.GetRowVertexColor(i))
end


local scrollbar = LibStub("tekKonfig-Scroll").new(GVS, 0, SCROLLSTEP)
local offset = 0
local function Refresh()
	local n = GetMerchantNumItems()
	local row, n_searchmatch = 1, 0
	for i=1,n do
		local link = GetMerchantItemLink(i)
		if ItemSearch:Find(link, GVS.searchstring) then
			if n_searchmatch >= offset and n_searchmatch < offset + NUMROWS then
				ShowMerchantItem(rows[row], i)
				row = row + 1
			end
			n_searchmatch = n_searchmatch + 1
		end
	end
	scrollbar:SetMinMaxValues(0, math.max(0, n_searchmatch - NUMROWS))
	for i=row,NUMROWS do
		rows[i]:Hide()
	end
end
GVS.CURRENCY_DISPLAY_UPDATE = Refresh
GVS.BAG_UPDATE = Refresh
GVS.MERCHANT_UPDATE = Refresh


ns.MakeSearchField(GVS, Refresh)


local f = scrollbar:GetScript("OnValueChanged")
scrollbar:SetScript("OnValueChanged", function(self, value, ...)
	offset = math.floor(value)
	Refresh()
	return f(self, value, ...)
end)


local offset = 0
GVS:EnableMouseWheel(true)
GVS:SetScript("OnMouseWheel", function(self, value) scrollbar:SetValue(scrollbar:GetValue() - value * SCROLLSTEP) end)
GVS:SetScript("OnShow", function(self, noreset)
	local max = math.max(0, GetMerchantNumItems() - NUMROWS)
	scrollbar:SetMinMaxValues(0, max)
	scrollbar:SetValue(noreset and math.min(scrollbar:GetValue(), max) or 0)
	Refresh()

	GVS:RegisterEvent("BAG_UPDATE")
	GVS:RegisterEvent("MERCHANT_UPDATE")
	GVS:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
end)
GVS:SetScript("OnHide", function()
	GVS:UnregisterEvent("BAG_UPDATE")
	GVS:UnregisterEvent("MERCHANT_UPDATE")
	GVS:UnregisterEvent("CURRENCY_DISPLAY_UPDATE")
	if StackSplitFrame:IsVisible() then StackSplitFrame:Hide() end
end)


-- Reanchor the buyback button, it acts weird when switching tabs otherwise...
MerchantBuyBackItem:ClearAllPoints()
MerchantBuyBackItem:SetPoint("BOTTOMRIGHT", -7, 33)


local function Show()
	for i=1,12 do _G["MerchantItem"..i]:Hide() end
	if GVS:IsShown() then GVS:GetScript("OnShow")(GVS, true) else GVS:Show() end
end
hooksecurefunc("MerchantFrame_UpdateMerchantInfo", Show)


hooksecurefunc("MerchantFrame_UpdateBuybackInfo", function()
	GVS:Hide()
	for i=1,12 do _G["MerchantItem"..i]:Show() end
end)


if MerchantFrame:IsVisible() and MerchantFrame.selectedTab == 1 then Show() end
