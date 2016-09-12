
local myname, ns = ...


local function OnClick(self, button)
	local id = self:GetParent():GetID()
	local link = GetMerchantItemLink(id)
	if not link then return end

	local _, _, _, vendorStackSize, numAvailable = GetMerchantItemInfo(id)
	local maxPurchase = GetMerchantItemMaxStack(id)
	local _, _, _, _, _, _, _, itemStackSize = GetItemInfo(link)

	local size = numAvailable > 0 and numAvailable or itemStackSize
	OpenStackSplitFrame(250, self, "LEFT", "RIGHT")
end


local function OnHide()
	if StackSplitFrame:IsVisible() then StackSplitFrame:Hide() end
end


local function PopoutSplitStack(self, qty)
	ns.Purchase(self:GetParent():GetID(), qty)
end


function ns.NewQtyPopoutFrame(parent)
	local frame = CreateFrame("Button", nil, parent)

	frame:SetNormalTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-FlyoutButton")
	frame:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-FlyoutButton")
	frame:GetNormalTexture():SetTexCoord(0.15625, 0.5, 0.84375, 0.5, 0.15625, 0, 0.84375, 0)
	frame:GetHighlightTexture():SetTexCoord(0.15625, 1, 0.84375, 1, 0.15625, 0.5, 0.84375, 0.5)

	frame:SetScript("OnClick", OnClick)
	frame:SetScript("OnHide", OnHide)

	frame.SplitStack = PopoutSplitStack

	return frame
end
