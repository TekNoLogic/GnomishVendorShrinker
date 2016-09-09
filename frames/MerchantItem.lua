
local myname, ns = ...


local GAP = 4
local HEIGHT = 21
local ICONSIZE = 17


local function OnClick(self, button)
	if IsAltKeyDown() and not self.AltCurrency:IsShown() then
		self:BuyItem(true)
	elseif IsModifiedClick() then
		HandleModifiedItemClick(GetMerchantItemLink(self:GetID()))
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


local function SetValue(self, i)
	self:SetID(i)
	self:Show()

	local name, itemTexture, itemPrice, itemStackCount, numAvailable, isUsable, extendedCost = GetMerchantItemInfo(i)
	local link = GetMerchantItemLink(i)

	local gradient, shown = ns.GetRowGradient(i)
	self.backdrop:SetGradientAlpha("HORIZONTAL", unpack(gradient))
	self.backdrop:SetShown(shown)

	self.icon:SetTexture(itemTexture)

	local textcolor = ns.GetRowTextColor(i)
	self.ItemName:SetText((numAvailable > -1 and ("["..numAvailable.."] ") or "").. textcolor.. (name or "<Loading item data>").. (itemStackCount > 1 and ("|r x"..itemStackCount) or ""))

	self.AltCurrency:SetValue(i)

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

	self.icon:SetVertexColor(ns.GetRowVertexColor(i))
end


function ns.NewMerchantItemFrame(parent)
	local frame = CreateFrame("Button", nil, parent)
	frame:SetHeight(HEIGHT)

	frame.BuyItem = BuyItem

	frame:SetHighlightTexture("Interface\\HelpFrame\\HelpFrameButton-Highlight")
	frame:GetHighlightTexture():SetTexCoord(0, 1, 0, 0.578125)

	frame:RegisterForClicks("AnyUp")
	frame:SetScript('OnClick', OnClick)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript('OnDragStart', function(self, button)
		MerchantFrame.extendedCost = nil
		PickupMerchantItem(self:GetID())
		if self.extendedCost then MerchantFrame.extendedCost = self end
	end)

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

	local popout = CreateFrame("Button", nil, frame)
	popout:SetPoint("RIGHT")
	popout:SetWidth(HEIGHT/2) popout:SetHeight(HEIGHT)
	popout:SetNormalTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-FlyoutButton")
	popout:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-FlyoutButton")
	popout:GetNormalTexture():SetTexCoord(0.15625, 0.5, 0.84375, 0.5, 0.15625, 0, 0.84375, 0)
	popout:GetHighlightTexture():SetTexCoord(0.15625, 1, 0.84375, 1, 0.15625, 0.5, 0.84375, 0.5)
	popout:SetScript("OnClick", PopoutOnClick)
	popout.SplitStack = PopoutSplitStack
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

	frame:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetMerchantItem(self:GetID())
		GameTooltip_ShowCompareItem()
		MerchantFrame.itemHover = self:GetID()
		if IsModifiedClick("DRESSUP") then ShowInspectCursor() else ResetCursor() end
	end)

	frame:SetScript('OnLeave', function()
		GameTooltip:Hide()
		ResetCursor()
		MerchantFrame.itemHover = nil
	end)

	frame.SetValue = SetValue

	return frame
end
