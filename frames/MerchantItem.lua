
local myname, ns = ...


local GAP = 4
local HEIGHT = 21
local ICONSIZE = 17


local function PriceIsAltCurrency(index)
	for i=1,MAX_ITEM_COST do
		local _, _, _, currencyName = GetMerchantItemCostItem(index, i)
		if currencyName then return true end
	end
end


local function HasAllCommonBarterItems(index)
	for i=1,MAX_ITEM_COST do
		local _, _, link = GetMerchantItemCostItem(index, i)
		if link then
			local _, _, quality = GetItemInfo(link)
			if quality >= LE_ITEM_QUALITY_UNCOMMON then return false end
		end
	end
	return true
end


local function IsHeirloom(index)
	local id = GetMerchantItemID(index)
	return id and C_Heirloom.IsItemHeirloom(id)
end


local function RequiresConfirmation(index)
	if IsHeirloom(index) then return true end
	if not HasAllCommonBarterItems(index) then return true end
end


local function OnClick(self, button)
	local id = self:GetID()
	local hasaltcurrency = (GetMerchantItemCostInfo(id) > 0)

	if IsAltKeyDown() and not hasaltcurrency then
		self:BuyItem(true)

	elseif IsModifiedClick() then
		HandleModifiedItemClick(GetMerchantItemLink(id))

	elseif hasaltcurrency then
		if not PriceIsAltCurrency(id) and not RequiresConfirmation(id) then
			-- We're trading an item like [Tricky Treat], not using a "real" currency
			self:BuyItem()
		else
			self.link = GetMerchantItemLink(id)
			self.texture = self.icon:GetTexture()
			MerchantFrame_ConfirmExtendedItemCost(self)
		end

	else
		self:BuyItem()
	end
end


local function OnDragStart(self, button)
	MerchantFrame.extendedCost = nil
	PickupMerchantItem(self:GetID())
	if self.extendedCost then MerchantFrame.extendedCost = self end
end


local function OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetMerchantItem(self:GetID())
	GameTooltip_ShowCompareItem()
	MerchantFrame.itemHover = self:GetID()
	if IsModifiedClick("DRESSUP") then ShowInspectCursor() else ResetCursor() end
end


local function OnLeave()
	GameTooltip:Hide()
	ResetCursor()
	MerchantFrame.itemHover = nil
end


function ns.Purchase(id, quantity)
	local _, _, _, _, available = GetMerchantItemInfo(id)
	local max = GetMerchantItemMaxStack(id)

	if available > 0 and available < quantity then quantity = available end
	local purchased = 0
	while purchased < quantity do
		local buyamount = math.min(max, quantity - purchased)
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
	ns.Purchase(id, fullstack and itemStackSize or vendorStackSize or 1)
end


local function SetValue(self, i)
	self:SetID(i)
	self:Show()

	local name, itemTexture, itemPrice, itemStackCount, numAvailable, isUsable, extendedCost = GetMerchantItemInfo(i)
	local link = GetMerchantItemLink(i)

	local gradient, shown = ns.GetRowGradient(i)
	self.backdrop:SetGradientAlpha("HORIZONTAL", unpack(gradient))
	self.backdrop:SetShown(shown)

	self.icon:SetTexture(itemTexture)
	self.icon:SetVertexColor(ns.GetRowVertexColor(i))

	local textcolor = ns.GetRowTextColor(i)
	local text =
		(numAvailable > -1 and ("["..numAvailable.."] ") or "")..
		textcolor..
		(name or "<Loading item data>")..
		(itemStackCount > 1 and ("|r x"..itemStackCount) or "")
	self.ItemName:SetText(text)

	self.AltCurrency:SetValue(i)
	if self.AltCurrency:IsShown() then
	    self.ItemName:SetPoint("RIGHT", self.AltCurrency, "LEFT", -GAP, 0)
	else
	    self.ItemName:SetPoint("RIGHT", self.ItemPrice, "LEFT", -GAP, 0)
	end

	if extendedCost then
		self.link, self.texture, self.extendedCost = link, itemTexture, true
	end
	if itemPrice > 0 then
		self.ItemPrice:SetText(ns.GSC(itemPrice))
		self.Price = itemPrice
	end
	if extendedCost and (itemPrice <= 0) then
		self.ItemPrice:SetText("")
		self.Price = 0
	elseif extendedCost and (itemPrice > 0) then
		self.ItemPrice:SetText(ns.GSC(itemPrice))
	else
		self.extendedCost = nil
	end
end


function ns.NewMerchantItemFrame(parent)
	local frame = CreateFrame("Button", nil, parent)
	frame:SetHeight(HEIGHT)

	frame:SetHighlightTexture("Interface\\HelpFrame\\HelpFrameButton-Highlight")
	frame:GetHighlightTexture():SetTexCoord(0, 1, 0, 0.578125)

	frame:RegisterForClicks("AnyUp")
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnClick", OnClick)
	frame:SetScript("OnDragStart", OnDragStart)
	frame:SetScript("OnEnter", OnEnter)
	frame:SetScript("OnLeave", OnLeave)

	frame.BuyItem = BuyItem
	frame.SetValue = SetValue

	local backdrop = frame:CreateTexture(nil, "BACKGROUND")
	backdrop:SetAllPoints()
	backdrop:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
	frame.backdrop = backdrop

	local icon = CreateFrame('Frame', nil, frame)
	icon:SetHeight(ICONSIZE)
	icon:SetWidth(ICONSIZE)
	icon:SetPoint('LEFT', 2, 0)

	frame.icon = icon:CreateTexture(nil, "BORDER")
	frame.icon:SetAllPoints()

	local popout = ns.NewQtyPopoutFrame(frame)
	popout:SetPoint("RIGHT")
	popout:SetSize(HEIGHT/2, HEIGHT)
	frame.popout = popout

	local ItemPrice = frame:CreateFontString(nil, nil, "NumberFontNormal")
	ItemPrice:SetPoint('RIGHT', popout, "LEFT", -2, 0)
	frame.ItemPrice = ItemPrice

	local AltCurrency = ns.NewAltCurrencyFrame(frame)
	AltCurrency:SetPoint("RIGHT", ItemPrice, "LEFT")
	frame.AltCurrency = AltCurrency

	local ItemName = frame:CreateFontString(nil, nil, "GameFontNormalSmall")
	ItemName:SetPoint("LEFT", icon, "RIGHT", GAP, 0)
	ItemName:SetPoint("RIGHT", AltCurrency, "LEFT", -GAP, 0)
	ItemName:SetJustifyH("LEFT")
	frame.ItemName = ItemName

	return frame
end
